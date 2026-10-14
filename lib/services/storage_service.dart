import 'package:shared_preferences/shared_preferences.dart';

class StorageService {
  // TIMER
  static const String _keyCustomMinutes = 'custom_minutes';
  static const String _keyCustomSeconds = 'custom_seconds';
  static const String _keyLockApp = 'lock_app_when_timer';

  // MULTIPLE CUSTOM PRESETS
  static const String _keyCustomPresets = 'custom_presets';

  // THEME
  static const String _keyIsDark = 'isDarkMode';

  // XP & CHALLENGES
  static const String _keyXp = 'user_xp';
  static const String _keyCompletedChallenges = 'completed_challenges';

  // STATS
  static const String _keyTotalPomodoro = 'total_pomodoro';
  static const String _keyTodayPomodoro = 'today_pomodoro';
  static const String _keyLastDate = 'last_pomodoro_date';
  static const String _keyStreak = 'user_streak';
  static const String _keyEarlyBirdDone = 'early_bird_done';

  // STREAK BROKEN
  static const String _keyStreakBroken = 'streak_broken';
  static const String _keyLastStreakValue = 'last_streak_value';

  // STATS HISTORY
  static const String _keyPomodoroHistory = 'pomodoro_history';

  // MUSIC
  static const String _keySelectedMusic = 'selected_music';

  // USER AUTH
  static const String _keyRegisteredUsers = 'registered_users';
  static const String _keyCurrentUserName = 'current_user_name';
  static const String _keyCurrentUserEmail = 'current_user_email';

  // WHAT YOUR TARGET
  static const String _keyTargets = 'user_targets';
  static const String _keyActiveTargetIndex = 'active_target_index';

  // SHOP (FRAME)
  static const String _keyOwnedFrames = 'owned_frames';
  static const String _keyEquippedFrame = 'equipped_frame';

  // ============================================================
  // REGISTER
  // ============================================================
  static Future<bool> registerUser({
    required String name,
    required String email,
    required String password,
  }) async {
    final prefs = await SharedPreferences.getInstance();
    final list = prefs.getStringList(_keyRegisteredUsers) ?? [];

    for (final u in list) {
      final parts = u.split('|');
      if (parts.length >= 2 &&
          parts[1].toLowerCase() == email.toLowerCase()) {
        return false;
      }
    }

    list.add('$name|$email|$password');
    await prefs.setStringList(_keyRegisteredUsers, list);
    return true;
  }

  // ============================================================
  // LOGIN
  // ============================================================
  static Future<String?> loginUser({
    required String email,
    required String password,
  }) async {
    final prefs = await SharedPreferences.getInstance();
    final list = prefs.getStringList(_keyRegisteredUsers) ?? [];

    for (final u in list) {
      final parts = u.split('|');
      if (parts.length < 3) continue;
      final name = parts[0];
      final userEmail = parts[1];
      final userPass = parts[2];

      if (userEmail.toLowerCase() == email.toLowerCase() &&
          userPass == password) {
        await prefs.setString(_keyCurrentUserName, name);
        await prefs.setString(_keyCurrentUserEmail, userEmail);
        return name;
      }
    }
    return null;
  }

  static Future<bool> isEmailRegistered(String email) async {
    final prefs = await SharedPreferences.getInstance();
    final list = prefs.getStringList(_keyRegisteredUsers) ?? [];
    for (final u in list) {
      final parts = u.split('|');
      if (parts.length >= 2 &&
          parts[1].toLowerCase() == email.toLowerCase()) {
        return true;
      }
    }
    return false;
  }

  // ============================================================
  // CURRENT USER
  // ============================================================
  static Future<void> setCurrentUser({
    required String name,
    required String email,
  }) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_keyCurrentUserName, name);
    await prefs.setString(_keyCurrentUserEmail, email);
  }

  static Future<String> getCurrentUserName() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_keyCurrentUserName) ?? 'User';
  }

  static Future<String> getCurrentUserEmail() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_keyCurrentUserEmail) ?? '-';
  }

  static Future<void> updateCurrentUserName(String newName) async {
    final prefs = await SharedPreferences.getInstance();
    final oldName = prefs.getString(_keyCurrentUserName);
    final email = prefs.getString(_keyCurrentUserEmail) ?? '';

    if (oldName != null && email.isNotEmpty) {
      final list = prefs.getStringList(_keyRegisteredUsers) ?? [];
      for (int i = 0; i < list.length; i++) {
        final parts = list[i].split('|');
        if (parts.length >= 3 &&
            parts[1].toLowerCase() == email.toLowerCase()) {
          list[i] = '$newName|${parts[1]}|${parts[2]}';
          break;
        }
      }
      await prefs.setStringList(_keyRegisteredUsers, list);
    }
    await prefs.setString(_keyCurrentUserName, newName);
  }

  static Future<void> updateCurrentUserEmail(String newEmail) async {
    final prefs = await SharedPreferences.getInstance();
    final name = prefs.getString(_keyCurrentUserName) ?? '';
    final oldEmail = prefs.getString(_keyCurrentUserEmail) ?? '';

    if (name.isNotEmpty && oldEmail.isNotEmpty) {
      final list = prefs.getStringList(_keyRegisteredUsers) ?? [];
      for (int i = 0; i < list.length; i++) {
        final parts = list[i].split('|');
        if (parts.length >= 3 &&
            parts[1].toLowerCase() == oldEmail.toLowerCase()) {
          list[i] = '${parts[0]}|$newEmail|${parts[2]}';
          break;
        }
      }
      await prefs.setStringList(_keyRegisteredUsers, list);
    }
    await prefs.setString(_keyCurrentUserEmail, newEmail);
  }

  static Future<void> logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_keyCurrentUserName);
    await prefs.remove(_keyCurrentUserEmail);
  }

  static Future<void> clearAll() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.clear();
  }

  // ============================================================
  // TIMER
  // ============================================================
  static Future<void> saveCustomTimer(int minutes, int seconds) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(_keyCustomMinutes, minutes);
    await prefs.setInt(_keyCustomSeconds, seconds);
  }

  static Future<Map<String, int>> loadCustomTimer() async {
    final prefs = await SharedPreferences.getInstance();
    return {
      'minutes': prefs.getInt(_keyCustomMinutes) ?? 25,
      'seconds': prefs.getInt(_keyCustomSeconds) ?? 0,
    };
  }

  // ============================================================
  // CUSTOM TIMER PRESETS
  // ============================================================
  static Future<List<Map<String, dynamic>>> loadCustomPresets() async {
    final prefs = await SharedPreferences.getInstance();
    final list = prefs.getStringList(_keyCustomPresets) ?? [];
    final result = <Map<String, dynamic>>[];
    for (final item in list) {
      final parts = item.split('|');
      if (parts.length >= 2) {
        result.add({
          'minutes': int.tryParse(parts[0]) ?? 0,
          'seconds': int.tryParse(parts[1]) ?? 0,
          'label': parts.length >= 3 ? parts[2] : '',
        });
      }
    }
    return result;
  }

  static Future<void> saveCustomPreset({
    required int minutes,
    required int seconds,
    String label = '',
  }) async {
    final prefs = await SharedPreferences.getInstance();
    final list = prefs.getStringList(_keyCustomPresets) ?? [];

    final key = '$minutes|$seconds';
    for (final item in list) {
      final parts = item.split('|');
      if (parts.length >= 2 && '${parts[0]}|${parts[1]}' == key) {
        return;
      }
    }

    list.add('$minutes|$seconds|$label');
    await prefs.setStringList(_keyCustomPresets, list);
  }

  static Future<void> deleteCustomPreset(int minutes, int seconds) async {
    final prefs = await SharedPreferences.getInstance();
    final list = prefs.getStringList(_keyCustomPresets) ?? [];
    list.removeWhere((item) {
      final parts = item.split('|');
      if (parts.length < 2) return false;
      return int.tryParse(parts[0]) == minutes &&
          int.tryParse(parts[1]) == seconds;
    });
    await prefs.setStringList(_keyCustomPresets, list);
  }

  // ============================================================
  // WHAT YOUR TARGET
  // ============================================================
  static Future<List<Map<String, dynamic>>> loadTargets() async {
    final prefs = await SharedPreferences.getInstance();
    final list = prefs.getStringList(_keyTargets) ?? [];
    final result = <Map<String, dynamic>>[];
    for (final item in list) {
      final parts = item.split('|');
      if (parts.length >= 2) {
        result.add({
          'name': parts[0],
          'icon': int.tryParse(parts[1]) ?? 0xe318,
        });
      }
    }
    return result;
  }

  static Future<void> saveTargets(List<Map<String, dynamic>> targets) async {
    final prefs = await SharedPreferences.getInstance();
    final list = targets.map((t) => '${t['name']}|${t['icon']}').toList();
    await prefs.setStringList(_keyTargets, list);
  }

  static Future<int> loadActiveTargetIndex() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getInt(_keyActiveTargetIndex) ?? 0;
  }

  static Future<void> saveActiveTargetIndex(int index) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(_keyActiveTargetIndex, index);
  }

  // ============================================================
  // LOCK APP
  // ============================================================
  static Future<void> saveLockApp(bool value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_keyLockApp, value);
  }

  static Future<bool> loadLockApp() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_keyLockApp) ?? false;
  }

  // ============================================================
  // XP (SAFE-CAST)
  // ============================================================
  static Future<void> saveXp(int xp) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(_keyXp, xp);
  }

  static Future<int> loadXp() async {
    final prefs = await SharedPreferences.getInstance();
    final value = prefs.get(_keyXp);
    if (value is int) return value;
    return 0;
  }

  // ============================================================
  // CHALLENGES
  // ============================================================
  static Future<void> saveCompletedChallenges(List<String> ids) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setStringList(_keyCompletedChallenges, ids);
  }

  static Future<List<String>> loadCompletedChallenges() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getStringList(_keyCompletedChallenges) ?? [];
  }

  // ============================================================
  // MUSIC
  // ============================================================
  static Future<void> saveSelectedMusic(String music) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_keySelectedMusic, music);
  }

  static Future<String> loadSelectedMusic() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_keySelectedMusic) ?? 'Rain Sounds';
  }

  // ============================================================
  // STATS
  // ============================================================
  static Future<int> loadTotalPomodoro() async {
    final prefs = await SharedPreferences.getInstance();
    final value = prefs.get(_keyTotalPomodoro);
    if (value is int) return value;
    return 0;
  }

  static Future<int> loadTodayPomodoro() async {
    final prefs = await SharedPreferences.getInstance();
    final today = _todayStr();
    final lastDate = prefs.getString(_keyLastDate) ?? '';
    if (lastDate != today) return 0;
    final value = prefs.get(_keyTodayPomodoro);
    if (value is int) return value;
    return 0;
  }

  static Future<int> loadStreak() async {
    final prefs = await SharedPreferences.getInstance();
    final value = prefs.get(_keyStreak);
    if (value is int) return value;
    return 0;
  }

  static Future<void> saveStreak(int value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(_keyStreak, value);
  }

  // 👇 FUNGSI INI YANG TADI HILANG
  static Future<bool> loadEarlyBirdDone() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_keyEarlyBirdDone) ?? false;
  }

  // ============================================================
  // STREAK BROKEN (LOGIKA BARU)
  // ============================================================

  /// Dipanggil saat user buka app.
  /// Kalau ternyata user bolong sehari (kemarin nggak fokus),
  /// streak di-reset jadi 0 dan status "broken" diaktifkan.
  static Future<void> checkStreakStatus() async {
    final prefs = await SharedPreferences.getInstance();
    final today = _todayStr();
    final lastDate = prefs.getString(_keyLastDate) ?? '';

    // Belum pernah fokus sama sekali
    if (lastDate.isEmpty) return;

    // Sudah broken dari sebelumnya, nggak perlu cek lagi
    final alreadyBroken = prefs.getBool(_keyStreakBroken) ?? false;
    if (alreadyBroken) return;

    // Kalau hari ini atau kemarin, streak masih aman
    if (lastDate == today || _isYesterday(lastDate)) return;

    // BOLONG! Streak putus.
    final currentStreak = prefs.getInt(_keyStreak) ?? 0;
    if (currentStreak > 0) {
      await prefs.setInt(_keyLastStreakValue, currentStreak);
      await prefs.setInt(_keyStreak, 0);
      await prefs.setBool(_keyStreakBroken, true);
    }
  }

  /// Cek apakah streak sedang dalam kondisi putus
  static Future<bool> isStreakBroken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_keyStreakBroken) ?? false;
  }

  /// Nilai streak sebelum putus (untuk dipulihkan)
  static Future<int> loadLastStreakValue() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getInt(_keyLastStreakValue) ?? 0;
  }

  /// Pulihkan streak pakai XP
  static Future<void> restoreStreak() async {
    final prefs = await SharedPreferences.getInstance();
    final lastValue = prefs.getInt(_keyLastStreakValue) ?? 0;
    await prefs.setInt(_keyStreak, lastValue);
    await prefs.setBool(_keyStreakBroken, false);
    // Set lastDate jadi hari ini biar fokus berikutnya gak "reset lagi"
    await prefs.setString(_keyLastDate, _todayStr());
  }

  // ============================================================
  // POMODORO HISTORY
  // ============================================================
  static Future<Map<String, int>> loadPomodoroHistory() async {
    final prefs = await SharedPreferences.getInstance();
    final list = prefs.getStringList(_keyPomodoroHistory) ?? [];
    final result = <String, int>{};
    for (final item in list) {
      final parts = item.split('|');
      if (parts.length == 2) {
        result[parts[0]] = int.tryParse(parts[1]) ?? 0;
      }
    }
    return result;
  }

  static Future<void> _savePomodoroHistory(Map<String, int> history) async {
    final prefs = await SharedPreferences.getInstance();
    final list = history.entries.map((e) => '${e.key}|${e.value}').toList();
    await prefs.setStringList(_keyPomodoroHistory, list);
  }

  static Future<void> recordPomodoroCompleted() async {
    final prefs = await SharedPreferences.getInstance();
    final today = _todayStr();
    final lastDate = prefs.getString(_keyLastDate) ?? '';
    final broken = prefs.getBool(_keyStreakBroken) ?? false;

    // Tambah total pomodoro
    final total = (prefs.getInt(_keyTotalPomodoro) ?? 0) + 1;
    await prefs.setInt(_keyTotalPomodoro, total);

    int todayCount;
    int streak = prefs.getInt(_keyStreak) ?? 0;

    if (lastDate == today) {
      // Masih hari yang sama, tinggal tambah counter harian
      todayCount = (prefs.getInt(_keyTodayPomodoro) ?? 0) + 1;
    } else {
      // Hari baru! Ini pomodoro pertama hari ini
      todayCount = 1;

      if (broken) {
        // User nggak restore, mulai fresh dari 1
        streak = 1;
        await prefs.setBool(_keyStreakBroken, false);
      } else if (lastDate.isEmpty) {
        // Pertama kali pakai app
        streak = 1;
      } else if (_isYesterday(lastDate)) {
        // Lanjut streak
        streak += 1;
      } else {
        // Bolong tapi belum di-mark sebagai broken
        if (streak > 0) {
          await prefs.setInt(_keyLastStreakValue, streak);
        }
        streak = 1;
      }
    }

    await prefs.setString(_keyLastDate, today);
    await prefs.setInt(_keyStreak, streak);
    await prefs.setInt(_keyTodayPomodoro, todayCount);

    // Simpan ke history
    final history = await loadPomodoroHistory();
    history[today] = todayCount;
    await _savePomodoroHistory(history);

    // Early bird
    final now = DateTime.now();
    if (now.hour < 10) {
      await prefs.setBool(_keyEarlyBirdDone, true);
    }
  }

  // ============================================================
  // SHOP (FRAME)
  // ============================================================
  static Future<List<String>> loadOwnedFrames() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getStringList(_keyOwnedFrames) ?? ['default'];
  }

  static Future<void> saveOwnedFrames(List<String> ids) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setStringList(_keyOwnedFrames, ids);
  }

  static Future<String> loadEquippedFrame() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_keyEquippedFrame) ?? 'default';
  }

  static Future<void> saveEquippedFrame(String id) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_keyEquippedFrame, id);
  }

  // ============================================================
  // HELPER
  // ============================================================
  static String _todayStr() {
    final now = DateTime.now();
    return '${now.year}-${now.month}-${now.day}';
  }

  static bool _isYesterday(String dateStr) {
    if (dateStr.isEmpty) return false;
    final parts = dateStr.split('-').map(int.parse).toList();
    final date = DateTime(parts[0], parts[1], parts[2]);
    final yesterday = DateTime.now().subtract(const Duration(days: 1));
    return date.year == yesterday.year &&
        date.month == yesterday.month &&
        date.day == yesterday.day;
  }
}