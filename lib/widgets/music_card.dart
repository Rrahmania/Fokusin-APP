import 'package:flutter/material.dart';
import '../theme/app_theme.dart';
import '../services/music_service.dart';
import '../screens/music_player_screen.dart';

class MusicCard extends StatelessWidget {
  const MusicCard({super.key});

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: MusicService.instance,
      builder: (context, _) {
        final current = MusicService.instance.current;
        final isPlaying = MusicService.instance.isPlaying;

        return GestureDetector(
          // Jika area selain tombol diketuk, buka layar musik
          onTap: () {
            Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const MusicPlayerScreen())
            );
          },
          child: Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppTheme.card,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: AppTheme.border, width: 1.5),
            ),
            child: Row(
              children: [
                // Icon Album
                Container(
                  width: 54,
                  height: 54,
                  decoration: BoxDecoration(
                      color: current.color.withValues(alpha: 0.2),
                      borderRadius: BorderRadius.circular(15)
                  ),
                  child: Icon(current.icon, color: current.color, size: 26),
                ),
                const SizedBox(width: 16),

                // Teks Judul & Status
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                          current.title,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15, color: AppTheme.txt)
                      ),
                      const SizedBox(height: 4),
                      Text(
                          isPlaying ? 'Sedang diputar • Tap to open' : '${current.artist} • Tap to play',
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(color: isPlaying ? AppTheme.primary : AppTheme.txtGrey, fontSize: 12)
                      ),
                    ],
                  ),
                ),

                // TOMBOL PLAY / PAUSE BARU
                IconButton(
                  onPressed: () {
                    // Memanggil fungsi toggle dari service
                    MusicService.instance.togglePlay();
                  },
                  icon: Icon(
                    isPlaying ? Icons.pause_circle_filled_rounded : Icons.play_circle_fill_rounded,
                    color: AppTheme.primary,
                    size: 40,
                  ),
                  tooltip: isPlaying ? 'Pause' : 'Play',
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}