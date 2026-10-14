import 'package:flutter/material.dart';

class AvatarFrame {
  final String id;
  final String name;
  final int price;
  final List<Color> colors;

  const AvatarFrame({
    required this.id,
    required this.name,
    required this.price,
    required this.colors,
  });
}

// Daftar semua frame yang tersedia
final List<AvatarFrame> avatarFrames = [
  const AvatarFrame(
    id: 'default',
    name: 'Default',
    price: 0,
    colors: [Color(0xFFE0E0E0), Color(0xFFBDBDBD)],
  ),
  const AvatarFrame(
    id: 'gold',
    name: 'Gold Frame',
    price: 150,
    colors: [Color(0xFFFFD700), Color(0xFFFF8F00)],
  ),
  const AvatarFrame(
    id: 'ruby',
    name: 'Ruby Frame',
    price: 350,
    colors: [Color(0xFFFF5252), Color(0xFFB71C1C)],
  ),
  const AvatarFrame(
    id: 'royal',
    name: 'Royal Frame',
    price: 500,
    colors: [Color(0xFF9C27B0), Color(0xFF3F51B5)],
  ),
  const AvatarFrame(
    id: 'rainbow',
    name: 'Rainbow Frame',
    price: 800,
    colors: [
      Color(0xFFFF1744),
      Color(0xFFFF9100),
      Color(0xFFFFEA00),
      Color(0xFF00E676),
      Color(0xFF00B0FF),
      Color(0xFFAA00FF),
    ],
  ),
];

AvatarFrame getFrameById(String id) {
  return avatarFrames.firstWhere(
        (f) => f.id == id,
    orElse: () => avatarFrames.first,
  );
}