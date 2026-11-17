import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppTheme {
  static const List<Map<String, dynamic>> colorThemes = [
    {'primary': Color(0xFF2C5F51), 'dark': Color(0xFF1E4238), 'name': 'Emerald'},
    {'primary': Color(0xFF3F51B5), 'dark': Color(0xFF283593), 'name': 'Indigo'},
    {'primary': Color(0xFFD32F2F), 'dark': Color(0xFFB71C1C), 'name': 'Crimson'},
    {'primary': Color(0xFF8E24AA), 'dark': Color(0xFF4A148C), 'name': 'Royal Purple'},
    {'primary': Color(0xFFF57C00), 'dark': Color(0xFFE65100), 'name': 'Amber'},
    // 5 Warna Soft Baru:
    {'primary': Color(0xFF4A90E2), 'dark': Color(0xFF2E5E99), 'name': 'Soft Blue'},
    {'primary': Color(0xFFD16BA5), 'dark': Color(0xFF8F4470), 'name': 'Soft Rose'},
    {'primary': Color(0xFF48B59A), 'dark': Color(0xFF2E7A67), 'name': 'Soft Mint'},
    {'primary': Color(0xFFE29B4A), 'dark': Color(0xFF99662E), 'name': 'Soft Peach'},
    {'primary': Color(0xFF9B7EDE), 'dark': Color(0xFF634D99), 'name': 'Soft Lavender'},
  ];

  static int _themeColorIndex = 0;
  static final ValueNotifier<int> colorNotifier = ValueNotifier<int>(0);

  static void setThemeColorIndex(int index) {
    _themeColorIndex = index;
    colorNotifier.value = index;
  }

  static Color get primary => colorThemes[_themeColorIndex]['primary'] as Color;
  static Color get darkTeal => colorThemes[_themeColorIndex]['dark'] as Color;
  static const Color accent = Color(0xFFE8A87C);

  static const Color lightBg = Color(0xFFF9F7F3);
  static const Color lightCard = Color(0xFFFFFFFF);
  static const Color lightText = Color(0xFF1E1E1E);
  static const Color lightTextGrey = Color(0xFF8A8A8A);
  static const Color lightBorder = Color(0xFFEBE6E0);

  static const Color darkBg = Color(0xFF0F1110);
  static const Color darkCard = Color(0xFF1A1D1C);
  static const Color darkText = Color(0xFFF2F2F2);
  static const Color darkTextGrey = Color(0xFF9E9E9E);
  static const Color darkBorder = Color(0xFF2A2E2D);

  static bool isDarkMode = false;
  static final ValueNotifier<bool> themeNotifier = ValueNotifier<bool>(false);

  static void setDarkMode(bool value) {
    isDarkMode = value;
    themeNotifier.value = value;
  }

  static Color get bg => isDarkMode ? darkBg : lightBg;
  static Color get card => isDarkMode ? darkCard : lightCard;
  static Color get txt => isDarkMode ? darkText : lightText;
  static Color get txtGrey => isDarkMode ? darkTextGrey : lightTextGrey;
  static Color get border => isDarkMode ? darkBorder : lightBorder;

  static Color get primaryTeal => primary;
  static Color get lightTeal => isDarkMode ? primary.withValues(alpha: 0.2) : primary.withValues(alpha: 0.1);
  static Color get textGrey => txtGrey;

  static ThemeData get lightTheme => _buildTheme(false);
  static ThemeData get darkTheme => _buildTheme(true);

  static ThemeData _buildTheme(bool dark) {
    final String fontFamily = GoogleFonts.plusJakartaSans().fontFamily!;

    return ThemeData(
      useMaterial3: true,
      brightness: dark ? Brightness.dark : Brightness.light,
      scaffoldBackgroundColor: bg,
      canvasColor: bg,
      fontFamily: fontFamily,

      colorScheme: ColorScheme.fromSeed(
        seedColor: primary,
        brightness: dark ? Brightness.dark : Brightness.light,
        surface: card,
        onSurface: txt,
      ),

      appBarTheme: AppBarTheme(
        backgroundColor: bg,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        centerTitle: false,
        iconTheme: IconThemeData(color: txt),
        titleTextStyle: TextStyle(fontFamily: fontFamily, color: txt, fontSize: 20, fontWeight: FontWeight.bold),
      ),

      cardTheme: CardThemeData(
        color: card,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        margin: const EdgeInsets.only(bottom: 16),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(24),
          side: BorderSide(color: border, width: 1.5),
        ),
      ),

      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: card,
        contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
        labelStyle: TextStyle(color: txtGrey, fontFamily: fontFamily),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: BorderSide(color: border, width: 1.5)),
        enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: BorderSide(color: border, width: 1.5)),
        focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: BorderSide(color: primary, width: 2)),
      ),

      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: primary,
          foregroundColor: Colors.white,
          elevation: 0,
          minimumSize: const Size(double.infinity, 56),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          textStyle: TextStyle(fontFamily: fontFamily, fontWeight: FontWeight.bold, letterSpacing: 0.5),
        ),
      ),
    );
  }
}