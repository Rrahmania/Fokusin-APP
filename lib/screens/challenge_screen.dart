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
          color: AppTheme.primaryTeal,
          backgroundColor: AppTheme.card,
          child: SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        'Challenges',
                        style: TextStyle(
                          fontSize: 27,
                          fontWeight: FontWeight.bold,
                          color: AppTheme.primaryTeal,
                        ),
                      ),
                    ),
                    IconButton(
                      onPressed: _refresh,
                      icon: Icon(Icons.refresh, color: AppTheme.txt),
                    ),
                  ],
                ),
                const SizedBox(height: 6),
                Text(
                  'Progress otomatis dari aktivitas fokusmu.',
                  style: TextStyle(color: AppTheme.txtGrey),
                ),
                const SizedBox(height: 25),
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [AppTheme.primaryTeal, AppTheme.darkTeal],
                    ),
                    borderRadius: BorderRadius.circular(22),
                  ),
                  child: Row(
                    children: [
                      Container(
                        width: 55,
                        height: 55,
                        decoration: BoxDecoration(
                          color: Colors.white24,
                          borderRadius: BorderRadius.circular(15),
                        ),
                        child: const Icon(Icons.star,
                            color: Colors.white, size: 30),
                      ),
                      const SizedBox(width: 15),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text('Your XP',
                              style: TextStyle(color: Colors.white70)),
                          const SizedBox(height: 3),
                          Text(
                            '$userXp XP',
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 25),
                Text('Available Challenges',
                    style: TextStyle(
                        fontSize: 19,
                        fontWeight: FontWeight.bold,
                        color: AppTheme.txt)),
                const SizedBox(height: 12),
                if (loading)
                  const Center(child: CircularProgressIndicator())
                else
                  ...challengeList.map((challenge) {
                    final progress = progressMap[challenge.id];
                    final current = progress?['current'] ?? 0;
                    final target = progress?['target'] ?? 1;
                    final ratio = (current / target).clamp(0.0, 1.0);
                    final completed =
                    completedIds.contains(challenge.id);

                    return Container(
                      margin: const EdgeInsets.only(bottom: 14),
                      padding: const EdgeInsets.all(17),
                      decoration: BoxDecoration(
                        color: AppTheme.card,
                        borderRadius: BorderRadius.circular(20),
                        border: completed
                            ? Border.all(
                            color: Colors.green.withOpacity(0.4),
                            width: 1.5)
                            : null,
                      ),
                      child: Column(
                        children: [
                          Row(
                            children: [
                              Container(
                                width: 50,
                                height: 50,
                                decoration: BoxDecoration(
                                  color: completed
                                      ? Colors.green.withOpacity(0.15)
                                      : AppTheme.lightTeal,
                                  borderRadius: BorderRadius.circular(14),
                                ),
                                child: Icon(
                                  completed
                                      ? Icons.check_circle
                                      : Icons.emoji_events,
                                  color: completed
                                      ? Colors.green
                                      : AppTheme.darkTeal,
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment:
                                  CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      challenge.title,
                                      style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                        fontSize: 15,
                                        color: AppTheme.txt,
                                      ),
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      challenge.description,
                                      style: TextStyle(
                                        color: AppTheme.txtGrey,
                                        fontSize: 12,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              Text(
                                '+${challenge.reward} XP',
                                style: const TextStyle(
                                  color: AppTheme.primaryTeal,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 12,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 12),
                          Row(
                            children: [
                              Expanded(
                                child: ClipRRect(
                                  borderRadius: BorderRadius.circular(10),
                                  child: LinearProgressIndicator(
                                    value: ratio,
                                    minHeight: 8,
                                    backgroundColor: AppTheme.lightTeal,
                                    color: completed
                                        ? Colors.green
                                        : AppTheme.primaryTeal,
                                  ),
                                ),
                              ),
                              const SizedBox(width: 10),
                              Text(
                                '$current/$target',
                                style: TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.bold,
                                  color: AppTheme.txt,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 10),
                          if (completed)
                            const Row(
                              children: [
                                Icon(Icons.verified,
                                    color: Colors.green, size: 18),
                                SizedBox(width: 6),
                                Text(
                                  'Selesai otomatis oleh sistem ✓',
                                  style: TextStyle(
                                    color: Colors.green,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 12,
                                  ),
                                ),
                              ],
                            )
                          else
                            Row(
                              children: [
                                Icon(Icons.lock_clock,
                                    size: 16, color: AppTheme.txtGrey),
                                const SizedBox(width: 6),
                                Text(
                                  'Selesaikan aktivitas untuk membuka',
                                  style: TextStyle(
                                    color: AppTheme.txtGrey,
                                    fontSize: 12,
                                  ),
                                ),
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