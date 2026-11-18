import 'package:flutter/material.dart';
import '../models/music_model.dart';
import '../theme/app_theme.dart';
import '../services/music_service.dart';

class MusicPlayerScreen extends StatelessWidget {
  final MusicTrack? initialTrack;

  const MusicPlayerScreen({super.key, this.initialTrack});

  @override
  Widget build(BuildContext context) {
    if (initialTrack != null && MusicService.instance.current.title != initialTrack!.title) {
      final idx = MusicService.instance.playlist.indexWhere((t) => t.title == initialTrack!.title);
      if (idx >= 0) {
        MusicService.instance.selectTrack(idx);
      }
    }

    return ListenableBuilder(
        listenable: MusicService.instance,
        builder: (context, _) {
          final service = MusicService.instance;
          final current = service.current;

          // CEK APAKAH TERKUNCI
          final isLocked = current.price > 0 && !service.isTrackOwned(current.title);

          final totalSecs = service.totalDuration.inSeconds > 0
              ? service.totalDuration.inSeconds
              : current.durationSeconds;
          final progress = totalSecs == 0 ? 0.0 : (service.currentPosition.inSeconds / totalSecs).clamp(0.0, 1.0);

          return Scaffold(
            backgroundColor: AppTheme.bg,
            appBar: AppBar(title: const Text('Audio Player'), centerTitle: false, backgroundColor: AppTheme.bg, elevation: 0),
            body: SafeArea(
              child: Column(
                children: [
                  const SizedBox(height: 20),
                  Stack(
                    alignment: Alignment.center,
                    children: [
                      Container(
                        width: 220,
                        height: 220,
                        decoration: BoxDecoration(
                          color: isLocked ? Colors.grey : current.color,
                          borderRadius: BorderRadius.circular(30),
                        ),
                        child: Icon(current.icon, size: 100, color: Colors.white),
                      ),
                      if (isLocked)
                        Container(
                          decoration: BoxDecoration(color: Colors.black45, borderRadius: BorderRadius.circular(30)),
                          width: 220, height: 220,
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              const Icon(Icons.lock, color: Colors.white, size: 50),
                              const SizedBox(height: 8),
                              Text('Butuh ${current.price} XP', style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                            ],
                          ),
                        ),
                    ],
                  ),
                  const SizedBox(height: 25),
                  Text(current.title, style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: AppTheme.txt)),
                  const SizedBox(height: 5),
                  Text(current.artist, style: TextStyle(color: AppTheme.txtGrey)),
                  const SizedBox(height: 25),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 30),
                    child: Column(
                      children: [
                        ClipRRect(
                          borderRadius: BorderRadius.circular(10),
                          child: LinearProgressIndicator(
                            value: isLocked ? 0 : progress,
                            minHeight: 6,
                            backgroundColor: AppTheme.border,
                            color: isLocked ? Colors.grey : current.color,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(_fmt(service.currentPosition.inSeconds), style: TextStyle(fontSize: 12, color: AppTheme.txtGrey)),
                            Text(
                                service.totalDuration.inSeconds > 0 ? _fmt(service.totalDuration.inSeconds) : current.duration,
                                style: TextStyle(fontSize: 12, color: AppTheme.txtGrey)
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 20),

                  // TOMBOL PLAY / BELI
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      IconButton(iconSize: 40, onPressed: service.prev, icon: Icon(Icons.skip_previous, color: AppTheme.txt)),
                      const SizedBox(width: 15),
                      if (isLocked)
                        ElevatedButton(
                          onPressed: () async {
                            bool success = await service.purchaseTrack(service.currentIndex);
                            if (success) {
                              service.togglePlay();
                              if (context.mounted) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(content: Text('Musik berhasil dibeli! 🎉'), backgroundColor: Colors.green),
                                );
                              }
                            } else {
                              if (context.mounted) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(content: Text('XP tidak cukup untuk membeli musik ini.'), backgroundColor: Colors.red),
                                );
                              }
                            }
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppTheme.primary,
                            padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 15),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
                          ),
                          child: Text('Beli - ${current.price} XP', style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                        )
                      else
                        Container(
                          decoration: BoxDecoration(color: current.color, shape: BoxShape.circle),
                          child: IconButton(
                            iconSize: 45,
                            onPressed: service.togglePlay,
                            icon: Icon(service.isPlaying ? Icons.pause : Icons.play_arrow, color: Colors.white),
                          ),
                        ),
                      const SizedBox(width: 15),
                      IconButton(iconSize: 40, onPressed: service.next, icon: Icon(Icons.skip_next, color: AppTheme.txt)),
                    ],
                  ),
                  const SizedBox(height: 20),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 24),
                    child: Row(
                      children: [
                        Text('Audio List (${service.playlist.length})', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppTheme.txt)),
                      ],
                    ),
                  ),
                  const SizedBox(height: 12),
                  Expanded(
                    child: ListView.builder(
                      padding: const EdgeInsets.symmetric(horizontal: 24),
                      itemCount: service.playlist.length,
                      itemBuilder: (context, i) {
                        final track = service.playlist[i];
                        final isCurrent = i == service.currentIndex;
                        final trackLocked = track.price > 0 && !service.isTrackOwned(track.title);

                        return GestureDetector(
                          onTap: () {
                            service.selectTrack(i);
                            if (trackLocked) {
                              service.stop();
                            }
                          },
                          child: Container(
                            margin: const EdgeInsets.only(bottom: 10),
                            padding: const EdgeInsets.all(14),
                            decoration: BoxDecoration(
                              color: isCurrent ? current.color.withValues(alpha: 0.1) : AppTheme.card,
                              borderRadius: BorderRadius.circular(16),
                              border: Border.all(color: isCurrent ? current.color : AppTheme.border, width: 1.5),
                            ),
                            child: Row(
                              children: [
                                Container(
                                  width: 45,
                                  height: 45,
                                  decoration: BoxDecoration(
                                      color: trackLocked ? Colors.grey.withValues(alpha: 0.2) : track.color.withValues(alpha: 0.2),
                                      borderRadius: BorderRadius.circular(10)
                                  ),
                                  child: Icon(track.icon, color: trackLocked ? Colors.grey : track.color),
                                ),
                                const SizedBox(width: 16),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        track.title,
                                        style: TextStyle(
                                          fontWeight: isCurrent ? FontWeight.bold : FontWeight.w600,
                                          color: trackLocked ? AppTheme.txtGrey : (isCurrent ? current.color : AppTheme.txt),
                                        ),
                                      ),
                                      const SizedBox(height: 4),
                                      Text(track.artist, style: TextStyle(fontSize: 12, color: AppTheme.txtGrey)),
                                    ],
                                  ),
                                ),
                                if (trackLocked)
                                  Text('${track.price} XP', style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.orange))
                                else if (isCurrent && service.isPlaying)
                                  Icon(Icons.graphic_eq, color: current.color, size: 18),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                ],
              ),
            ),
          );
        }
    );
  }

  String _fmt(int s) {
    final m = (s ~/ 60).toString().padLeft(2, '0');
    final sec = (s % 60).toString().padLeft(2, '0');
    return '$m:$sec';
  }
}