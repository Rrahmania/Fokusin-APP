import 'dart:async';
import 'package:flutter/material.dart';
import 'package:vibration/vibration.dart'; // TAMBAHAN IMPORT
import 'storage_service.dart';
import 'challenge_service.dart';

class TimerService extends ChangeNotifier {
  static final TimerService instance = TimerService._internal();
  TimerService._internal();

  final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

  int selectedMinutes = 25;
  int selectedSeconds = 0;
  int remainingSeconds = 25 * 60;
  bool isRunning = false;

  int? activePreset = 25;
  int activeCustomIndex = -1;

  String selectedActivity = 'Belajar';
  String selectedMusic = 'Lo-fi Focus';

  Timer? _timer;

  String get timerText {
    final h = remainingSeconds ~/ 3600;
    final m = (remainingSeconds % 3600) ~/ 60;
    final s = remainingSeconds % 60;
    if (h > 0) return '${h.toString().padLeft(2, '0')}:${m.toString().padLeft(2, '0')}:${s.toString().padLeft(2, '0')}';
    return '${m.toString().padLeft(2, '0')}:${s.toString().padLeft(2, '0')}';
  }

  void selectPreset(int minutes) {
    _timer?.cancel();
    selectedMinutes = minutes;
    selectedSeconds = 0;
    remainingSeconds = minutes * 60;
    isRunning = false;
    activePreset = minutes;
    activeCustomIndex = -1;
    notifyListeners();
  }

  void selectCustomPreset({required int minutes, required int seconds, required int index, String? activity}) {
    _timer?.cancel();
    selectedMinutes = minutes;
    selectedSeconds = seconds;
    remainingSeconds = minutes * 60 + seconds;
    isRunning = false;
    activePreset = null;
    activeCustomIndex = index;
    if (activity != null) selectedActivity = activity;
    notifyListeners();
  }

  void setActivity(String activity) {
    if (isRunning) return;
    selectedActivity = activity;
    notifyListeners();
  }

  void setMusic(String music) {
    selectedMusic = music;
    notifyListeners();
  }

  void toggle() => isRunning ? pause() : start();

  void start() {
    if (isRunning) return;
    _timer?.cancel();
    isRunning = true;
    notifyListeners();

    _timer = Timer.periodic(const Duration(seconds: 1), (t) async {
      if (remainingSeconds <= 0) {
        t.cancel();
        isRunning = false;
        notifyListeners();
        await _onComplete();
        return;
      }
      remainingSeconds--;
      notifyListeners();
    });
  }

  void pause() {
    _timer?.cancel();
    isRunning = false;
    notifyListeners();
  }

  void reset() {
    _timer?.cancel();
    remainingSeconds = selectedMinutes * 60 + selectedSeconds;
    isRunning = false;
    notifyListeners();
  }

  Future<void> _onComplete() async {
    await StorageService.recordPomodoroCompleted();
    final result = await ChallengeService.evaluate();

    final context = navigatorKey.currentContext;
    if (context == null) return;

    // 1. MULAI GETARAN (Bergetar 1 detik, diam 1 detik, diulang terus)
    Vibration.hasVibrator().then((bool? hasVibrator) {
      if (hasVibrator == true) {
        Vibration.vibrate(pattern: [1000, 1000], repeat: 0);
      }
    });

    // 2. TAMPILKAN DIALOG
    showDialog(
      context: context,
      barrierDismissible: false, // User WAJIB klik tombol OK
      builder: (_) => AlertDialog(
        title: Text('$selectedActivity selesai! 🎉'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Great job! Kamu berhasil menyelesaikan sesi $selectedActivity.'),
            if (result.xpGained > 0) ...[
              const SizedBox(height: 12),
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: const Color(0xFF2C5F51).withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('+${result.xpGained} XP', style: const TextStyle(color: Color(0xFF2C5F51), fontWeight: FontWeight.bold)),
                    const SizedBox(height: 4),
                    ...result.newlyCompleted.map((c) => Text('🏆 ${c.title}', style: const TextStyle(fontSize: 12, color: Color(0xFF2C5F51)))),
                  ],
                ),
              ),
            ],
          ],
        ),
        actions: [
          TextButton(
            onPressed: () {
              // 3. HENTIKAN GETARAN SAAT TOMBOL OK DIKLIK
              Vibration.cancel();
              Navigator.pop(context);
            },
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _timer?.cancel();
    Vibration.cancel(); // Pastikan getar berhenti jika aplikasi ditutup paksa
    super.dispose();
  }
}