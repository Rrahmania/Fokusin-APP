import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

class AiRecommendation extends StatefulWidget {
  const AiRecommendation({super.key});

  @override
  State<AiRecommendation> createState() => _AiRecommendationState();
}

class _AiRecommendationState extends State<AiRecommendation> {
  int selectedIndex = 0;
  final List<Map<String, dynamic>> recommendations = [
    {'title': 'Belajar Struktur Data', 'description': 'Cocok untuk meningkatkan pemahaman codingmu hari ini.', 'duration': '2 Pomodoro', 'icon': Icons.code},
    {'title': 'Review Materi Kuliah', 'description': 'Gunakan waktu fokus untuk mengulang materi yang belum dikuasai.', 'duration': '3 Pomodoro', 'icon': Icons.menu_book},
    {'title': 'Kerjakan Project', 'description': 'Lanjutkan project yang sedang kamu kerjakan.', 'duration': '4 Pomodoro', 'icon': Icons.laptop_mac},
  ];

  void nextRecommendation() {
    setState(() {
      selectedIndex++;
      if (selectedIndex >= recommendations.length) selectedIndex = 0;
    });
  }

  @override
  Widget build(BuildContext context) {
    final item = recommendations[selectedIndex];
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(color: AppTheme.card, borderRadius: BorderRadius.circular(20), border: Border.all(color: AppTheme.border, width: 1.5)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(color: AppTheme.lightTeal, borderRadius: BorderRadius.circular(14)),
                child: Icon(Icons.auto_awesome, color: AppTheme.primary), // Hapus const
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Focus AI', style: TextStyle(color: AppTheme.primary, fontWeight: FontWeight.bold, fontSize: 13)), // Hapus const
                    const SizedBox(height: 4),
                    Text('Rekomendasi untukmu', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 17, color: AppTheme.txt)),
                  ],
                ),
              ),
              IconButton(onPressed: nextRecommendation, icon: Icon(Icons.refresh, color: AppTheme.txt)),
            ],
          ),
          const SizedBox(height: 20),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Icon(item['icon'], color: AppTheme.primary, size: 28), // Hapus const
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(item['title'], style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: AppTheme.txt)),
                    const SizedBox(height: 6),
                    Text(item['description'], style: TextStyle(color: AppTheme.txtGrey, height: 1.5, fontSize: 13)),
                    const SizedBox(height: 10),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                      decoration: BoxDecoration(color: AppTheme.lightTeal, borderRadius: BorderRadius.circular(20)),
                      child: Text(item['duration'], style: TextStyle(color: AppTheme.primary, fontSize: 12, fontWeight: FontWeight.bold)), // Hapus const
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}