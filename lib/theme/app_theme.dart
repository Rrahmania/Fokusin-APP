import 'package:flutter/material.dart';

class AppTheme {
  static const Color primaryTeal =
  Color(0xFF009688);

  static const Color darkTeal =
  Color(0xFF00796B);

  static const Color lightTeal =
  Color(0xFFE0F2F1);

  static const Color background =
  Color(0xFFF5FAF9);

  static const Color textDark =
  Color(0xFF263238);

  static const Color textGrey =
  Color(0xFF78909C);

  static ThemeData lightTheme =
  ThemeData(
    useMaterial3: true,

    scaffoldBackgroundColor:
    background,

    colorScheme:
    ColorScheme.fromSeed(
      seedColor: primaryTeal,
      primary: primaryTeal,
      secondary: darkTeal,
    ),

    appBarTheme:
    const AppBarTheme(
      backgroundColor: background,
      elevation: 0,
      centerTitle: false,
      foregroundColor: textDark,
    ),

    inputDecorationTheme:
    InputDecorationTheme(
      filled: true,
      fillColor: Colors.white,

      contentPadding:
      const EdgeInsets.symmetric(
        horizontal: 18,
        vertical: 17,
      ),

      border: OutlineInputBorder(
        borderRadius:
        BorderRadius.circular(16),
        borderSide:
        BorderSide.none,
      ),

      enabledBorder:
      OutlineInputBorder(
        borderRadius:
        BorderRadius.circular(16),
        borderSide:
        BorderSide.none,
      ),

      focusedBorder:
      OutlineInputBorder(
        borderRadius:
        BorderRadius.circular(16),
        borderSide:
        const BorderSide(
          color: primaryTeal,
          width: 2,
        ),
      ),

      prefixIconColor:
      primaryTeal,
    ),

    elevatedButtonTheme:
    ElevatedButtonThemeData(
      style:
      ElevatedButton.styleFrom(
        backgroundColor:
        primaryTeal,
        foregroundColor:
        Colors.white,

        minimumSize:
        const Size(
          double.infinity,
          52,
        ),

        shape:
        RoundedRectangleBorder(
          borderRadius:
          BorderRadius.circular(16),
        ),
      ),
    ),

    filledButtonTheme:
    FilledButtonThemeData(
      style:
      FilledButton.styleFrom(
        backgroundColor:
        primaryTeal,
        foregroundColor:
        Colors.white,

        minimumSize:
        const Size(
          double.infinity,
          52,
        ),

        shape:
        RoundedRectangleBorder(
          borderRadius:
          BorderRadius.circular(16),
        ),
      ),
    ),

    cardTheme:
    CardThemeData(
      color: Colors.white,
      elevation: 0,
      margin:
      const EdgeInsets.only(
        bottom: 12,
      ),
      shape:
      RoundedRectangleBorder(
        borderRadius:
        BorderRadius.circular(18),
      ),
    ),

    navigationBarTheme: NavigationBarThemeData(
      backgroundColor: Colors.white,
      indicatorColor: lightTeal,
    ),
  );
}