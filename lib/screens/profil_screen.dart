import 'package:flutter/material.dart';
import '../theme/app_theme.dart';
import '../services/storage_service.dart';
import '../models/shop_model.dart';
import '../widgets/framed_avatar.dart';
import 'login_screen.dart';
import 'shop_screen.dart';
import 'statistics_screen.dart';

// PERHATIKAN: Nama class ini harus "ProfilScreen"
class ProfilScreen extends StatefulWidget {
  const ProfilScreen({super.key});

  @override
  State<ProfilScreen> createState() => _ProfilScreenState();
}

class _ProfilScreenState extends State<ProfilScreen> {
  String name = 'User';
  String email = '-';
  int pomodoros = 0;
  int streak = 0;
  int xp = 0;
  bool darkMode = false;
  bool lockApp = false;
  String equippedFrameId = 'default';
  bool streakBroken = false;
  int lastStreakValue = 0;
  final int restoreStreakCost = 50;

  bool hasFreeze = false;
  int themeColorIndex = 0;

  @override
  void initState() {
    super.initState();
    _loadData();
    AppTheme.themeNotifier.addListener(_onThemeChanged);
  }

  @override
  void dispose() {
    AppTheme.themeNotifier.removeListener(_onThemeChanged);
    super.dispose();
  }

  void _onThemeChanged() {
    if (mounted) setState(() => darkMode = AppTheme.isDarkMode);
  }

  Future<void> _loadData() async {
    try {
      await StorageService.checkStreakStatus();
      final n = await StorageService.getCurrentUserName();
      final e = await StorageService.getCurrentUserEmail();
      final total = await StorageService.loadTotalPomodoro();
      final s = await StorageService.loadStreak();
      final userXp = await StorageService.loadXp();
      final lock = await StorageService.loadLockApp();
      final frame = await StorageService.loadEquippedFrame();
      final broken = await StorageService.isStreakBroken();
      final lastVal = await StorageService.loadLastStreakValue();
      final freeze = await StorageService.loadStreakFreeze();
      final colorIdx = await StorageService.loadThemeColorIndex();

      if (!mounted) return;
      setState(() {
        name = n;
        email = e;
        pomodoros = total;
        streak = s;
        xp = userXp;
        lockApp = lock;
        darkMode = AppTheme.isDarkMode;
        equippedFrameId = frame;
        streakBroken = broken;
        lastStreakValue = lastVal;
        hasFreeze = freeze;
        themeColorIndex = colorIdx;
      });
    } catch (err) {
      debugPrint("ERROR PROFIL: $err");
    }
  }

  Future<void> _toggleDarkMode(bool value) async {
    AppTheme.setDarkMode(value);
    if (mounted) setState(() => darkMode = value);
  }

  Future<void> _toggleLockApp(bool value) async {
    setState(() => lockApp = value);
    await StorageService.saveLockApp(value);
  }

  Future<void> _openShop() async {
    await Navigator.push(context, MaterialPageRoute(builder: (_) => const ShopScreen()));
    _loadData();
  }

  Future<void> _openStatistics() async {
    await Navigator.push(context, MaterialPageRoute(builder: (_) => const StatisticsScreen()));
    _loadData();
  }

  Future<void> _buyStreakFreeze() async {
    if (xp < 100) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: const Text('XP tidak cukup! Butuh 100 XP.'), backgroundColor: Colors.red),
      );
      return;
    }
    await StorageService.saveXp(xp - 100);
    await StorageService.saveStreakFreeze(true);
    _loadData();
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: const Text('Streak Freeze berhasil dibeli! ❄️'), backgroundColor: AppTheme.darkTeal),
    );
  }

  Future<void> _changeThemeColor(int index) async {
    await StorageService.saveThemeColorIndex(index);
    AppTheme.setThemeColorIndex(index);
    _loadData();
  }

  Future<void> _restoreStreak() async {
    if (xp < restoreStreakCost) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('XP kamu tidak cukup! Butuh $restoreStreakCost XP.'), backgroundColor: Colors.red),
      );
      return;
    }

    final confirm = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Pulihkan Streak?'),
        content: Text('Gunakan $restoreStreakCost XP untuk memulihkan streak $lastStreakValue hari kamu?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Batal')),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(backgroundColor: AppTheme.primary, minimumSize: const Size(0, 40), padding: const EdgeInsets.symmetric(horizontal: 16)),
            child: const Text('Pulihkan', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );

    if (confirm != true) return;

    await StorageService.saveXp(xp - restoreStreakCost);
    await StorageService.restoreStreak();

    if (!mounted) return;
    _loadData();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Streak $lastStreakValue hari berhasil dipulihkan! 🔥'), backgroundColor: AppTheme.darkTeal),
    );
  }

  void editProfile() {
    final nameController = TextEditingController(text: name);
    final emailController = TextEditingController(text: email);

    showDialog(
      context: context,
      builder: (context) => Dialog(
        backgroundColor: AppTheme.card,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        insetPadding: const EdgeInsets.symmetric(horizontal: 24),
        child: Padding(
          padding: const EdgeInsets.all(22),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(color: AppTheme.lightTeal, borderRadius: BorderRadius.circular(12)),
                    child: Icon(Icons.edit, color: AppTheme.primary, size: 22),
                  ),
                  const SizedBox(width: 12),
                  Text('Edit Profile', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: AppTheme.txt)),
                ],
              ),
              const SizedBox(height: 20),
              TextField(
                controller: nameController,
                style: TextStyle(color: AppTheme.txt),
                decoration: const InputDecoration(labelText: 'Name', prefixIcon: Icon(Icons.person)),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: emailController,
                style: TextStyle(color: AppTheme.txt),
                keyboardType: TextInputType.emailAddress,
                decoration: const InputDecoration(labelText: 'Email', prefixIcon: Icon(Icons.email)),
              ),
              const SizedBox(height: 22),
              Row(
                children: [
                  Expanded(
                    child: SizedBox(
                      height: 48,
                      child: OutlinedButton(
                        onPressed: () => Navigator.pop(context),
                        style: OutlinedButton.styleFrom(
                          foregroundColor: AppTheme.txt,
                          side: BorderSide(color: AppTheme.border, width: 1.5),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                        ),
                        child: const Text('Cancel', style: TextStyle(fontWeight: FontWeight.w600)),
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: SizedBox(
                      height: 48,
                      child: ElevatedButton(
                        onPressed: () async {
                          final newName = nameController.text.trim();
                          final newEmail = emailController.text.trim();
                          if (newName.isEmpty || newEmail.isEmpty) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(content: const Text('Nama dan email tidak boleh kosong'), backgroundColor: Colors.red),
                            );
                            return;
                          }
                          await StorageService.updateCurrentUserName(newName);
                          await StorageService.updateCurrentUserEmail(newEmail);
                          if (!mounted) return;
                          setState(() { name = newName; email = newEmail; });
                          Navigator.pop(context);

                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(content: const Text('Profile berhasil diperbarui ✓'), backgroundColor: AppTheme.darkTeal),
                          );
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppTheme.primary,
                          foregroundColor: Colors.white,
                          minimumSize: const Size(0, 48),
                          padding: const EdgeInsets.symmetric(horizontal: 16),
                          elevation: 0,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                        ),
                        child: const Text('Save', style: TextStyle(fontWeight: FontWeight.bold)),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showHelp() {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Help & Support'),
        content: const Text('Hubungi kami di: support@fokusin.app'),
        actions: [TextButton(onPressed: () => Navigator.pop(context), child: const Text('Tutup'))],
      ),
    );
  }

  void _showApiKeySettings() async {
    final currentKey = await StorageService.loadApiKey();
    final keyController = TextEditingController(text: currentKey);

    if (!mounted) return;
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Row(
          children: [
            Icon(Icons.auto_awesome, color: Colors.teal),
            SizedBox(width: 8),
            Text('Pengaturan Gemini AI'),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Masukkan Gemini API Key milikmu (opsional) untuk mengaktifkan integrasi langsung dengan Google Gemini AI.',
              style: TextStyle(fontSize: 13),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: keyController,
              decoration: const InputDecoration(
                labelText: 'Gemini API Key',
                hintText: 'AIzaSy...',
                border: OutlineInputBorder(),
              ),
              obscureText: true,
            ),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Batal')),
          ElevatedButton(
            onPressed: () async {
              await StorageService.saveApiKey(keyController.text.trim());
              if (!mounted) return;
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('API Key Gemini berhasil disimpan! ✓'), backgroundColor: Colors.teal),
              );
            },
            child: const Text('Simpan'),
          ),
        ],
      ),
    );
  }

  void _showLogout() {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Logout'),
        content: const Text('Yakin ingin keluar?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Batal')),
          ElevatedButton(
            onPressed: () async {
              await StorageService.logout();
              if (!mounted) return;
              Navigator.pushAndRemoveUntil(context, MaterialPageRoute(builder: (_) => const LoginScreen()), (route) => false);
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red, minimumSize: const Size(0, 40), padding: const EdgeInsets.symmetric(horizontal: 16)),
            child: const Text('Logout', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final initial = name.isNotEmpty ? name[0].toUpperCase() : 'U';
    final currentFrame = getFrameById(equippedFrameId);

    return Scaffold(
      backgroundColor: AppTheme.bg,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(
            children: [
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(color: AppTheme.primary, borderRadius: BorderRadius.circular(28)),
                child: Column(
                  children: [
                    FramedAvatar(initial: initial, frame: currentFrame, size: 100),
                    const SizedBox(height: 16),
                    Text(name, style: const TextStyle(color: Colors.white, fontSize: 22, fontWeight: FontWeight.bold)),
                    const SizedBox(height: 4),
                    Text(email, style: const TextStyle(color: Colors.white70, fontSize: 14)),
                    const SizedBox(height: 20),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        OutlinedButton.icon(
                          onPressed: editProfile,
                          icon: const Icon(Icons.edit, size: 16),
                          label: const Text('Edit'),
                          style: OutlinedButton.styleFrom(
                            foregroundColor: Colors.white,
                            side: const BorderSide(color: Colors.white, width: 1.5),
                            minimumSize: const Size(0, 40),
                            padding: const EdgeInsets.symmetric(horizontal: 16),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                          ),
                        ),
                        const SizedBox(width: 12),
                        ElevatedButton.icon(
                          onPressed: _openShop,
                          icon: const Icon(Icons.storefront, size: 16),
                          label: const Text('Shop'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.white,
                            foregroundColor: AppTheme.primary,
                            minimumSize: const Size(0, 40),
                            padding: const EdgeInsets.symmetric(horizontal: 16),
                            elevation: 0,
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 32),

              Row(
                children: [
                  Expanded(child: _StatBox(value: '$pomodoros', label: 'Pomodoros', icon: Icons.timer)),
                  const SizedBox(width: 12),
                  Expanded(child: _StatBox(value: '$streak', label: 'Streak', icon: Icons.local_fire_department)),
                  const SizedBox(width: 12),
                  Expanded(child: _StatBox(value: '$xp', label: 'XP', icon: Icons.star)),
                ],
              ),
              const SizedBox(height: 32),

              if (streakBroken && lastStreakValue > 0) ...[
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: Colors.orange.withValues(alpha: 0.08),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: Colors.orange.withValues(alpha: 0.3), width: 1.5),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          const Icon(Icons.local_fire_department, color: Colors.orange, size: 28),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text('Streak $lastStreakValue Hari Terputus!', style: TextStyle(fontWeight: FontWeight.bold, color: AppTheme.txt)),
                                const SizedBox(height: 4),
                                Text('Pulihkan pakai $restoreStreakCost XP', style: TextStyle(fontSize: 12, color: AppTheme.txtGrey)),
                              ],
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      SizedBox(
                        width: double.infinity,
                        height: 44,
                        child: ElevatedButton.icon(
                          onPressed: _restoreStreak,
                          icon: const Icon(Icons.restore, size: 18),
                          label: const Text('Pulihkan Streak'),
                          style: ElevatedButton.styleFrom(backgroundColor: Colors.orange, foregroundColor: Colors.white, minimumSize: const Size(0, 44)),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 32),
              ],

              Align(
                alignment: Alignment.centerLeft,
                child: Text('Upgrades', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppTheme.txt)),
              ),
              const SizedBox(height: 12),

              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: hasFreeze ? Colors.blue.withValues(alpha: 0.1) : AppTheme.card,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: hasFreeze ? Colors.blue : AppTheme.border, width: 1.5),
                ),
                child: Row(
                  children: [
                    Icon(Icons.ac_unit, color: hasFreeze ? Colors.blue : AppTheme.primary, size: 28),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Streak Freeze', style: TextStyle(fontWeight: FontWeight.bold, color: AppTheme.txt)),
                          Text(hasFreeze ? 'Aktif (Melindungi streak 1 hari)' : 'Lindungi streak jika bolong 1 hari', style: TextStyle(fontSize: 12, color: AppTheme.txtGrey)),
                        ],
                      ),
                    ),
                    if (!hasFreeze)
                      ElevatedButton(
                        onPressed: _buyStreakFreeze,
                        style: ElevatedButton.styleFrom(backgroundColor: AppTheme.primary, minimumSize: const Size(0, 40), padding: const EdgeInsets.symmetric(horizontal: 16)),
                        child: const Text('Beli (100 XP)', style: TextStyle(fontSize: 12, color: Colors.white)),
                      ),
                  ],
                ),
              ),
              const SizedBox(height: 12),

              Container(
                padding: const EdgeInsets.all(16),
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
                        Icon(Icons.palette, color: xp >= 500 ? AppTheme.primary : Colors.grey, size: 28),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text('Warna Tema Premium', style: TextStyle(fontWeight: FontWeight.bold, color: AppTheme.txt)),
                              Text(xp >= 500 ? 'Pilih warna favoritmu!' : 'Butuh 500 XP untuk membuka', style: TextStyle(fontSize: 12, color: AppTheme.txtGrey)),
                            ],
                          ),
                        ),
                        if (xp < 500) const Icon(Icons.lock, color: Colors.grey),
                      ],
                    ),
                    if (xp >= 500) ...[
                      const SizedBox(height: 16),
                      SizedBox(
                        height: 50,
                        child: ListView.builder(
                          scrollDirection: Axis.horizontal,
                          itemCount: AppTheme.colorThemes.length,
                          itemBuilder: (context, index) {
                            final color = AppTheme.colorThemes[index]['primary'] as Color;
                            final isSelected = themeColorIndex == index;
                            return GestureDetector(
                              onTap: () => _changeThemeColor(index),
                              child: Container(
                                width: 50,
                                margin: const EdgeInsets.only(right: 12),
                                decoration: BoxDecoration(
                                  color: color,
                                  shape: BoxShape.circle,
                                  border: Border.all(color: isSelected ? AppTheme.txt : Colors.transparent, width: 3),
                                ),
                                child: isSelected ? const Icon(Icons.check, color: Colors.white) : null,
                              ),
                            );
                          },
                        ),
                      ),
                    ]
                  ],
                ),
              ),
              const SizedBox(height: 32),

              Align(alignment: Alignment.centerLeft, child: Text('Settings', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppTheme.txt))),
              const SizedBox(height: 12),
              _SwitchTile(icon: darkMode ? Icons.dark_mode : Icons.light_mode, title: 'Dark Mode', value: darkMode, onChanged: _toggleDarkMode),
              _SwitchTile(icon: Icons.lock_outline, title: 'Kunci Aplikasi', value: lockApp, onChanged: _toggleLockApp),
              _TileButton(icon: Icons.auto_awesome, title: 'Pengaturan Gemini AI', onTap: _showApiKeySettings),
              _TileButton(icon: Icons.bar_chart_rounded, title: 'Statistik Mingguan', onTap: _openStatistics),
              _TileButton(icon: Icons.help_outline, title: 'Help & Support', onTap: _showHelp),
              const SizedBox(height: 20),
              SizedBox(
                width: double.infinity,
                height: 54,
                child: OutlinedButton.icon(
                  onPressed: _showLogout,
                  icon: const Icon(Icons.logout),
                  label: const Text('Logout'),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: Colors.red,
                    side: const BorderSide(color: Colors.red, width: 1.5),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                  ),
                ),
              ),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }
}

class _StatBox extends StatelessWidget {
  final String value;
  final String label;
  final IconData icon;
  const _StatBox({required this.value, required this.label, required this.icon});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 16),
      decoration: BoxDecoration(color: AppTheme.card, borderRadius: BorderRadius.circular(20), border: Border.all(color: AppTheme.border, width: 1.5)),
      child: Column(
        children: [
          Icon(icon, color: AppTheme.primary, size: 28),
          const SizedBox(height: 8),
          Text(value, style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: AppTheme.txt)),
          const SizedBox(height: 4),
          Text(label, style: TextStyle(fontSize: 12, color: AppTheme.txtGrey)),
        ],
      ),
    );
  }
}

class _TileButton extends StatelessWidget {
  final IconData icon;
  final String title;
  final VoidCallback onTap;
  const _TileButton({required this.icon, required this.title, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(color: AppTheme.card, borderRadius: BorderRadius.circular(20), border: Border.all(color: AppTheme.border, width: 1.5)),
      child: ListTile(
        onTap: onTap,
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
        leading: Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(color: AppTheme.lightTeal, borderRadius: BorderRadius.circular(12)),
          child: Icon(icon, color: AppTheme.primary, size: 22),
        ),
        title: Text(title, style: TextStyle(fontWeight: FontWeight.w600, color: AppTheme.txt)),
        trailing: Icon(Icons.chevron_right, color: AppTheme.txtGrey),
      ),
    );
  }
}

class _SwitchTile extends StatelessWidget {
  final IconData icon;
  final String title;
  final bool value;
  final ValueChanged<bool> onChanged;
  const _SwitchTile({required this.icon, required this.title, required this.value, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(color: AppTheme.card, borderRadius: BorderRadius.circular(20), border: Border.all(color: AppTheme.border, width: 1.5)),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(color: AppTheme.lightTeal, borderRadius: BorderRadius.circular(12)),
            child: Icon(icon, color: AppTheme.primary, size: 22),
          ),
          const SizedBox(width: 16),
          Expanded(child: Text(title, style: TextStyle(fontWeight: FontWeight.w600, fontSize: 15, color: AppTheme.txt))),
          Switch(value: value, onChanged: onChanged),
        ],
      ),
    );
  }
}