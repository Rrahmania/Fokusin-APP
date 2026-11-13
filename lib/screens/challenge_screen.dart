import 'package:flutter/material.dart';
import '../theme/app_theme.dart';
import '../services/challenge_service.dart';

class ChallengeScreen extends StatefulWidget {
  const ChallengeScreen({super.key});

  @override
  State<ChallengeScreen> createState() => _ChallengeScreenState();
}

class _ChallengeScreenState extends State<ChallengeScreen> {
  int userXp = 0;
  List<String> completedIds = [];
  Map<String, Map<String, dynamic>> progressMap = {};
  bool loading = true;

  @override
  void initState() {
    super.initState();
    _refresh();
    AppTheme.themeNotifier.addListener(_onThemeChanged);
  }

  @override
  void dispose() {
    AppTheme.themeNotifier.removeListener(_onThemeChanged);
    super.dispose();
  }

  void _onThemeChanged() {
    if (mounted) setState(() {});
  }

  Future<void> _refresh() async {
    setState(() => loading = true);
    final result = await ChallengeService.evaluate();
    final progress = await ChallengeService.getProgressMap();
    if (!mounted) return;
    setState(() {
      userXp = result.totalXp;
      completedIds = result.completedIds;
      progressMap = progress;
      loading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.bg,
      body: SafeArea(
        child: RefreshIndicator(
          onRefresh: _refresh,
          color: AppTheme.primary,
          backgroundColor: AppTheme.card,
          child: SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            padding: const EdgeInsets.all(24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(child: Text('Challenges', style: TextStyle(fontSize: 26, fontWeight: FontWeight.bold, color: AppTheme.txt))),
                    IconButton(onPressed: _refresh, icon: Icon(Icons.refresh, color: AppTheme.txt)),
                  ],
                ),
                const SizedBox(height: 6),
                Text('Progress otomatis dari aktivitas fokusmu.', style: TextStyle(color: AppTheme.txtGrey)),
                const SizedBox(height: 24),
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(color: AppTheme.primary, borderRadius: BorderRadius.circular(28)),
                  child: Row(
                    children: [
                      Container(
                        width: 55,
                        height: 55,
                        decoration: BoxDecoration(color: Colors.white24, borderRadius: BorderRadius.circular(15)),
                        child: const Icon(Icons.star, color: Colors.white, size: 30),
                      ),
                      const SizedBox(width: 16),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text('Your XP', style: TextStyle(color: Colors.white70)),
                          const SizedBox(height: 4),
                          Text('$userXp XP', style: const TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold)),
                        ],
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 32),
                Text('Available Challenges', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppTheme.txt)),
                const SizedBox(height: 16),
                if (loading)
                  const Center(child: CircularProgressIndicator())
                else
                  ...challengeList.map((challenge) {
                    final progress = progressMap[challenge.id];
                    final current = progress?['current'] ?? 0;
                    final target = progress?['target'] ?? 1;
                    final ratio = (current / target).clamp(0.0, 1.0);
                    final completed = completedIds.contains(challenge.id);

                    return Container(
                      margin: const EdgeInsets.only(bottom: 16),
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color: AppTheme.card,
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(color: completed ? Colors.green.withValues(alpha: 0.5) : AppTheme.border, width: 1.5),
                      ),
                      child: Column(
                        children: [
                          Row(
                            children: [
                              Container(
                                width: 50,
                                height: 50,
                                decoration: BoxDecoration(
                                  color: completed ? Colors.green.withValues(alpha: 0.15) : AppTheme.lightTeal,
                                  borderRadius: BorderRadius.circular(14),
                                ),
                                child: Icon(completed ? Icons.check_circle : Icons.emoji_events, color: completed ? Colors.green : AppTheme.primary), // Hapus const
                              ),
                              const SizedBox(width: 16),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(challenge.title, style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: AppTheme.txt)),
                                    const SizedBox(height: 4),
                                    Text(challenge.description, style: TextStyle(color: AppTheme.txtGrey, fontSize: 12)),
                                  ],
                                ),
                              ),
                              Text('+${challenge.reward} XP', style: TextStyle(color: AppTheme.primary, fontWeight: FontWeight.bold, fontSize: 13)), // Hapus const
                            ],
                          ),
                          const SizedBox(height: 16),
                          Row(
                            children: [
                              Expanded(
                                child: ClipRRect(
                                  borderRadius: BorderRadius.circular(10),
                                  child: LinearProgressIndicator(
                                    value: ratio,
                                    minHeight: 8,
                                    backgroundColor: AppTheme.border,
                                    color: completed ? Colors.green : AppTheme.primary,
                                  ),
                                ),
                              ),
                              const SizedBox(width: 12),
                              Text('$current/$target', style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: AppTheme.txt)),
                            ],
                          ),
                          const SizedBox(height: 12),
                          if (completed)
                            const Row(
                              children: [
                                Icon(Icons.verified, color: Colors.green, size: 18),
                                SizedBox(width: 8),
                                Text('Selesai otomatis oleh sistem ✓', style: TextStyle(color: Colors.green, fontWeight: FontWeight.bold, fontSize: 12)),
                              ],
                            )
                          else
                            Row(
                              children: [
                                Icon(Icons.lock_clock, size: 16, color: AppTheme.txtGrey), // Hapus const
                                const SizedBox(width: 8),
                                Text('Selesaikan aktivitas untuk membuka', style: TextStyle(color: AppTheme.txtGrey, fontSize: 12)),
                              ],
                            ),
                        ],
                      ),
                    );
                  }),
              ],
            ),
          ),
        ),
      ),
    );
  }
}