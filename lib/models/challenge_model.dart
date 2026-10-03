import 'package:flutter/material.dart';

class ChallengeModel {
  final String title;

  final String description;

  final int target;

  int progress;

  final int reward;

  final IconData icon;

  ChallengeModel({
    required this.title,
    required this.description,
    required this.target,
    required this.progress,
    required this.reward,
    required this.icon,
  });

  double get percentage {
    if (target == 0) {
      return 0;
    }

    return progress / target;
  }

  bool get isCompleted {
    return progress >= target;
  }

  void addProgress() {
    if (progress < target) {
      progress++;
    }
  }
}