import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

class MusicCard extends StatefulWidget {
  const MusicCard({super.key});

  @override
  State<MusicCard> createState() => _MusicCardState();
}

class _MusicCardState extends State<MusicCard> {
  bool isPlaying = false;

  String selectedMusic = 'Rain Sounds';

  final List<String> musicList = [
    'Rain Sounds',
    'Forest Sounds',
    'Ocean Waves',
    'Piano Relax',
  ];

  void toggleMusic() {
    setState(() {
      isPlaying = !isPlaying;
    });

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        duration: const Duration(milliseconds: 900),
        content: Text(
          isPlaying
              ? '$selectedMusic sedang dimainkan 🎧'
              : 'Music dihentikan.',
        ),
      ),
    );
  }

  void chooseMusic() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(25),
        ),
      ),
      builder: (context) {
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Choose Relaxing Music',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: AppTheme.darkTeal,
                  ),
                ),

                const SizedBox(height: 15),

                ...musicList.map(
                      (music) {
                    final isSelected =
                        music == selectedMusic;

                    return ListTile(
                      contentPadding:
                      EdgeInsets.zero,

                      leading: Container(
                        width: 45,
                        height: 45,
                        decoration: BoxDecoration(
                          color: AppTheme.lightTeal,
                          borderRadius:
                          BorderRadius.circular(12),
                        ),
                        child: Icon(
                          _getMusicIcon(music),
                          color: AppTheme.darkTeal,
                        ),
                      ),

                      title: Text(
                        music,
                        style: TextStyle(
                          fontWeight:
                          isSelected
                              ? FontWeight.bold
                              : FontWeight.normal,
                        ),
                      ),

                      subtitle: const Text(
                        'Relax & Focus',
                      ),

                      trailing: isSelected
                          ? const Icon(
                        Icons.check_circle,
                        color:
                        AppTheme.primaryTeal,
                      )
                          : null,

                      onTap: () {
                        setState(() {
                          selectedMusic = music;
                          isPlaying = false;
                        });

                        Navigator.pop(context);
                      },
                    );
                  },
                ),

                const SizedBox(height: 10),
              ],
            ),
          ),
        );
      },
    );
  }

  IconData _getMusicIcon(String music) {
    switch (music) {
      case 'Rain Sounds':
        return Icons.water_drop;

      case 'Forest Sounds':
        return Icons.forest;

      case 'Ocean Waves':
        return Icons.waves;

      case 'Piano Relax':
        return Icons.piano;

      default:
        return Icons.music_note;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,

      padding: const EdgeInsets.all(16),

      decoration: BoxDecoration(
        color: Colors.white,

        borderRadius: BorderRadius.circular(20),

        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),

      child: Row(
        children: [
          // =====================================================
          // MUSIC ICON
          // =====================================================

          Container(
            width: 58,
            height: 58,

            decoration: BoxDecoration(
              color: AppTheme.lightTeal,

              borderRadius:
              BorderRadius.circular(16),
            ),

            child: Icon(
              _getMusicIcon(selectedMusic),
              color: AppTheme.darkTeal,
              size: 28,
            ),
          ),

          const SizedBox(width: 14),

          // =====================================================
          // MUSIC INFORMATION
          // =====================================================

          Expanded(
            child: GestureDetector(
              onTap: chooseMusic,

              child: Column(
                crossAxisAlignment:
                CrossAxisAlignment.start,

                children: [
                  Text(
                    selectedMusic,

                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                      color: AppTheme.textDark,
                    ),
                  ),

                  const SizedBox(height: 4),

                  Text(
                    isPlaying
                        ? 'Playing • Relax & Focus'
                        : 'Tap to choose music',

                    style: const TextStyle(
                      color: AppTheme.textGrey,
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            ),
          ),

          // =====================================================
          // PLAY BUTTON
          // =====================================================

          IconButton(
            onPressed: toggleMusic,

            icon: Icon(
              isPlaying
                  ? Icons.pause_circle_filled
                  : Icons.play_circle_fill,

              color: AppTheme.primaryTeal,

              size: 40,
            ),
          ),

          // =====================================================
          // MUSIC MENU
          // =====================================================

          IconButton(
            onPressed: chooseMusic,

            icon: const Icon(
              Icons.more_vert,
              color: AppTheme.textGrey,
            ),
          ),
        ],
      ),
    );
  }
}