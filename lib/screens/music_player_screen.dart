import 'dart:async';
import 'package:flutter/material.dart';
import '../models/music_model.dart';
import '../theme/app_theme.dart';
import '../services/storage_service.dart';

class MusicPlayerScreen extends StatefulWidget {
  final MusicTrack? initialTrack;

  const MusicPlayerScreen({super.key, this.initialTrack});

  @override
  State<MusicPlayerScreen> createState() => _MusicPlayerScreenState();
}

class _MusicPlayerScreenState extends State<MusicPlayerScreen> {
  late List<MusicTrack> playlist;
  late int currentIndex;
  bool isPlaying = false;
  int elapsedSeconds = 0;
  Timer? _ticker;

  @override
  void initState() {
    super.initState();
    playlist = List.from(defaultPlaylist);
    currentIndex = widget.initialTrack != null
        ? playlist.indexWhere((t) => t.title == widget.initialTrack!.title)
        : 0;
    if (currentIndex < 0) currentIndex = 0;
    _loadSaved();
  }

  Future<void> _loadSaved() async {
    final saved = await StorageService.loadSelectedMusic();
    final idx = playlist.indexWhere((t) => t.title == saved);
    if (idx >= 0 && mounted) {
      setState(() => currentIndex = idx);
    }
  }

  @override
  void dispose() {
    _ticker?.cancel();
    super.dispose();
  }

  MusicTrack get current => playlist[currentIndex];

  void _startTicker() {
    _ticker?.cancel();
    _ticker = Timer.periodic(const Duration(seconds: 1), (_) {
      if (elapsedSeconds >= current.durationSeconds) {
        _next();
      } else {
        setState(() => elapsedSeconds++);
      }
    });
  }

  void _togglePlay() {
    setState(() => isPlaying = !isPlaying);
    if (isPlaying) {
      _startTicker();
    } else {
      _ticker?.cancel();
    }
    StorageService.saveSelectedMusic(current.title);
  }

  void _next() {
    setState(() {
      currentIndex = (currentIndex + 1) % playlist.length;
      elapsedSeconds = 0;
    });
    if (isPlaying) _startTicker();
    StorageService.saveSelectedMusic(current.title);
  }

  void _prev() {
    setState(() {
      currentIndex =
          (currentIndex - 1 + playlist.length) % playlist.length;
      elapsedSeconds = 0;
    });
    if (isPlaying) _startTicker();
    StorageService.saveSelectedMusic(current.title);
  }

  void _selectTrack(int index) {
    setState(() {
      currentIndex = index;
      elapsedSeconds = 0;
      isPlaying = false;
    });
    _ticker?.cancel();
    StorageService.saveSelectedMusic(current.title);
  }

  String _fmt(int s) {
    final m = (s ~/ 60).toString().padLeft(2, '0');
    final sec = (s % 60).toString().padLeft(2, '0');
    return '$m:$sec';
  }

  @override
  Widget build(BuildContext context) {
    final progress = elapsedSeconds / current.durationSeconds;
    return Scaffold(
      backgroundColor: AppTheme.bg,
      appBar: AppBar(
        title: const Text('Music Player'),
        backgroundColor: Colors.transparent,
      ),
      body: SafeArea(
        child: Column(
          children: [
            const SizedBox(height: 10),
            Container(
              width: 220,
              height: 220,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    current.color,
                    current.color.withOpacity(0.5),
                  ],
                ),
                borderRadius: BorderRadius.circular(30),
                boxShadow: [
                  BoxShadow(
                    color: current.color.withOpacity(0.4),
                    blurRadius: 30,
                    offset: const Offset(0, 10),
                  ),
                ],
              ),
              child: Icon(current.icon, size: 100, color: Colors.white),
            ),
            const SizedBox(height: 25),
            Text(
              current.title,
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
                color: AppTheme.txt,
              ),
            ),
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
                      value: progress.clamp(0.0, 1.0),
                      minHeight: 6,
                      backgroundColor: AppTheme.lightTeal,
                      color: current.color,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(_fmt(elapsedSeconds),
                          style: TextStyle(
                              fontSize: 12, color: AppTheme.txtGrey)),
                      Text(current.duration,
                          style: TextStyle(
                              fontSize: 12, color: AppTheme.txtGrey)),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                IconButton(
                  iconSize: 40,
                  onPressed: _prev,
                  icon: Icon(Icons.skip_previous, color: AppTheme.txt),
                ),
                const SizedBox(width: 15),
                Container(
                  decoration: BoxDecoration(
                    color: current.color,
                    shape: BoxShape.circle,
                  ),
                  child: IconButton(
                    iconSize: 45,
                    onPressed: _togglePlay,
                    icon: Icon(
                      isPlaying ? Icons.pause : Icons.play_arrow,
                      color: Colors.white,
                    ),
                  ),
                ),
                const SizedBox(width: 15),
                IconButton(
                  iconSize: 40,
                  onPressed: _next,
                  icon: Icon(Icons.skip_next, color: AppTheme.txt),
                ),
              ],
            ),
            const SizedBox(height: 20),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Row(
                children: [
                  Text(
                    'Playlist (${playlist.length})',
                    style: TextStyle(
                      fontSize: 17,
                      fontWeight: FontWeight.bold,
                      color: AppTheme.txt,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 10),
            Expanded(
              child: ListView.builder(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                itemCount: playlist.length,
                itemBuilder: (context, i) {
                  final track = playlist[i];
                  final isCurrent = i == currentIndex;
                  return GestureDetector(
                    onTap: () => _selectTrack(i),
                    child: Container(
                      margin: const EdgeInsets.only(bottom: 8),
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: isCurrent
                            ? current.color.withOpacity(0.15)
                            : AppTheme.card,
                        borderRadius: BorderRadius.circular(14),
                        border: isCurrent
                            ? Border.all(
                            color: current.color, width: 1.5)
                            : null,
                      ),
                      child: Row(
                        children: [
                          Container(
                            width: 45,
                            height: 45,
                            decoration: BoxDecoration(
                              color: track.color.withOpacity(0.2),
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: Icon(track.icon, color: track.color),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  track.title,
                                  style: TextStyle(
                                    fontWeight: isCurrent
                                        ? FontWeight.bold
                                        : FontWeight.w600,
                                    color: isCurrent
                                        ? current.color
                                        : AppTheme.txt,
                                  ),
                                ),
                                const SizedBox(height: 3),
                                Text(
                                  track.artist,
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: AppTheme.txtGrey,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          Text(
                            track.duration,
                            style: TextStyle(
                              fontSize: 12,
                              color: AppTheme.txtGrey,
                            ),
                          ),
                          if (isCurrent && isPlaying) ...[
                            const SizedBox(width: 8),
                            Icon(
                              Icons.graphic_eq,
                              color: current.color,
                              size: 18,
                            ),
                          ],
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
}