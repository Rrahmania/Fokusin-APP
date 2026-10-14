import 'package:flutter/material.dart';
import '../models/shop_model.dart';
import '../theme/app_theme.dart';

class FramedAvatar extends StatelessWidget {
  final String initial;
  final AvatarFrame frame;
  final double size;

  const FramedAvatar({
    super.key,
    required this.initial,
    required this.frame,
    this.size = 90,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: LinearGradient(
          colors: frame.colors,
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        boxShadow: frame.id != 'default'
            ? [
          BoxShadow(
            color: frame.colors.first.withOpacity(0.5),
            blurRadius: 15,
            spreadRadius: 2,
          ),
        ]
            : [],
      ),
      padding: EdgeInsets.all(size * 0.07),
      child: Container(
        decoration: const BoxDecoration(
          color: Colors.white,
          shape: BoxShape.circle,
        ),
        child: Center(
          child: Text(
            initial,
            style: TextStyle(
              fontSize: size * 0.4,
              fontWeight: FontWeight.bold,
              color: AppTheme.darkTeal,
            ),
          ),
        ),
      ),
    );
  }
}