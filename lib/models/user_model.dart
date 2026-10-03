import 'package:flutter/material.dart';

class UserModel extends ChangeNotifier {
  // =========================
  // USER DATA
  // =========================

  String name = 'Rahmania Utami';

  String email = 'rahmania@gmail.com';

  String bio =
      'Keep focusing and keep growing 🚀';

  String avatarLetter = 'R';

  // =========================
  // PRODUCTIVITY DATA
  // =========================

  int streak = 7;

  int totalPomodoro = 42;

  int completedChallenges = 18;

  int totalFocusMinutes = 1050;

  int xp = 1250;

  // =========================
  // SETTINGS
  // =========================

  bool notificationsEnabled = true;

  bool soundEnabled = true;

  bool darkModeEnabled = false;

  // =========================
  // UPDATE PROFILE
  // =========================

  void updateProfile({
    required String newName,
    required String newEmail,
    required String newBio,
  }) {
    name = newName;

    email = newEmail;

    bio = newBio;

    if (name.isNotEmpty) {
      avatarLetter =
          name[0].toUpperCase();
    }

    notifyListeners();
  }

  // =========================
  // ADD POMODORO
  // =========================

  void completePomodoro(
      int minutes) {
    totalPomodoro++;

    totalFocusMinutes += minutes;

    xp += 25;

    notifyListeners();
  }

  // =========================
  // COMPLETE CHALLENGE
  // =========================

  void completeChallenge(
      int reward) {
    completedChallenges++;

    xp += reward;

    notifyListeners();
  }

  // =========================
  // SETTINGS
  // =========================

  void setNotifications(
      bool value) {
    notificationsEnabled =
        value;

    notifyListeners();
  }

  void setSound(bool value) {
    soundEnabled = value;

    notifyListeners();
  }

  void setDarkMode(bool value) {
    darkModeEnabled = value;

    notifyListeners();
  }

  void increaseStreak() {
    streak++;

    notifyListeners();
  }
}

final UserModel userData =
UserModel();