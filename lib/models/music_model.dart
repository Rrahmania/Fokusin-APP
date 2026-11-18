import 'package:flutter/material.dart';

class MusicTrack {
  final String title;
  final String artist;
  final String duration;
  final int durationSeconds;
  final IconData icon;
  final Color color;
  final int price; // 0 = Gratis
  final String filePath;

  MusicTrack({
    required this.title,
    required this.artist,
    required this.duration,
    required this.durationSeconds,
    required this.icon,
    required this.color,
    required this.filePath,
    this.price = 0, // Default gratis
  });

  String toStorageString() {
    return '$title|$artist|$duration|$durationSeconds|${color.toARGB32()}|$requiredXp|$filePath';
  }

  static MusicTrack fromStorageString(String str) {
    final parts = str.split('|');
    if (parts.length >= 7) {
      return MusicTrack(
        title: parts[0],
        artist: parts[1],
        duration: parts[2],
        durationSeconds: int.tryParse(parts[3]) ?? 180,
        color: Color(int.tryParse(parts[4]) ?? 0xFF4FC3F7),
        icon: Icons.music_note,
        requiredXp: int.tryParse(parts[5]) ?? 0,
        filePath: parts[6],
      );
    }
    return MusicTrack(
      title: parts.isNotEmpty ? parts[0] : 'Custom Track',
      artist: parts.length > 1 ? parts[1] : 'Admin',
      duration: '3:00',
      durationSeconds: 180,
      icon: Icons.music_note,
      color: const Color(0xFF4FC3F7),
      filePath: 'music/piano.mp3',
    );
  }
}

final List<MusicTrack> defaultPlaylist = [
  // 4 MUSIK GRATIS
  MusicTrack(title: 'Rain Sounds', artist: 'Nature', duration: '3:24', durationSeconds: 204, icon: Icons.water_drop, color: const Color(0xFF4FC3F7), filePath: 'music/Rain.mp3', price: 0),
  MusicTrack(title: 'Forest Sounds', artist: 'Nature', duration: '2:57', durationSeconds: 177, icon: Icons.forest, color: const Color(0xFF66BB6A), filePath: 'music/forest.mp3', price: 0),
  MusicTrack(title: 'Ocean Waves', artist: 'Nature', duration: '2:11', durationSeconds: 131, icon: Icons.waves, color: const Color(0xFF29B6F6), filePath: 'music/ocean.mp3', price: 0),
  MusicTrack(title: 'Piano Relax', artist: 'Instrumental', duration: '2:02', durationSeconds: 122, icon: Icons.piano, color: const Color(0xFFBA68C8), filePath: 'music/piano.mp3', price: 0),

  // 4 MUSIK PREMIUM (30 XP)
  MusicTrack(title: 'Lo-Fi Beats', artist: 'Chill Vibes', duration: '2:24', durationSeconds: 144, icon: Icons.headphones, color: const Color(0xFFFFB74D), filePath: 'music/lo-fi_beats.mp3', price: 30),
  MusicTrack(title: 'Coffee Shop', artist: 'Ambience', duration: '2:44', durationSeconds: 164, icon: Icons.local_cafe, color: const Color(0xFFA1887F), filePath: 'music/coffe.mp3', price: 30),
  MusicTrack(title: 'Fireplace', artist: 'Ambience', duration: '4:55', durationSeconds: 295, icon: Icons.local_fire_department, color: const Color(0xFFFF7043), filePath: 'music/fireplace.mp3', price: 30),
  MusicTrack(title: 'White Noise', artist: 'Focus', duration: '2:54', durationSeconds: 174, icon: Icons.graphic_eq, color: const Color(0xFF90A4AE), filePath: 'music/white_noise.mp3', price: 30),
];