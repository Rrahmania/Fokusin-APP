import 'package:flutter/material.dart';
import '../theme/app_theme.dart';
import '../services/storage_service.dart';
import '../services/music_service.dart';
import '../services/ai_service.dart';
import '../models/music_model.dart';
import 'login_screen.dart';

class AdminDashboardScreen extends StatefulWidget {
  const AdminDashboardScreen({super.key});

  @override
  State<AdminDashboardScreen> createState() => _AdminDashboardScreenState();
}

class _AdminDashboardScreenState extends State<AdminDashboardScreen> with SingleTickerProviderStateMixin {
  late final TabController _tabController;
  bool isLoading = true;

  List<Map<String, dynamic>> usersList = [];
  List<MusicTrack> customTracks = [];
  int totalPomodoros = 0;
  String currentApiKey = '';
  bool isAiTesting = false;
  String aiTestResult = '';

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
    _loadAdminData();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _loadAdminData() async {
    setState(() => isLoading = true);
    try {
      await MusicService.instance.reloadPlaylist();
      final users = await StorageService.getAllRegisteredUsers();
      final tracks = await StorageService.loadCustomMusicTracks();
      final pomodoroCount = await StorageService.loadTotalPomodoro();
      final key = await StorageService.loadApiKey();

      if (!mounted) return;
      setState(() {
        usersList = users;
        customTracks = tracks;
        totalPomodoros = pomodoroCount;
        currentApiKey = key;
        isLoading = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() => isLoading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Gagal memuat data admin: $e'), backgroundColor: Colors.red),
      );
    }
  }

  Future<void> _logoutAdmin() async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Keluar dari Portal Admin?'),
        content: const Text('Apakah Anda ingin keluar dari akun Super Admin?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('Batal')),
          ElevatedButton(
            onPressed: () => Navigator.pop(ctx, true),
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('Logout', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );

    if (confirm == true) {
      await StorageService.logout();
      if (!mounted) return;
      Navigator.pushAndRemoveUntil(context, MaterialPageRoute(builder: (_) => const LoginScreen()), (route) => false);
    }
  }

  Future<void> _toggleBlockUser(String email, String name, bool isCurrentlyBlocked) async {
    if (isCurrentlyBlocked) {
      await StorageService.unblockUser(email);
    } else {
      await StorageService.blockUser(email);
    }

    await _loadAdminData();

    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(isCurrentlyBlocked ? 'Pengguna $name berhasil dibuka blokirnya.' : 'Pengguna $name berhasil DIBLOKIR 🚫.'),
        backgroundColor: isCurrentlyBlocked ? Colors.teal : Colors.orange,
      ),
    );
  }

  Future<void> _deleteUser(String email, String name) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Hapus Pengguna?'),
        content: Text('Apakah Anda yakin ingin menghapus pengguna "$name" ($email)?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('Batal')),
          ElevatedButton(
            onPressed: () => Navigator.pop(ctx, true),
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('Hapus', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );

    if (confirm == true) {
      await StorageService.deleteRegisteredUser(email);
      await _loadAdminData();
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Pengguna $name berhasil dihapus.'), backgroundColor: Colors.red),
      );
    }
  }

  Future<void> _showAddSongDialog() async {
    final titleCtrl = TextEditingController();
    final artistCtrl = TextEditingController(text: 'Admin Soundscape');
    final durationCtrl = TextEditingController(text: '3:00');
    final secondsCtrl = TextEditingController(text: '180');
    final pathCtrl = TextEditingController(text: 'music/piano.mp3');
    final xpCtrl = TextEditingController(text: '0');

    final result = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Row(
          children: [
            Icon(Icons.library_music, color: Colors.teal),
            SizedBox(width: 8),
            Text('Tambah Lagu'),
          ],
        ),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(controller: titleCtrl, decoration: const InputDecoration(labelText: 'Judul Lagu (Contoh: Deep Focus)')),
              const SizedBox(height: 10),
              TextField(controller: artistCtrl, decoration: const InputDecoration(labelText: 'Artis / Kategori')),
              const SizedBox(height: 10),
              TextField(controller: durationCtrl, decoration: const InputDecoration(labelText: 'Durasi (Contoh: 3:30)')),
              const SizedBox(height: 10),
              TextField(controller: secondsCtrl, keyboardType: TextInputType.number, decoration: const InputDecoration(labelText: 'Durasi Detik (Contoh: 210)')),
              const SizedBox(height: 10),
              TextField(controller: pathCtrl, decoration: const InputDecoration(labelText: 'File Path MP3 / URL')),
              const SizedBox(height: 10),
              TextField(controller: xpCtrl, keyboardType: TextInputType.number, decoration: const InputDecoration(labelText: 'Required XP (0 = Gratis)')),
            ],
          ),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('Batal')),
          ElevatedButton(
            onPressed: () => Navigator.pop(ctx, true),
            style: ElevatedButton.styleFrom(backgroundColor: AppTheme.primary),
            child: const Text('Simpan Lagu'),
          ),
        ],
      ),
    );

    if (result == true) {
      if (titleCtrl.text.trim().isEmpty) return;

      final track = MusicTrack(
        title: titleCtrl.text.trim(),
        artist: artistCtrl.text.trim(),
        duration: durationCtrl.text.trim(),
        durationSeconds: int.tryParse(secondsCtrl.text.trim()) ?? 180,
        icon: Icons.music_note,
        color: AppTheme.primary,
        filePath: pathCtrl.text.trim(),
        price: int.tryParse(xpCtrl.text.trim()) ?? 0,
      );

      await StorageService.saveCustomMusicTrack(track);
      await MusicService.instance.reloadPlaylist();
      await _loadAdminData();

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Lagu "${track.title}" berhasil ditambahkan! 🎵'), backgroundColor: AppTheme.primary),
      );
    }
  }

  Future<void> _deleteSong(String title) async {
    await StorageService.deleteCustomMusicTrack(title);
    await MusicService.instance.reloadPlaylist();
    await _loadAdminData();

    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Lagu "$title" berhasil dihapus.'), backgroundColor: Colors.red),
    );
  }

  Future<void> _testGeminiAi() async {
    setState(() {
      isAiTesting = true;
      aiTestResult = '';
    });

    try {
      final rec = await AiService.getRecommendation(
        todayPomodoro: 4,
        streak: 7,
        totalXp: 999999,
      );

      if (!mounted) return;
      setState(() {
        aiTestResult = 'SUCCESS: ${rec.title} - ${rec.description} (${rec.tag})';
        isAiTesting = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        aiTestResult = 'ERROR: $e';
        isAiTesting = false;
      });
    }
  }

  Future<void> _showAddUserDialog() async {
    final result = await showDialog<Map<String, String>>(
      context: context,
      builder: (ctx) => const _AddUserDialog(),
    );

    if (result == null) return;

    try {
      await StorageService.registerUser(
        name: result['name']!,
        email: result['email']!,
        password: result['password']!,
      );
      await _loadAdminData();
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Pengguna baru berhasil ditambahkan!'), backgroundColor: Colors.teal),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Gagal menambah pengguna: $e'), backgroundColor: Colors.red),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.bg,
      appBar: AppBar(
        title: const Row(
          children: [
            Icon(Icons.admin_panel_settings, color: Colors.amber, size: 28),
            SizedBox(width: 8),
            Text('Portal Admin Fokusin', style: TextStyle(fontWeight: FontWeight.bold)),
          ],
        ),
        backgroundColor: AppTheme.bg,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadAdminData,
            tooltip: 'Perbarui Data',
          ),
          IconButton(
            icon: const Icon(Icons.logout, color: Colors.redAccent),
            onPressed: _logoutAdmin,
            tooltip: 'Logout Admin',
          ),
        ],
        bottom: TabBar(
          controller: _tabController,
          labelColor: AppTheme.primary,
          unselectedLabelColor: AppTheme.txtGrey,
          indicatorColor: AppTheme.primary,
          tabs: const [
            Tab(icon: Icon(Icons.dashboard_rounded), text: 'Home Admin'),
            Tab(icon: Icon(Icons.people_alt_rounded), text: 'Kelola User'),
            Tab(icon: Icon(Icons.library_music_rounded), text: 'Tambah Lagu'),
            Tab(icon: Icon(Icons.auto_awesome), text: 'AI & Sistem'),
          ],
        ),
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : Column(
        children: [
          // BANNER MODE ADMIN UNLIMITED
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
            decoration: BoxDecoration(
              color: Colors.amber.withValues(alpha: 0.15),
              border: Border(bottom: BorderSide(color: Colors.amber.withValues(alpha: 0.4), width: 1.5)),
            ),
            child: const Row(
              children: [
                Icon(Icons.verified_user, color: Colors.amber, size: 24),
                SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('AKUN SUPER ADMIN AKTIF 👑', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: Colors.amber)),
                      Text('Akses Penuh Pantauan Aplikasi • Bebas Biaya XP (♾️ XP)', style: TextStyle(fontSize: 11, color: Colors.black87)),
                    ],
                  ),
                ),
              ],
            ),
          ),

          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [
                _buildHomeAdminTab(),
                _buildUsersTab(),
                _buildSongsTab(),
                _buildAiSystemTab(),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHomeAdminTab() {
    final blockedCount = usersList.where((u) => u['isBlocked'] == true).length;
    final allPlaylistCount = MusicService.instance.playlist.length;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: AppTheme.primary,
              borderRadius: BorderRadius.circular(24),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: const BoxDecoration(color: Colors.white24, shape: BoxShape.circle),
                      child: const Icon(Icons.shield, color: Colors.white, size: 24),
                    ),
                    const SizedBox(width: 12),
                    const Text('Monitoring Pusat', style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold)),
                    const Spacer(),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(color: Colors.green, borderRadius: BorderRadius.circular(12)),
                      child: const Text('SERVER ONLINE', style: TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.bold)),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                const Text('Dashboard Pantauan Admin', style: TextStyle(color: Colors.white, fontSize: 22, fontWeight: FontWeight.bold)),
                const SizedBox(height: 4),
                const Text('Pantau aktivitas pengguna, status blokir, lagu soundscape, dan performa AI secara langsung.', style: TextStyle(color: Colors.white70, fontSize: 13)),
              ],
            ),
          ),
          const SizedBox(height: 24),

          Text('Pantauan Sistem', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppTheme.txt)),
          const SizedBox(height: 12),

          Row(
            children: [
              Expanded(
                child: _AdminStatCard(
                  title: 'Total Pengguna',
                  value: '${usersList.length}',
                  icon: Icons.people,
                  color: Colors.blue,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _AdminStatCard(
                  title: 'Pengguna Diblokir',
                  value: '$blockedCount',
                  icon: Icons.block,
                  color: Colors.redAccent,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: _AdminStatCard(
                  title: 'Total Pomodoro',
                  value: '$totalPomodoros',
                  icon: Icons.timer,
                  color: Colors.teal,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _AdminStatCard(
                  title: 'Track Soundscape',
                  value: '$allPlaylistCount',
                  icon: Icons.music_note,
                  color: Colors.purple,
                ),
              ),
            ],
          ),

          const SizedBox(height: 28),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('Pengguna Terbaru', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppTheme.txt)),
              TextButton(
                onPressed: () => _tabController.animateTo(1),
                child: const Text('Lihat Semua'),
              ),
            ],
          ),
          const SizedBox(height: 8),

          ...usersList.take(3).map((u) {
            final name = u['name'] as String? ?? 'User';
            final email = u['email'] as String? ?? '-';
            final isBlocked = u['isBlocked'] as bool? ?? false;
            final role = u['role'] as String? ?? 'user';
            final isAdmin = role == 'admin' || email.toLowerCase().contains('admin');

            return Container(
              margin: const EdgeInsets.only(bottom: 10),
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: isBlocked ? Colors.red.withValues(alpha: 0.05) : AppTheme.card,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: isBlocked ? Colors.red.withValues(alpha: 0.5) : AppTheme.border, width: 1.5),
              ),
              child: Row(
                children: [
                  CircleAvatar(
                    radius: 18,
                    backgroundColor: isBlocked
                        ? Colors.red.withValues(alpha: 0.2)
                        : (isAdmin ? Colors.amber.withValues(alpha: 0.2) : AppTheme.primary.withValues(alpha: 0.15)),
                    child: Icon(isBlocked ? Icons.block : (isAdmin ? Icons.admin_panel_settings : Icons.person), size: 20, color: isBlocked ? Colors.red : (isAdmin ? Colors.amber[800] : AppTheme.primary)),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(name, style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: isBlocked ? Colors.red : AppTheme.txt)),
                        Text(email, style: TextStyle(fontSize: 12, color: AppTheme.txtGrey)),
                      ],
                    ),
                  ),
                  if (!isAdmin)
                    TextButton(
                      onPressed: () => _toggleBlockUser(email, name, isBlocked),
                      child: Text(isBlocked ? 'Buka' : 'Blokir', style: TextStyle(fontSize: 12, color: isBlocked ? Colors.green : Colors.orange)),
                    ),
                ],
              ),
            );
          }),

          const SizedBox(height: 24),
          Text('Aksi Cepat Admin', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppTheme.txt)),
          const SizedBox(height: 12),

          Row(
            children: [
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: _showAddSongDialog,
                  icon: const Icon(Icons.music_note, size: 18),
                  label: const Text('Tambah Lagu'),
                  style: ElevatedButton.styleFrom(backgroundColor: AppTheme.primary, minimumSize: const Size(0, 48)),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: _showAddUserDialog,
                  icon: const Icon(Icons.person_add, size: 18),
                  label: const Text('Tambah User'),
                  style: OutlinedButton.styleFrom(minimumSize: const Size(0, 48)),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildUsersTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('Kelola Pengguna (${usersList.length})', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppTheme.txt)),
              ElevatedButton.icon(
                onPressed: _showAddUserDialog,
                icon: const Icon(Icons.person_add, size: 18),
                label: const Text('User Baru'),
                style: ElevatedButton.styleFrom(backgroundColor: AppTheme.primary),
              ),
            ],
          ),
          const SizedBox(height: 16),
          if (usersList.isEmpty)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 40),
              child: Center(child: Text('Belum ada pengguna terdaftar.', style: TextStyle(color: AppTheme.txtGrey))),
            )
          else
            ...usersList.map((u) {
              final name = u['name'] as String? ?? 'User';
              final email = u['email'] as String? ?? '-';
              final role = u['role'] as String? ?? 'user';
              final isBlocked = u['isBlocked'] as bool? ?? false;
              final isAdmin = role == 'admin' || email.toLowerCase().contains('admin');

              return Container(
                margin: const EdgeInsets.only(bottom: 12),
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: isBlocked ? Colors.red.withValues(alpha: 0.05) : AppTheme.card,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: isBlocked ? Colors.red.withValues(alpha: 0.6) : (isAdmin ? Colors.amber.withValues(alpha: 0.6) : AppTheme.border),
                    width: 1.5,
                  ),
                ),
                child: Row(
                  children: [
                    CircleAvatar(
                      backgroundColor: isBlocked
                          ? Colors.red.withValues(alpha: 0.2)
                          : (isAdmin ? Colors.amber.withValues(alpha: 0.2) : AppTheme.primary.withValues(alpha: 0.15)),
                      child: Icon(
                        isBlocked ? Icons.block : (isAdmin ? Icons.admin_panel_settings : Icons.person),
                        color: isBlocked ? Colors.red : (isAdmin ? Colors.amber[800] : AppTheme.primary),
                      ),
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Flexible(
                                child: Text(
                                  name,
                                  overflow: TextOverflow.ellipsis,
                                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: isBlocked ? Colors.red : AppTheme.txt),
                                ),
                              ),
                              const SizedBox(width: 8),
                              if (isAdmin)
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                  decoration: BoxDecoration(color: Colors.amber[800], borderRadius: BorderRadius.circular(6)),
                                  child: const Text('ADMIN', style: TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold)),
                                )
                              else if (isBlocked)
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                  decoration: BoxDecoration(color: Colors.red, borderRadius: BorderRadius.circular(6)),
                                  child: const Text('DIBLOKIR 🚫', style: TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold)),
                                ),
                            ],
                          ),
                          const SizedBox(height: 4),
                          Text(email, overflow: TextOverflow.ellipsis, style: TextStyle(fontSize: 13, color: AppTheme.txtGrey)),
                        ],
                      ),
                    ),
                    if (!isAdmin) ...[
                      TextButton.icon(
                        onPressed: () => _toggleBlockUser(email, name, isBlocked),
                        icon: Icon(isBlocked ? Icons.lock_open : Icons.block, size: 16, color: isBlocked ? Colors.green : Colors.orange),
                        label: Text(isBlocked ? 'Buka' : 'Blokir', style: TextStyle(fontSize: 12, color: isBlocked ? Colors.green : Colors.orange)),
                      ),
                      IconButton(
                        icon: const Icon(Icons.delete_outline, color: Colors.red, size: 20),
                        onPressed: () => _deleteUser(email, name),
                        tooltip: 'Hapus User',
                      ),
                    ],
                  ],
                ),
              );
            }),
        ],
      ),
    );
  }

  Widget _buildSongsTab() {
    final allPlaylist = MusicService.instance.playlist.isEmpty
        ? defaultPlaylist
        : MusicService.instance.playlist;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('Daftar Lagu Soundscape (${allPlaylist.length})', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppTheme.txt)),
              ElevatedButton.icon(
                onPressed: _showAddSongDialog,
                icon: const Icon(Icons.add, size: 18),
                label: const Text('Tambah Lagu'),
                style: ElevatedButton.styleFrom(backgroundColor: AppTheme.primary),
              ),
            ],
          ),
          const SizedBox(height: 16),
          ...allPlaylist.map((song) {
            final isCustom = customTracks.any((t) => t.title.toLowerCase() == song.title.toLowerCase());

            return Container(
              margin: const EdgeInsets.only(bottom: 12),
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppTheme.card,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: isCustom ? AppTheme.primary : AppTheme.border, width: 1.5),
              ),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(color: song.color.withValues(alpha: 0.15), shape: BoxShape.circle),
                    child: Icon(song.icon, color: song.color, size: 24),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Text(song.title, style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: AppTheme.txt)),
                            if (isCustom) ...[
                              const SizedBox(width: 8),
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                decoration: BoxDecoration(color: AppTheme.primary, borderRadius: BorderRadius.circular(6)),
                                child: const Text('ADMIN ADDED', style: TextStyle(color: Colors.white, fontSize: 9, fontWeight: FontWeight.bold)),
                              ),
                            ],
                          ],
                        ),
                        const SizedBox(height: 4),
                        Text('${song.artist} • ${song.duration}', style: TextStyle(fontSize: 13, color: AppTheme.txtGrey)),
                      ],
                    ),
                  ),
                  if (isCustom)
                    IconButton(
                      icon: const Icon(Icons.delete_outline, color: Colors.red),
                      onPressed: () => _deleteSong(song.title),
                      tooltip: 'Hapus Lagu',
                    ),
                ],
              ),
            );
          }),
        ],
      ),
    );
  }

  Widget _buildAiSystemTab() {
    final isSuccess = aiTestResult.startsWith('SUCCESS');
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Diagnosis & Integrasi Gemini AI', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppTheme.txt)),
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: AppTheme.card,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: AppTheme.border, width: 1.5),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(Icons.auto_awesome, color: AppTheme.primary, size: 24),
                    const SizedBox(width: 12),
                    Text('Gemini API Integration', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: AppTheme.txt)),
                  ],
                ),
                const SizedBox(height: 12),
                Text(
                  currentApiKey.isNotEmpty ? 'API Key tersimpan aktif.' : 'API Key tidak diset (Menggunakan Smart Heuristic Engine).',
                  style: TextStyle(fontSize: 13, color: AppTheme.txtGrey),
                ),
                const SizedBox(height: 16),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    onPressed: isAiTesting ? null : _testGeminiAi,
                    icon: isAiTesting
                        ? const SizedBox(width: 18, height: 18, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                        : const Icon(Icons.bolt),
                    label: Text(isAiTesting ? 'Menguji AI...' : 'Uji Respon AI Gemini Sekarang'),
                    style: ElevatedButton.styleFrom(backgroundColor: AppTheme.primary),
                  ),
                ),
                if (aiTestResult.isNotEmpty) ...[
                  const SizedBox(height: 16),
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: isSuccess ? Colors.green.withValues(alpha: 0.1) : Colors.red.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      aiTestResult,
                      style: TextStyle(fontSize: 12, color: isSuccess ? Colors.green[800] : Colors.red[800]),
                    ),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _AddUserDialog extends StatefulWidget {
  const _AddUserDialog();

  @override
  State<_AddUserDialog> createState() => _AddUserDialogState();
}

class _AddUserDialogState extends State<_AddUserDialog> {
  final _nameCtrl = TextEditingController();
  final _emailCtrl = TextEditingController();
  final _passCtrl = TextEditingController();

  @override
  void dispose() {
    _nameCtrl.dispose();
    _emailCtrl.dispose();
    _passCtrl.dispose();
    super.dispose();
  }

  void _submit() {
    final name = _nameCtrl.text.trim();
    final email = _emailCtrl.text.trim();
    final pass = _passCtrl.text.trim();
    if (name.isEmpty || email.isEmpty || pass.isEmpty) return;
    Navigator.pop(context, {'name': name, 'email': email, 'password': pass});
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Tambah Pengguna Baru'),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(controller: _nameCtrl, decoration: const InputDecoration(labelText: 'Nama Lengkap')),
            const SizedBox(height: 10),
            TextField(controller: _emailCtrl, keyboardType: TextInputType.emailAddress, decoration: const InputDecoration(labelText: 'Email')),
            const SizedBox(height: 10),
            TextField(controller: _passCtrl, decoration: const InputDecoration(labelText: 'Password'), obscureText: true),
          ],
        ),
      ),
      actions: [
        TextButton(onPressed: () => Navigator.pop(context), child: const Text('Batal')),
        ElevatedButton(onPressed: _submit, child: const Text('Simpan')),
      ],
    );
  }
}

class _AdminStatCard extends StatelessWidget {
  final String title;
  final String value;
  final IconData icon;
  final Color color;

  const _AdminStatCard({
    required this.title,
    required this.value,
    required this.icon,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppTheme.card,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppTheme.border, width: 1.5),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(color: color.withValues(alpha: 0.15), borderRadius: BorderRadius.circular(10)),
            child: Icon(icon, color: color, size: 22),
          ),
          const SizedBox(height: 12),
          Text(value, style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: AppTheme.txt)),
          const SizedBox(height: 4),
          Text(title, style: TextStyle(fontSize: 12, color: AppTheme.txtGrey)),
        ],
      ),
    );
  }
}