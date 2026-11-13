import 'package:flutter/material.dart';
import '../theme/app_theme.dart';
import '../screens/timer_screen.dart';

class FocusCard extends StatelessWidget {
  const FocusCard({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(color: AppTheme.card, borderRadius: BorderRadius.circular(20), border: Border.all(color: AppTheme.border, width: 1.5)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(color: AppTheme.lightTeal, borderRadius: BorderRadius.circular(14)),
                child: Icon(Icons.timer_outlined, color: AppTheme.primary, size: 26), // Hapus const
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Focus Session', style: TextStyle(fontSize: 17, fontWeight: FontWeight.bold, color: AppTheme.txt)),
                    const SizedBox(height: 4),
                    Text('Time to focus and get things done', style: TextStyle(fontSize: 12, color: AppTheme.txtGrey)),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(vertical: 20),
            decoration: BoxDecoration(color: AppTheme.lightTeal, borderRadius: BorderRadius.circular(16)),
            child: Column(
              children: [
                Text('25:00', style: TextStyle(fontSize: 38, fontWeight: FontWeight.bold, color: AppTheme.primary)), // Hapus const
                const SizedBox(height: 4),
                Text('Focus', style: TextStyle(fontSize: 12, color: AppTheme.txtGrey)),
              ],
            ),
          ),
          const SizedBox(height: 20),
          SizedBox(
            width: double.infinity,
            height: 50,
            child: ElevatedButton.icon(
              onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (context) => const TimerScreen())),
              icon: const Icon(Icons.play_arrow),
              label: const Text('Start Pomodoro', style: TextStyle(fontWeight: FontWeight.bold)),
            ),
          ),
        ],
      ),
    );
  }
}