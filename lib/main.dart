import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'theme/app_theme.dart';
import 'screens/login_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final prefs = await SharedPreferences.getInstance();
  final isDark = prefs.getBool('isDarkMode') ?? false;
  AppTheme.setDarkMode(isDark);
  runApp(const FokusinApp());
}

class FokusinApp extends StatefulWidget {
  const FokusinApp({super.key});

  @override
  State<FokusinApp> createState() => _FokusinAppState();
}

class _FokusinAppState extends State<FokusinApp> {
  @override
  void initState() {
    super.initState();
    AppTheme.themeNotifier.addListener(_refresh);
  }

  @override
  void dispose() {
    AppTheme.themeNotifier.removeListener(_refresh);
    super.dispose();
  }

  void _refresh() {
    if (mounted) setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    final dark = AppTheme.isDarkMode;
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Fokusin',
      theme: dark ? AppTheme.darkTheme : AppTheme.lightTheme,
      themeAnimationDuration: Duration.zero,
      themeAnimationCurve: Curves.linear,
      home: const LoginScreen(),
    );
  }
}