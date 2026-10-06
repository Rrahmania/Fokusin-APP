import 'storage_service.dart';

class ChallengeDefinition {
  final String id;
  final String title;
  final String description;
  final int reward;

  const ChallengeDefinition({
    required this.id,
    required this.title,
    required this.description,
    required this.reward,
  });
}

/// Semua definisi challenge — sistem yang mengecek, bukan user.
const List<ChallengeDefinition> challengeList = [
  ChallengeDefinition(
    id: 'pomodoro_starter',
    title: 'Pomodoro Starter',
    description: 'Selesaikan 3 sesi Pomodoro.',
    reward: 50,
  ),
  ChallengeDefinition(
    id: 'focus_master',
    title: 'Focus Master',
    description: 'Selesaikan total 5 sesi Pomodoro.',
    reward: 100,
  ),
  ChallengeDefinition(
    id: 'early_bird',
    title: 'Early Bird',
    description: 'Selesaikan 1 Pomodoro sebelum jam 10 pagi.',
    reward: 75,
  ),
  ChallengeDefinition(
    id: 'consistency',
    title: 'Consistency',
    description: 'Jaga streak fokus selama 7 hari.',
    reward: 200,
  ),
  ChallengeDefinition(
    id: 'marathon',
    title: 'Focus Marathon',
    description: 'Selesaikan 10 Pomodoro dalam 1 hari.',
    reward: 300,
  ),
];

class ChallengeService {
  /// Cek semua challenge berdasarkan statistik user.
  /// Return list of challenge yang baru selesai (dan XP yang didapat).
  static Future<ChallengeResult> evaluate() async {
    final total = await StorageService.loadTotalPomodoro();
    final today = await StorageService.loadTodayPomodoro();
    final streak = await StorageService.loadStreak();
    final earlyBird = await StorageService.loadEarlyBirdDone();

    final completedIds = await StorageService.loadCompletedChallenges();
    int currentXp = await StorageService.loadXp();

    final newlyCompleted = <ChallengeDefinition>[];
    int xpGained = 0;

    // Helper untuk cek & tandai
    Future<void> check(ChallengeDefinition def, bool condition) async {
      if (condition && !completedIds.contains(def.id)) {
        completedIds.add(def.id);
        xpGained += def.reward;
        newlyCompleted.add(def);
      }
    }

    // Cek satu per satu
    for (final def in challengeList) {
      switch (def.id) {
        case 'pomodoro_starter':
          await check(def, total >= 3);
          break;
        case 'focus_master':
          await check(def, total >= 5);
          break;
        case 'early_bird':
          await check(def, earlyBird);
          break;
        case 'consistency':
          await check(def, streak >= 7);
          break;
        case 'marathon':
          await check(def, today >= 10);
          break;
      }
    }

    if (xpGained > 0) {
      currentXp += xpGained;
      await StorageService.saveXp(currentXp);
      await StorageService.saveCompletedChallenges(completedIds);
    }

    return ChallengeResult(
      completedIds: completedIds,
      newlyCompleted: newlyCompleted,
      totalXp: currentXp,
      xpGained: xpGained,
    );
  }

  /// Data untuk menampilkan progress tiap challenge (read-only).
  static Future<Map<String, Map<String, dynamic>>> getProgressMap() async {
    final total = await StorageService.loadTotalPomodoro();
    final today = await StorageService.loadTodayPomodoro();
    final streak = await StorageService.loadStreak();
    final earlyBird = await StorageService.loadEarlyBirdDone();

    return {
      'pomodoro_starter': {
        'current': total > 3 ? 3 : total,
        'target': 3,
      },
      'focus_master': {
        'current': total > 5 ? 5 : total,
        'target': 5,
      },
      'early_bird': {
        'current': earlyBird ? 1 : 0,
        'target': 1,
      },
      'consistency': {
        'current': streak > 7 ? 7 : streak,
        'target': 7,
      },
      'marathon': {
        'current': today > 10 ? 10 : today,
        'target': 10,
      },
    };
  }
}

class ChallengeResult {
  final List<String> completedIds;
  final List<ChallengeDefinition> newlyCompleted;
  final int totalXp;
  final int xpGained;

  ChallengeResult({
    required this.completedIds,
    required this.newlyCompleted,
    required this.totalXp,
    required this.xpGained,
  });
}