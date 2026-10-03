import 'dart:async';

import 'package:flutter/material.dart';

import '../theme/app_theme.dart';

class TimerScreen extends StatefulWidget {
  const TimerScreen({super.key});

  @override
  State<TimerScreen> createState() => _TimerScreenState();
}

class _TimerScreenState extends State<TimerScreen> {
  int selectedMinutes = 25;

  int remainingSeconds = 25 * 60;

  Timer? timer;

  bool isRunning = false;

  @override
  void dispose() {
    timer?.cancel();
    super.dispose();
  }

  void selectDuration(int minutes) {
    timer?.cancel();

    setState(() {
      selectedMinutes = minutes;
      remainingSeconds = minutes * 60;
      isRunning = false;
    });
  }

  void startTimer() {
    if (isRunning) {
      timer?.cancel();

      setState(() {
        isRunning = false;
      });

      return;
    }

    setState(() {
      isRunning = true;
    });

    timer = Timer.periodic(
      const Duration(seconds: 1),
          (timer) {
        if (remainingSeconds <= 0) {
          timer.cancel();

          setState(() {
            isRunning = false;
          });

          showDialog(
            context: context,
            builder: (context) {
              return AlertDialog(
                title: const Text(
                  'Pomodoro Complete 🎉',
                ),
                content: const Text(
                  'Great job! Kamu berhasil menyelesaikan sesi fokus.',
                ),
                actions: [
                  TextButton(
                    onPressed: () {
                      Navigator.pop(context);
                    },
                    child: const Text('OK'),
                  ),
                ],
              );
            },
          );

          return;
        }

        setState(() {
          remainingSeconds--;
        });
      },
    );
  }

  void resetTimer() {
    timer?.cancel();

    setState(() {
      remainingSeconds = selectedMinutes * 60;
      isRunning = false;
    });
  }

  String get minutes {
    return (remainingSeconds ~/ 60)
        .toString()
        .padLeft(2, '0');
  }

  String get seconds {
    return (remainingSeconds % 60)
        .toString()
        .padLeft(2, '0');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5FAF9),

      appBar: AppBar(
        title: const Text(
          'Pomodoro Timer',
        ),

        centerTitle: true,

        backgroundColor: Colors.transparent,

        elevation: 0,

        foregroundColor: AppTheme.darkTeal,
      ),

      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(20),

          child: Column(
            children: [
              const SizedBox(height: 20),

              // =================================================
              // TITLE
              // =================================================

              const Text(
                'Stay Focused',
                style: TextStyle(
                  fontSize: 25,
                  fontWeight: FontWeight.bold,
                  color: AppTheme.darkTeal,
                ),
              ),

              const SizedBox(height: 8),

              const Text(
                'Focus on your task and avoid distractions.',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: AppTheme.textGrey,
                ),
              ),

              const SizedBox(height: 35),

              // =================================================
              // TIMER
              // =================================================

              Container(
                width: 260,
                height: 260,

                decoration: BoxDecoration(
                  shape: BoxShape.circle,

                  color: Colors.white,

                  border: Border.all(
                    color: AppTheme.primaryTeal,
                    width: 8,
                  ),

                  boxShadow: [
                    BoxShadow(
                      color: AppTheme.primaryTeal
                          .withOpacity(0.15),
                      blurRadius: 25,
                      spreadRadius: 5,
                    ),
                  ],
                ),

                child: Center(
                  child: Column(
                    mainAxisAlignment:
                    MainAxisAlignment.center,

                    children: [
                      Text(
                        '$minutes:$seconds',

                        style: const TextStyle(
                          fontSize: 52,
                          fontWeight: FontWeight.bold,
                          color: AppTheme.darkTeal,
                        ),
                      ),

                      const SizedBox(height: 5),

                      Text(
                        isRunning
                            ? 'Focusing...'
                            : 'Ready to focus',

                        style: const TextStyle(
                          color: AppTheme.textGrey,
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 35),

              // =================================================
              // DURATION
              // =================================================

              const Align(
                alignment: Alignment.centerLeft,

                child: Text(
                  'Choose Duration',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),

              const SizedBox(height: 12),

              Row(
                children: [
                  Expanded(
                    child: _durationButton(15),
                  ),

                  const SizedBox(width: 10),

                  Expanded(
                    child: _durationButton(25),
                  ),

                  const SizedBox(width: 10),

                  Expanded(
                    child: _durationButton(45),
                  ),
                ],
              ),

              const Spacer(),

              // =================================================
              // BUTTON
              // =================================================

              SizedBox(
                width: double.infinity,
                height: 55,

                child: ElevatedButton.icon(
                  onPressed: startTimer,

                  icon: Icon(
                    isRunning
                        ? Icons.pause
                        : Icons.play_arrow,
                  ),

                  label: Text(
                    isRunning
                        ? 'Pause'
                        : 'Start Focus',
                  ),

                  style: ElevatedButton.styleFrom(
                    backgroundColor:
                    AppTheme.primaryTeal,

                    foregroundColor: Colors.white,

                    elevation: 0,

                    shape:
                    RoundedRectangleBorder(
                      borderRadius:
                      BorderRadius.circular(16),
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 12),

              TextButton.icon(
                onPressed: resetTimer,

                icon: const Icon(
                  Icons.refresh,
                ),

                label: const Text(
                  'Reset Timer',
                ),
              ),

              const SizedBox(height: 10),
            ],
          ),
        ),
      ),
    );
  }

  Widget _durationButton(int minutes) {
    final selected =
        selectedMinutes == minutes;

    return GestureDetector(
      onTap: () {
        selectDuration(minutes);
      },

      child: Container(
        padding:
        const EdgeInsets.symmetric(
          vertical: 12,
        ),

        decoration: BoxDecoration(
          color: selected
              ? AppTheme.primaryTeal
              : Colors.white,

          borderRadius:
          BorderRadius.circular(14),

          border: Border.all(
            color: selected
                ? AppTheme.primaryTeal
                : AppTheme.lightTeal,
          ),
        ),

        child: Center(
          child: Text(
            '$minutes min',

            style: TextStyle(
              color: selected
                  ? Colors.white
                  : AppTheme.darkTeal,

              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ),
    );
  }
}