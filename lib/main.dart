import 'package:flutter/material.dart';

import 'theme/app_theme.dart';
import 'screens/login_screen.dart';

void main() {
  runApp(const FokusinApp());
}

class FokusinApp extends StatelessWidget {
  const FokusinApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,

      title: 'Fokusin',

      theme: AppTheme.lightTheme,

      home: const LoginScreen(),
    );
  }
}