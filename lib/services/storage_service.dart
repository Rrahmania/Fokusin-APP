import 'package:shared_preferences/shared_preferences.dart';
import '../models/music_model.dart';

class StorageService {
  static const String _keyCustomMinutes = 'custom_minutes';
  static const String _keyCustomSeconds = 'custom_seconds';
  static const String _keyLockApp = 'lock_app_when_timer';
  static const String _keyCustomPresets = 'custom_presets';
  static const String _keyXp = 'user_xp';
  static const String _keyCompletedChallenges = 'completed_challenges';
  static const String _keyTotalPomodoro = 'total_pomodoro';
  static const String _keyTodayPomodoro = 'today_pomodoro';
  static const String _keyLastDate = 'last_pomodoro_date';
  static const String _keyStreak = 'user_streak';
  static const String _keyEarlyBirdDone = 'early_bird_done';
  static const String _keyStreakBroken = 'streak_broken';
  static const String _keyLastStreakValue = 'last_streak_value';
  static const String _keyPomodoroHistory = 'pomodoro_history';
  static const String _keySelectedMusic = 'selected_music';
  static const String _keyRegisteredUsers = 'registered_users';
  static const String _keyCurrentUserName = 'current_user_name';
  static const String _keyCurrentUserEmail = 'current_user_email';
  static const String _keyOwnedFrames = 'owned_frames';
  static const String _keyEquippedFrame = 'equipped_frame';
  static const String _keyOwnedThemes = 'owned_theme_colors';
  static const String _keyOwnedMusic = 'owned_music_tracks';

  static const String _keyStreakFreeze = 'streak_freeze_active';
  static const String _keyThemeColor = 'theme_color_index';
  static const String _keyApiKey = 'gemini_api_key';
  static const String _keyBlockedUsers = 'blocked_users';
  static const String _keyCustomMusicTracks = 'custom_music_tracks';

  static Future<void> ensureDefaultAdmin() async {
    final prefs = await SharedPreferences.getInstance();
    final list = prefs.getStringList(_keyRegisteredUsers) ?? [];
    bool hasAdmin = list.any((u) => u.split('|').length >= 2 && u.split('|')[1].toLowerCase() == 'admin@fokusin.app');
    if (!hasAdmin) {
      list.add('Admin Fokusin|admin@fokusin.app|admin123|admin');
      await prefs.setStringList(_keyRegisteredUsers, list);
    }
  }

  static Future<bool> isUserBlocked(String email) async {
    final prefs = await SharedPreferences.getInstance();
    final list = prefs.getStringList(_keyBlockedUsers) ?? [];
    return list.any((e) => e.toLowerCase() == email.toLowerCase());
  }

  static Future<void> blockUser(String email) async {
    final prefs = await SharedPreferences.getInstance();
    final list = prefs.getStringList(_keyBlockedUsers) ?? [];
    if (!list.any((e) => e.toLowerCase() == email.toLowerCase())) {
      list.add(email);
      await prefs.setStringList(_keyBlockedUsers, list);
    }
  }

  static Future<void> unblockUser(String email) async {
    final prefs = await SharedPreferences.getInstance();
    final list = prefs.getStringList(_keyBlockedUsers) ?? [];
    list.removeWhere((e) => e.toLowerCase() == email.toLowerCase());
    await prefs.setStringList(_keyBlockedUsers, list);
  }

  static Future<bool> registerUser({required String name, required String email, required String password}) async {
    await ensureDefaultAdmin();
    final prefs = await SharedPreferences.getInstance();
    final list = prefs.getStringList(_keyRegisteredUsers) ?? [];
    for (final u in list) {
      final parts = u.split('|');
      if (parts.length >= 2 && parts[1].toLowerCase() == email.toLowerCase()) return false;
    }
    list.add('$name|$email|$password');
    await prefs.setStringList(_keyRegisteredUsers, list);
    return true;
  }

  static Future<String?> loginUser({required String email, required String password}) async {
    await ensureDefaultAdmin();
    if (await isUserBlocked(email)) {
      return 'BLOCKED';
    }
    final prefs = await SharedPreferences.getInstance();
    final list = prefs.getStringList(_keyRegisteredUsers) ?? [];
    for (final u in list) {
      final parts = u.split('|');
      if (parts.length < 3) continue;
      if (parts[1].toLowerCase() == email.toLowerCase() && parts[2] == password) {
        await prefs.setString(_keyCurrentUserName, parts[0]);
        await prefs.setString(_keyCurrentUserEmail, parts[1]);
        return parts[0];
      }
    }
    return null;
  }

  static Future<bool> isAdmin() async {
    final email = await getCurrentUserEmail();
    if (email.toLowerCase() == 'admin@fokusin.app' || email.toLowerCase().contains('admin')) {
      return true;
    }
    final prefs = await SharedPreferences.getInstance();
    final list = prefs.getStringList(_keyRegisteredUsers) ?? [];
    for (final u in list) {
      final parts = u.split('|');
      if (parts.length >= 4 && parts[1].toLowerCase() == email.toLowerCase() && parts[3] == 'admin') {
        return true;
      }
    }
    return false;
  }

  static Future<List<Map<String, dynamic>>> getAllRegisteredUsers() async {
    await ensureDefaultAdmin();
    final prefs = await SharedPreferences.getInstance();

    final currentName = prefs.getString(_keyCurrentUserName) ?? '';
    final currentEmail = prefs.getString(_keyCurrentUserEmail) ?? '';
    final list = prefs.getStringList(_keyRegisteredUsers) ?? [];

    if (currentName.isNotEmpty && currentEmail.isNotEmpty) {
      bool exists = list.any((u) => u.split('|').length >= 2 && u.split('|')[1].toLowerCase() == currentEmail.toLowerCase());
      if (!exists) {
        list.add('$currentName|$currentEmail|pass123');
        await prefs.setStringList(_keyRegisteredUsers, list);
      }
    }

    final blockedList = prefs.getStringList(_keyBlockedUsers) ?? [];
    final result = <Map<String, dynamic>>[];
    for (final item in list) {
      final parts = item.split('|');
      if (parts.length >= 2) {
        final name = parts[0];
        final email = parts[1];
        final role = parts.length >= 4 ? parts[3] : (email.toLowerCase().contains('admin') ? 'admin' : 'user');
        final isBlocked = blockedList.any((b) => b.toLowerCase() == email.toLowerCase());
        result.add({
          'name': name,
          'email': email,
          'role': role,
          'isBlocked': isBlocked,
        });
      }
    }
    return result;
  }

  static Future<bool> deleteRegisteredUser(String email) async {
    final prefs = await SharedPreferences.getInstance();
    final list = prefs.getStringList(_keyRegisteredUsers) ?? [];
    int initialLen = list.length;
    list.removeWhere((item) {
      final parts = item.split('|');
      return parts.length >= 2 && parts[1].toLowerCase() == email.toLowerCase();
    });
    if (list.length != initialLen) {
      await prefs.setStringList(_keyRegisteredUsers, list);
      return true;
    }
    return false;
  }

  static Future<bool> isEmailRegistered(String email) async {
    final prefs = await SharedPreferences.getInstance();
    final list = prefs.getStringList(_keyRegisteredUsers) ?? [];
    for (final u in list) {
      final parts = u.split('|');
      if (parts.length >= 2 && parts[1].toLowerCase() == email.toLowerCase()) return true;
    }
    return false;
  }

  static Future<void> setCurrentUser({required String name, required String email}) async {
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
    final email = prefs.getString(_keyCurrentUserEmail) ?? '';
    if (email.isNotEmpty) {
      final list = prefs.getStringList(_keyRegisteredUsers) ?? [];
      for (int i = 0; i < list.length; i++) {
        final parts = list[i].split('|');
        if (parts.length >= 3 && parts[1].toLowerCase() == email.toLowerCase()) {
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
        if (parts.length >= 3 && parts[1].toLowerCase() == oldEmail.toLowerCase()) {
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

  static Future<void> saveCustomTimer(int minutes, int seconds) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(_keyCustomMinutes, minutes);
    await prefs.setInt(_keyCustomSeconds, seconds);
  }

  static Future<Map<String, int>> loadCustomTimer() async {
    final prefs = await SharedPreferences.getInstance();
    return {'minutes': prefs.getInt(_keyCustomMinutes) ?? 25, 'seconds': prefs.getInt(_keyCustomSeconds) ?? 0};
  }

  static Future<List<Map<String, dynamic>>> loadCustomPresets() async {
    final prefs = await SharedPreferences.getInstance();
    final list = prefs.getStringList(_keyCustomPresets) ?? [];
    final result = <Map<String, dynamic>>[];
    for (final item in list) {
      final parts = item.split('|');
      if (parts.length >= 2) {
        result.add({'minutes': int.tryParse(parts[0]) ?? 0, 'seconds': int.tryParse(parts[1]) ?? 0, 'label': parts.length >= 3 ? parts[2] : ''});
      }
    }
    return result;
  }

  static Future<void> saveCustomPreset({required int minutes, required int seconds, String label = ''}) async {
    final prefs = await SharedPreferences.getInstance();
    final list = prefs.getStringList(_keyCustomPresets) ?? [];
    final key = '$minutes|$seconds';
    for (final item in list) {
      final parts = item.split('|');
      if (parts.length >= 2 && '${parts[0]}|${parts[1]}' == key) return;
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
      return int.tryParse(parts[0]) == minutes && int.tryParse(parts[1]) == seconds;
    });
    await prefs.setStringList(_keyCustomPresets, list);
  }

  static Future<void> saveLockApp(bool value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_keyLockApp, value);
  }

  static Future<bool> loadLockApp() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_keyLockApp) ?? false;
  }

  static Future<void> saveXp(int xp) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(_keyXp, xp);
  }

  static Future<int> loadXp() async {
    if (await isAdmin()) return 999999;
    final prefs = await SharedPreferences.getInstance();
    return prefs.getInt(_keyXp) ?? 0;
  }

  static Future<bool> deductXp(int amount) async {
    if (await isAdmin()) return true;
    final prefs = await SharedPreferences.getInstance();
    int currentXp = prefs.getInt(_keyXp) ?? 0;
    if (currentXp >= amount) {
      await prefs.setInt(_keyXp, currentXp - amount);
      return true;
    }
    return false;
  }

  static Future<void> saveCustomMusicTrack(MusicTrack track) async {
    final prefs = await SharedPreferences.getInstance();
    final list = prefs.getStringList(_keyCustomMusicTracks) ?? [];
    list.add(track.toStorageString());
    await prefs.setStringList(_keyCustomMusicTracks, list);
  }

  static Future<List<MusicTrack>> loadCustomMusicTracks() async {
    final prefs = await SharedPreferences.getInstance();
    final list = prefs.getStringList(_keyCustomMusicTracks) ?? [];
    return list.map((str) => MusicTrack.fromStorageString(str)).toList();
  }

  static Future<void> deleteCustomMusicTrack(String title) async {
    final prefs = await SharedPreferences.getInstance();
    final list = prefs.getStringList(_keyCustomMusicTracks) ?? [];
    list.removeWhere((str) => str.split('|').first.toLowerCase() == title.toLowerCase());
    await prefs.setStringList(_keyCustomMusicTracks, list);
  }

  static Future<void> saveCompletedChallenges(List<String> ids) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setStringList(_keyCompletedChallenges, ids);
  }

  static Future<List<String>> loadCompletedChallenges() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getStringList(_keyCompletedChallenges) ?? [];
  }

  static Future<void> saveSelectedMusic(String music) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_keySelectedMusic, music);
  }

  static Future<String> loadSelectedMusic() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_keySelectedMusic) ?? 'Rain Sounds';
  }

  static Future<int> loadTotalPomodoro() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getInt(_keyTotalPomodoro) ?? 0;
  }

  static Future<int> loadTodayPomodoro() async {
    final prefs = await SharedPreferences.getInstance();
    final today = _todayStr();
    final lastDate = prefs.getString(_keyLastDate) ?? '';
    if (lastDate != today) return 0;
    return prefs.getInt(_keyTodayPomodoro) ?? 0;
  }

  static Future<int> loadStreak() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getInt(_keyStreak) ?? 0;
  }

  static Future<bool> loadEarlyBirdDone() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_keyEarlyBirdDone) ?? false;
  }

  static Future<void> saveStreakFreeze(bool value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_keyStreakFreeze, value);
  }

  static Future<bool> loadStreakFreeze() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_keyStreakFreeze) ?? false;
  }

  static Future<void> saveThemeColorIndex(int index) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(_keyThemeColor, index);
  }

  static Future<int> loadThemeColorIndex() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getInt(_keyThemeColor) ?? 0;
  }

  static Future<List<int>> loadOwnedThemes() async {
    final prefs = await SharedPreferences.getInstance();
    final list = prefs.getStringList(_keyOwnedThemes);
    if (list == null || list.isEmpty) return [0];
    return list.map((e) => int.tryParse(e) ?? 0).toList();
  }

  static Future<void> saveOwnedThemes(List<int> themes) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setStringList(_keyOwnedThemes, themes.map((e) => e.toString()).toList());
  }

  static Future<List<String>> loadOwnedMusic() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getStringList(_keyOwnedMusic) ?? [];
  }

  static Future<void> saveOwnedMusic(List<String> titles) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setStringList(_keyOwnedMusic, titles);
  }

  static Future<void> checkStreakStatus() async {
    final prefs = await SharedPreferences.getInstance();
    final today = _todayStr();
    final lastDate = prefs.getString(_keyLastDate) ?? '';
    if (lastDate.isEmpty) return;

    final alreadyBroken = prefs.getBool(_keyStreakBroken) ?? false;
    if (alreadyBroken) return;
    if (lastDate == today || _isYesterday(lastDate)) return;

    final hasFreeze = prefs.getBool(_keyStreakFreeze) ?? false;
    final currentStreak = prefs.getInt(_keyStreak) ?? 0;

    if (hasFreeze && currentStreak > 0) {
      await prefs.setBool(_keyStreakFreeze, false);
      await prefs.setString(_keyLastDate, _yesterdayStr());
    } else {
      if (currentStreak > 0) {
        await prefs.setInt(_keyLastStreakValue, currentStreak);
        await prefs.setInt(_keyStreak, 0);
        await prefs.setBool(_keyStreakBroken, true);
      }
    }
  }

  static Future<bool> isStreakBroken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_keyStreakBroken) ?? false;
  }

  static Future<int> loadLastStreakValue() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getInt(_keyLastStreakValue) ?? 0;
  }

  static Future<void> restoreStreak() async {
    final prefs = await SharedPreferences.getInstance();
    final lastValue = prefs.getInt(_keyLastStreakValue) ?? 0;
    await prefs.setInt(_keyStreak, lastValue);
    await prefs.setBool(_keyStreakBroken, false);
    await prefs.setString(_keyLastDate, _todayStr());
  }

  static Future<Map<String, int>> loadPomodoroHistory() async {
    final prefs = await SharedPreferences.getInstance();
    final list = prefs.getStringList(_keyPomodoroHistory) ?? [];
    final result = <String, int>{};
    for (final item in list) {
      final parts = item.split('|');
      if (parts.length == 2) result[parts[0]] = int.tryParse(parts[1]) ?? 0;
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

    final total = (prefs.getInt(_keyTotalPomodoro) ?? 0) + 1;
    await prefs.setInt(_keyTotalPomodoro, total);

    int todayCount;
    int streak = prefs.getInt(_keyStreak) ?? 0;

    if (lastDate == today) {
      todayCount = (prefs.getInt(_keyTodayPomodoro) ?? 0) + 1;
    } else {
      todayCount = 1;
      if (broken) {
        streak = 1;
        await prefs.setBool(_keyStreakBroken, false);
      } else if (lastDate.isEmpty) {
        streak = 1;
      } else if (_isYesterday(lastDate)) {
        streak += 1;
      } else {
        if (streak > 0) await prefs.setInt(_keyLastStreakValue, streak);
        streak = 1;
      }
    }

    await prefs.setString(_keyLastDate, today);
    await prefs.setInt(_keyStreak, streak);
    await prefs.setInt(_keyTodayPomodoro, todayCount);

    final history = await loadPomodoroHistory();
    history[today] = todayCount;
    await _savePomodoroHistory(history);

    if (DateTime.now().hour < 10) await prefs.setBool(_keyEarlyBirdDone, true);
  }

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

  static Future<void> saveApiKey(String key) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_keyApiKey, key);
  }

  static Future<String> loadApiKey() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_keyApiKey) ?? '';
  }

  static String _todayStr() {
    final now = DateTime.now();
    return '${now.year}-${now.month}-${now.day}';
  }

  static String _yesterdayStr() {
    final yesterday = DateTime.now().subtract(const Duration(days: 1));
    return '${yesterday.year}-${yesterday.month}-${yesterday.day}';
  }

  static bool _isYesterday(String dateStr) {
    if (dateStr.isEmpty) return false;
    final parts = dateStr.split('-').map(int.parse).toList();
    final date = DateTime(parts[0], parts[1], parts[2]);
    final yesterday = DateTime.now().subtract(const Duration(days: 1));
    return date.year == yesterday.year && date.month == yesterday.month && date.day == yesterday.day;
  }
}