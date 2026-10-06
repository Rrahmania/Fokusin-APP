import 'package:flutter/material.dart';

class AppTheme {
  static const Color primaryTeal = Color(0xFF009688);
  static const Color darkTeal = Color(0xFF00796B);
  static const Color lightTeal = Color(0xFFE0F2F1);

  // LIGHT MODE
  static const Color background = Color(0xFFF5FAF9);
  static const Color textDark = Color(0xFF263238);
  static const Color textGrey = Color(0xFF78909C);
  static const Color lightCard = Color(0xFFFFFFFF);

  // DARK MODE
  static const Color darkBackground = Color(0xFF0F1413);
  static const Color darkCard = Color(0xFF1E2423);
  static const Color darkNavBar = Color(0xFF161B1A);
  static const Color darkText = Color(0xFFEEEEEE);
  static const Color darkTextGrey = Color(0xFF9E9E9E);
  static const Color darkDivider = Color(0xFF2A3331);

  static bool isDarkMode = false;
  static final ValueNotifier<bool> themeNotifier =
  ValueNotifier<bool>(false);

  static void setDarkMode(bool value) {
    isDarkMode = value;
    themeNotifier.value = value;
  }

  // DYNAMIC GETTERS
  static Color get bg => isDarkMode ? darkBackground : background;
  static Color get card => isDarkMode ? darkCard : lightCard;
  static Color get txt => isDarkMode ? darkText : textDark;
  static Color get txtGrey => isDarkMode ? darkTextGrey : textGrey;

  static ThemeData get lightTheme => _buildTheme(false);
  static ThemeData get darkTheme => _buildTheme(true);

  static ThemeData _buildTheme(bool dark) {
    final bgColor = dark ? darkBackground : background;
    final cardColor = dark ? darkCard : lightCard;
    final navColor = dark ? darkNavBar : Colors.white;
    final textColor = dark ? darkText : textDark;
    final textGreyColor = dark ? darkTextGrey : textGrey;

    return ThemeData(
      useMaterial3: true,
      brightness: dark ? Brightness.dark : Brightness.light,
      scaffoldBackgroundColor: bgColor,
      canvasColor: bgColor,

      colorScheme: ColorScheme.fromSeed(
        seedColor: primaryTeal,
        primary: primaryTeal,
        secondary: darkTeal,
        brightness: dark ? Brightness.dark : Brightness.light,
        surface: cardColor,
        onSurface: textColor,
        surfaceContainer: navColor,
        surfaceContainerHighest: navColor,
      ),

      appBarTheme: AppBarTheme(
        backgroundColor: bgColor,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        centerTitle: false,
        foregroundColor: textColor,
        iconTheme: IconThemeData(color: textColor),
      ),

      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: cardColor,
        contentPadding:
        const EdgeInsets.symmetric(horizontal: 18, vertical: 17),
        labelStyle: TextStyle(color: textGreyColor),
        hintStyle: TextStyle(color: textGreyColor),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide.none,
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(color: primaryTeal, width: 2),
        ),
        prefixIconColor: primaryTeal,
      ),

      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: primaryTeal,
          foregroundColor: Colors.white,
          minimumSize: const Size(double.infinity, 52),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
        ),
      ),

      cardTheme: CardThemeData(
        color: cardColor,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        margin: const EdgeInsets.only(bottom: 12),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(18),
        ),
      ),

      // ============ NAV BAR ============
      navigationBarTheme: NavigationBarThemeData(
        backgroundColor: navColor,
        surfaceTintColor: Colors.transparent,
        shadowColor: Colors.transparent,
        elevation: 0,
        indicatorColor:
        dark ? primaryTeal.withOpacity(0.25) : lightTeal,
        iconTheme: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return const IconThemeData(color: primaryTeal, size: 24);
          }
          return IconThemeData(color: textGreyColor, size: 24);
        }),
        labelTextStyle: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return const TextStyle(
              color: primaryTeal,
              fontSize: 12,
              fontWeight: FontWeight.w600,
            );
          }
          return TextStyle(
            color: textGreyColor,
            fontSize: 12,
            fontWeight: FontWeight.w500,
          );
        }),
      ),

      // ============ SWITCH THEME (YANG DIPERBAIKI) ============
      switchTheme: SwitchThemeData(
        thumbColor: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return Colors.white; // 👈 putih saat nyala
          }
          // saat mati: bulatan putih dengan sedikit abu
          return dark ? const Color(0xFFB0BEC5) : Colors.white;
        }),
        trackColor: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return primaryTeal; // 👈 teal saat nyala
          }
          // saat mati: abu-abu gelap (terang) / abu-abu sedang (gelap)
          return dark ? const Color(0xFF37474F) : const Color(0xFFBDBDBD);
        }),
        trackOutlineColor: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return Colors.transparent;
          }
          // outline abu tua biar jelas di background putih
          return dark
              ? const Color(0xFF546E7A)
              : const Color(0xFF9E9E9E);
        }),
        trackOutlineWidth: WidgetStateProperty.all(1.5),
        materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
      ),

      dialogTheme: DialogThemeData(
        backgroundColor: cardColor,
        surfaceTintColor: Colors.transparent,
        titleTextStyle: TextStyle(
          color: textColor,
          fontSize: 20,
          fontWeight: FontWeight.bold,
        ),
        contentTextStyle: TextStyle(color: textColor, fontSize: 14),
      ),

      bottomSheetTheme: BottomSheetThemeData(
        backgroundColor: cardColor,
        surfaceTintColor: Colors.transparent,
      ),

      dividerTheme: DividerThemeData(
        color: dark ? darkDivider : Colors.grey.shade300,
      ),

      listTileTheme: ListTileThemeData(
        iconColor: primaryTeal,
        textColor: textColor,
      ),

      snackBarTheme: SnackBarThemeData(
        backgroundColor: darkTeal,
        contentTextStyle: const TextStyle(color: Colors.white),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
      ),

      textTheme: TextTheme(
        bodyLarge: TextStyle(color: textColor),
        bodyMedium: TextStyle(color: textColor),
        bodySmall: TextStyle(color: textGreyColor),
        titleLarge:
        TextStyle(color: textColor, fontWeight: FontWeight.bold),
        titleMedium:
        TextStyle(color: textColor, fontWeight: FontWeight.w600),
        labelLarge: TextStyle(color: textColor),
      ),

      iconTheme: IconThemeData(color: textColor),
    );
  }
}