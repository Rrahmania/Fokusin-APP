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

      decoration: BoxDecoration(
        color: Colors.white,

        borderRadius: BorderRadius.circular(22),

        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 12,
            offset: const Offset(0, 5),
          ),
        ],
      ),

      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,

        children: [
          // =====================================================
          // HEADER
          // =====================================================

          Row(
            children: [
              Container(
                width: 48,
                height: 48,

                decoration: BoxDecoration(
                  color: AppTheme.lightTeal,
                  borderRadius: BorderRadius.circular(14),
                ),

                child: const Icon(
                  Icons.timer_outlined,
                  color: AppTheme.darkTeal,
                  size: 26,
                ),
              ),

              const SizedBox(width: 12),

              const Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,

                  children: [
                    Text(
                      'Focus Session',
                      style: TextStyle(
                        fontSize: 17,
                        fontWeight: FontWeight.bold,
                        color: AppTheme.textDark,
                      ),
                    ),

                    SizedBox(height: 4),

                    Text(
                      'Time to focus and get things done',
                      style: TextStyle(
                        fontSize: 12,
                        color: AppTheme.textGrey,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),

          const SizedBox(height: 20),

          // =====================================================
          // TIMER PREVIEW
          // =====================================================

          Container(
            width: double.infinity,

            padding: const EdgeInsets.symmetric(
              vertical: 18,
            ),

            decoration: BoxDecoration(
              color: AppTheme.lightTeal,
              borderRadius: BorderRadius.circular(18),
            ),

            child: const Column(
              children: [
                Text(
                  '25:00',
                  style: TextStyle(
                    fontSize: 38,
                    fontWeight: FontWeight.bold,
                    color: AppTheme.darkTeal,
                  ),
                ),

                SizedBox(height: 3),

                Text(
                  'Focus',
                  style: TextStyle(
                    fontSize: 12,
                    color: AppTheme.textGrey,
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 16),

          // =====================================================
          // START BUTTON
          // =====================================================

          SizedBox(
            width: double.infinity,
            height: 50,

            child: ElevatedButton.icon(
              onPressed: () {
                Navigator.push(
                  context,

                  MaterialPageRoute(
                    builder: (context) => const TimerScreen(),
                  ),
                );
              },

              icon: const Icon(
                Icons.play_arrow,
              ),

              label: const Text(
                'Start Pomodoro',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                ),
              ),

              style: ElevatedButton.styleFrom(
                backgroundColor: AppTheme.primaryTeal,
                foregroundColor: Colors.white,

                elevation: 0,

                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(15),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}