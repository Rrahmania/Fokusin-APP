import 'package:flutter/material.dart';
import '../theme/app_theme.dart';
import '../services/storage_service.dart';
import '../services/challenge_service.dart';
import '../widgets/music_card.dart';
import '../widgets/bottom_nav.dart';
import '../widgets/ai_recommendation.dart';

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

  String challengeTitle = 'Selesaikan 3 Pomodoro';
  int challengeReward = 50;
  int challengeCurrent = 0;
  int challengeTarget = 3;
  bool challengeCompleted = false;

  @override
  void initState() {
    super.initState();
    _loadUser();
    BottomNav.navNotifier.addListener(_onTabChanged);
  }

  @override
  void dispose() {
    BottomNav.navNotifier.removeListener(_onTabChanged);
    super.dispose();
  }

  void _onTabChanged() {
    if (BottomNav.navNotifier.value == 0) {
      _loadUser();
    }
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

      final progressMap = await ChallengeService.getProgressMap();
      final challengeResult = await ChallengeService.evaluate();
      final completedIds = challengeResult.completedIds;

      final activeChallenge = challengeList.firstWhere(
            (c) => !completedIds.contains(c.id),
        orElse: () => challengeList.first,
      );

      final progress = progressMap[activeChallenge.id];
      final current = progress?['current'] ?? 0;
      final target = progress?['target'] ?? 1;
      final isCompleted = completedIds.contains(activeChallenge.id);

      if (!mounted) return;
      setState(() {
        userName = name;
        userInitial = name.isNotEmpty ? name[0].toUpperCase() : 'U';
        pomodoros = total;
        streak = s;
        xp = userXp;
        streakBroken = broken;
        lastStreakValue = lastVal;

        challengeTitle = activeChallenge.description;
        challengeReward = activeChallenge.reward;
        challengeCurrent = current;
        challengeTarget = target;
        challengeCompleted = isCompleted;
      });
    } catch (err) {
      debugPrint("ERROR HOME: $err");
    }
  }

  void _goToProfile() => BottomNav.navNotifier.value = 4;

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
    return Scaffold(
      backgroundColor: AppTheme.bg,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(24, 32, 24, 40),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
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
                      decoration: BoxDecoration(color: AppTheme.primary, shape: BoxShape.circle),
                      child: Center(child: Text(userInitial, style: const TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold))),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 32),

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

              const AiRecommendation(),
              const SizedBox(height: 32),

              Text("Soundscape", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppTheme.txt)),
              const SizedBox(height: 12),
              const MusicCard(),

              const SizedBox(height: 32),

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
                        decoration: BoxDecoration(
                          color: challengeCompleted ? Colors.green.withValues(alpha: 0.15) : AppTheme.accent.withValues(alpha: 0.15),
                          shape: BoxShape.circle,
                        ),
                        child: Icon(
                          challengeCompleted ? Icons.check_circle : Icons.emoji_events,
                          color: challengeCompleted ? Colors.green : AppTheme.accent,
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              challengeTitle,
                              style: TextStyle(fontWeight: FontWeight.bold, color: AppTheme.txt, fontSize: 14),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                            const SizedBox(height: 4),
                            Text('Hadiah: +$challengeReward XP', style: TextStyle(color: AppTheme.txtGrey, fontSize: 12)),
                          ],
                        ),
                      ),
                      Text(
                        challengeCompleted ? 'Selesai' : '$challengeCurrent/$challengeTarget',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: challengeCompleted ? Colors.green : (challengeCurrent == 0 ? AppTheme.txtGrey : AppTheme.primary),
                          fontSize: 16,
                        ),
                      ),
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