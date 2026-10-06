import 'package:flutter/material.dart';

class MusicTrack {
  final String title;
  final String artist;
  final String duration;
  final int durationSeconds;
  final IconData icon;
  final Color color;

  MusicTrack({
    required this.title,
    required this.artist,
    required this.duration,
    required this.durationSeconds,
    required this.icon,
    required this.color,
  });
}

final List<MusicTrack> defaultPlaylist = [
  MusicTrack(
    title: 'Rain Sounds',
    artist: 'Nature Sounds',
    duration: '3:45',
    durationSeconds: 225,
    icon: Icons.water_drop,
    color: const Color(0xFF4FC3F7),
  ),
  MusicTrack(
    title: 'Forest Sounds',
    artist: 'Nature Sounds',
    duration: '4:20',
    durationSeconds: 260,
    icon: Icons.forest,
    color: const Color(0xFF66BB6A),
  ),
  MusicTrack(
    title: 'Ocean Waves',
    artist: 'Nature Sounds',
    duration: '5:10',
    durationSeconds: 310,
    icon: Icons.waves,
    color: const Color(0xFF29B6F6),
  ),
  MusicTrack(
    title: 'Piano Relax',
    artist: 'Instrumental',
    duration: '3:30',
    durationSeconds: 210,
    icon: Icons.piano,
    color: const Color(0xFFBA68C8),
  ),
  MusicTrack(
    title: 'Lo-Fi Beats',
    artist: 'Chill Vibes',
    duration: '4:00',
    durationSeconds: 240,
    icon: Icons.headphones,
    color: const Color(0xFFFFB74D),
  ),
  MusicTrack(
    title: 'Coffee Shop',
    artist: 'Ambience',
    duration: '6:00',
    durationSeconds: 360,
    icon: Icons.local_cafe,
    color: const Color(0xFFA1887F),
  ),
  MusicTrack(
    title: 'Fireplace',
    artist: 'Ambience',
    duration: '5:30',
    durationSeconds: 330,
    icon: Icons.local_fire_department,
    color: const Color(0xFFFF7043),
  ),
  MusicTrack(
    title: 'White Noise',
    artist: 'Focus',
    duration: '8:00',
    durationSeconds: 480,
    icon: Icons.graphic_eq,
    color: const Color(0xFF90A4AE),
  ),
];