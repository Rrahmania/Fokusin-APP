import 'package:flutter/material.dart';
import '../theme/app_theme.dart';
import '../models/music_model.dart';
import '../services/storage_service.dart';
import '../screens/music_player_screen.dart';

class MusicCard extends StatefulWidget {
  const MusicCard({super.key});

  @override
  State<MusicCard> createState() => _MusicCardState();
}

class _MusicCardState extends State<MusicCard> {
  MusicTrack current = defaultPlaylist.first;

  @override
  void initState() {
    super.initState();
    _load();
    AppTheme.themeNotifier.addListener(_onThemeChanged);
  }

  @override
  void dispose() {
    AppTheme.themeNotifier.removeListener(_onThemeChanged);
    super.dispose();
  }

  void _onThemeChanged() {
    if (mounted) setState(() {});
  }

  Future<void> _load() async {
    final saved = await StorageService.loadSelectedMusic();
    final track = defaultPlaylist.firstWhere(
          (t) => t.title == saved,
      orElse: () => defaultPlaylist.first,
    );
    if (!mounted) return;
    setState(() => current = track);
  }

  void _openPlayer() async {
    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => MusicPlayerScreen(initialTrack: current),
      ),
    );
    _load();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: _openPlayer,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          // 👇 INI KUNCINYA: pakai AppTheme.card biar ikut tema
          color: AppTheme.card,
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
            Container(
              width: 54,
              height: 54,
              decoration: BoxDecoration(
                color: current.color.withOpacity(0.2),
                borderRadius: BorderRadius.circular(15),
              ),
              child: Icon(current.icon, color: current.color, size: 26),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    current.title,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 15,
                      // 👇 pakai AppTheme.txt biar dinamis
                      color: AppTheme.txt,
                    ),
                  ),
                  const SizedBox(height: 3),
                  Text(
                    '${current.artist} • Tap to open player',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      // 👇 pakai AppTheme.txtGrey
                      color: AppTheme.txtGrey,
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            ),
            const Icon(
              Icons.play_circle_fill,
              color: AppTheme.primaryTeal,
              size: 38,
            ),
          ],
        ),
      ),
    );
  }
}