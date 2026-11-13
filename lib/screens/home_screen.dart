import 'package:flutter/material.dart';
import '../theme/app_theme.dart';
import '../services/storage_service.dart';
import '../widgets/music_card.dart';
import '../widgets/bottom_nav.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  String userName = 'User';
  String userInitial = 'U';
  int pomodoros = 0;
  int streak = 0;
  int xp = 0;
  bool streakBroken = false;
  int lastStreakValue = 0;
  final int restoreStreakCost = 50;

  // State untuk AI Recommendation
  int aiIndex = 0;
  final List<Map<String, dynamic>> aiSuggestions = [
    {
      'title': 'Belajar Flutter UI',
      'desc': 'Kamu sudah fokus dengan baik minggu ini. Coba pelajari animasi di Flutter selama 25 menit.',
      'tag': 'Coding',
    },
    {
      'title': 'Review Materi Kuliah',
      'desc': 'Gunakan waktu fokus untuk mengulang materi yang belum dikuasai hari ini.',
      'tag': 'Belajar',
    },
    {
      'title': 'Kerjakan Project',
      'desc': 'Lanjutkan project yang sedang kamu kerjakan. Selesaikan satu sub-task dulu.',
      'tag': 'Bekerja',
    },
  ];

  @override
  void initState() {
    super.initState();
    _loadUser();
  }

  Future<void> _loadUser() async {
    try {
      await StorageService.checkStreakStatus();
      final name = await StorageService.getCurrentUserName();
      final total = await StorageService.loadTotalPomodoro();
      final s = await StorageService.loadStreak();
      final userXp = await StorageService.loadXp();
      final broken = await StorageService.isStreakBroken();
      final lastVal = await StorageService.loadLastStreakValue();

      if (!mounted) return;
      setState(() {
        userName = name;
        userInitial = name.isNotEmpty ? name[0].toUpperCase() : 'U';
        pomodoros = total;
        streak = s;
        xp = userXp;
        streakBroken = broken;
        lastStreakValue = lastVal;
      });
    } catch (err) {
      debugPrint("ERROR HOME: $err");
    }
  }

  void _goToProfile() => BottomNav.navNotifier.value = 4;

  void _nextAiSuggestion() {
    setState(() {
      aiIndex = (aiIndex + 1) % aiSuggestions.length;
    });
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
      builder: (context) => AlertDialog(
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
    _loadUser();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Streak $lastStreakValue hari berhasil dipulihkan! 🔥'), backgroundColor: AppTheme.darkTeal),
    );
  }

  String get greeting {
    final h = DateTime.now().hour;
    if (h < 12) return 'Good Morning ☀️';
    if (h < 17) return 'Good Afternoon 🌤️';
    if (h < 21) return 'Good Evening 🌆';
    return 'Good Night 🌙';
  }

  @override
  Widget build(BuildContext context) {
    final currentAi = aiSuggestions[aiIndex];

    return Scaffold(
      backgroundColor: AppTheme.bg,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(24, 32, 24, 40),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // HEADER
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(greeting.toUpperCase(), style: TextStyle(fontSize: 11, letterSpacing: 2, fontWeight: FontWeight.bold, color: AppTheme.txtGrey)),
                      const SizedBox(height: 8),
                      Text("Halo,\n$userName.", style: TextStyle(fontSize: 34, height: 1.1, fontWeight: FontWeight.w800, color: AppTheme.txt, letterSpacing: -1)),
                    ],
                  ),
                  GestureDetector(
                    onTap: _goToProfile,
                    child: Container(
                      width: 50,
                      height: 50,
                      decoration: BoxDecoration(color: AppTheme.primary, shape: BoxShape.circle), // Hapus const
                      child: Center(child: Text(userInitial, style: const TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold))),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 32),

              // BANNER STREAK PUTUS
              if (streakBroken && lastStreakValue > 0) ...[
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: Colors.orange.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: Colors.orange.withValues(alpha: 0.3), width: 1.5),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.local_fire_department, color: Colors.orange, size: 32),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('Streak $lastStreakValue Hari Terputus!', style: TextStyle(fontWeight: FontWeight.bold, color: AppTheme.txt)),
                            Text('Pulihkan pakai $restoreStreakCost XP', style: TextStyle(fontSize: 12, color: AppTheme.txtGrey)),
                          ],
                        ),
                      ),
                      IconButton(onPressed: _restoreStreak, icon: const Icon(Icons.restore, color: Colors.orange)),
                    ],
                  ),
                ),
                const SizedBox(height: 24),
              ],

              // BENTO GRID
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    flex: 1,
                    child: GestureDetector(
                      onTap: () => BottomNav.navNotifier.value = 1,
                      child: Container(
                        height: 180,
                        padding: const EdgeInsets.all(20),
                        decoration: BoxDecoration(color: AppTheme.primary, borderRadius: BorderRadius.circular(28)),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Icon(Icons.play_circle_fill, color: Colors.white, size: 36),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text('Mulai\nFokus', style: TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold, height: 1.2)),
                                const SizedBox(height: 8),
                                Text('$pomodoros Sesi', style: const TextStyle(color: Colors.white70, fontSize: 12)),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    flex: 1,
                    child: Column(
                      children: [
                        Container(
                          height: 82,
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(color: AppTheme.card, borderRadius: BorderRadius.circular(24), border: Border.all(color: AppTheme.border, width: 1.5)),
                          child: Row(
                            children: [
                              const Icon(Icons.star, color: Colors.amber, size: 28),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text('$xp', style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: AppTheme.txt, height: 1)),
                                    Text('XP', style: TextStyle(fontSize: 11, color: AppTheme.txtGrey)),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 16),
                        Container(
                          height: 82,
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(color: AppTheme.card, borderRadius: BorderRadius.circular(24), border: Border.all(color: AppTheme.border, width: 1.5)),
                          child: Row(
                            children: [
                              const Icon(Icons.local_fire_department, color: Colors.redAccent, size: 28),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text('$streak', style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: AppTheme.txt, height: 1)),
                                    Text('Streak', style: TextStyle(fontSize: 11, color: AppTheme.txtGrey)),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 32),

              // AI RECOMMENDATION
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text("Saran Fokus AI", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppTheme.txt)),
                  IconButton(
                    onPressed: _nextAiSuggestion,
                    icon: Icon(Icons.refresh, color: AppTheme.txtGrey, size: 20),
                    tooltip: 'Ganti Saran',
                  ),
                ],
              ),
              const SizedBox(height: 12),
              GestureDetector(
                onTap: () => BottomNav.navNotifier.value = 1,
                child: Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: AppTheme.primary.withValues(alpha: 0.05),
                    borderRadius: BorderRadius.circular(24),
                    border: Border.all(color: AppTheme.primary.withValues(alpha: 0.2), width: 1.5),
                  ),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(color: AppTheme.primary.withValues(alpha: 0.15), shape: BoxShape.circle),
                        child: Icon(Icons.auto_awesome, color: AppTheme.primary, size: 24), // Hapus const
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                                  decoration: BoxDecoration(color: AppTheme.primary, borderRadius: BorderRadius.circular(8)),
                                  child: Text(currentAi['tag'], style: const TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold)),
                                ),
                                const Spacer(),
                                Icon(Icons.arrow_forward, size: 16, color: AppTheme.primary), // Hapus const
                              ],
                            ),
                            const SizedBox(height: 10),
                            Text(currentAi['title'], style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: AppTheme.txt)),
                            const SizedBox(height: 6),
                            Text(currentAi['desc'], style: TextStyle(fontSize: 13, height: 1.4, color: AppTheme.txtGrey)),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 32),

              // MUSIK
              Text("Soundscape", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppTheme.txt)),
              const SizedBox(height: 12),
              const MusicCard(),

              const SizedBox(height: 32),

              // CHALLENGE
              Text("Tantangan", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppTheme.txt)),
              const SizedBox(height: 12),
              InkWell(
                onTap: () => BottomNav.navNotifier.value = 3,
                borderRadius: BorderRadius.circular(16),
                child: Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(color: AppTheme.card, borderRadius: BorderRadius.circular(20), border: Border.all(color: AppTheme.border, width: 1.5)),
                  child: Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(color: AppTheme.accent.withValues(alpha: 0.15), shape: BoxShape.circle),
                        child: Icon(Icons.emoji_events, color: AppTheme.accent), // Hapus const
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('Selesaikan 3 Pomodoro', style: TextStyle(fontWeight: FontWeight.bold, color: AppTheme.txt, fontSize: 14)),
                            const SizedBox(height: 4),
                            Text('Hadiah: +50 XP', style: TextStyle(color: AppTheme.txtGrey, fontSize: 12)),
                          ],
                        ),
                      ),
                      Text('2/3', style: TextStyle(fontWeight: FontWeight.bold, color: AppTheme.primary, fontSize: 16)),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}