import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppColors {
  static bool isDark = true;

  static const Color red = Color(0xFFFF3B30);
  static const Color redDark = Color(0xFFCC2E26);
  static const Color orange = Color(0xFFFF6B35);
  static const Color green = Color(0xFF00C853);
  static const Color greenDark = Color(0xFF00A843);
  static const Color yellow = Color(0xFFFFD60A);
  
  static const Color white = Colors.white;
  static const Color grey = Color(0xFF888898);
  static const Color greyLight = Color(0xFFAAAAAB);
  
  static const Color online = Color(0xFF00C853);
  static const Color offline = Color(0xFF888898);

  // ── Dark/Light adaptive getters ─────────────────────────────────────────────
  static Color get bg => isDark ? const Color(0xFF0A0A0F) : const Color(0xFFFFF5F5);
  static Color get surface => isDark ? const Color(0xFF131318) : const Color(0xFFFFFFFF);
  static Color get card => isDark ? const Color(0xFF1C1C24) : const Color(0xFFFFFFFF);
  static Color get cardHigh => isDark ? const Color(0xFF22222C) : const Color(0xFFFEE2E2);

  static Color get border => isDark ? const Color(0xFF2A2A35) : const Color(0xFFFECACA);

  // Exposing old light names
  static Color get bgLight => const Color(0xFFFFF5F5);
  static Color get surfaceLight => const Color(0xFFFFFFFF);
  static Color get cardLight => const Color(0xFFFFFFFF);
  static Color get cardHighLight => const Color(0xFFFEE2E2);

  static Color get textDark => const Color(0xFF1C1917);
  static Color get textDarkSecondary => const Color(0xFF57534E);
  static Color get textDarkMuted => const Color(0xFFA8A29E);
  static Color get borderLight => const Color(0xFFFECACA);
}

class AppShadows {
  static const List<BoxShadow> card = [
    BoxShadow(
      color: Color(0x33000000),
      blurRadius: 20,
      offset: Offset(0, 8),
    ),
  ];

  static const List<BoxShadow> cardLight = [
    BoxShadow(
      color: Color(0x1AFF3B30),
      blurRadius: 20,
      offset: Offset(0, 8),
    ),
  ];

  static const List<BoxShadow> red = [
    BoxShadow(
      color: Color(0x55FF3B30),
      blurRadius: 24,
      offset: Offset(0, 8),
    ),
  ];

  static const List<BoxShadow> green = [
    BoxShadow(
      color: Color(0x5500C853),
      blurRadius: 24,
      offset: Offset(0, 8),
    ),
  ];
}

class AppTheme {
  // ── DARK ─────────────────────────────────────────────────────────────────────
  static ThemeData get darkTheme {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      scaffoldBackgroundColor: const Color(0xFF0A0A0F),
      colorScheme: const ColorScheme.dark(
        primary: AppColors.red,
        secondary: AppColors.orange,
        surface: Color(0xFF131318),
        onPrimary: AppColors.white,
        onSurface: AppColors.white,
      ),
      textTheme: GoogleFonts.interTextTheme(
        TextTheme(
          displayLarge: TextStyle(color: AppColors.white, fontWeight: FontWeight.w700),
          headlineLarge: TextStyle(color: AppColors.white, fontWeight: FontWeight.w700),
          headlineMedium: TextStyle(color: AppColors.white, fontWeight: FontWeight.w600),
          titleLarge: TextStyle(color: AppColors.white, fontWeight: FontWeight.w600),
          titleMedium: TextStyle(color: AppColors.white, fontWeight: FontWeight.w500),
          bodyLarge: TextStyle(color: AppColors.greyLight),
          bodyMedium: TextStyle(color: AppColors.greyLight),
          labelLarge: TextStyle(color: AppColors.white, fontWeight: FontWeight.w600),
        ),
      ),
      appBarTheme: const AppBarTheme(
        backgroundColor: Color(0xFF0A0A0F),
        elevation: 0,
        iconTheme: IconThemeData(color: AppColors.white),
        titleTextStyle: TextStyle(
          color: AppColors.white,
          fontSize: 18,
          fontWeight: FontWeight.w600,
        ),
      ),
      cardTheme: const CardThemeData(
        color: Color(0xFF1C1C24),
        elevation: 0,
        shadowColor: Colors.transparent,
      ).copyWith(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: BorderSide(color: Color(0xFF2A2A35)),
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.red,
          foregroundColor: AppColors.white,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: const Color(0xFF131318),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide(color: Color(0xFF2A2A35)),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide(color: Color(0xFF2A2A35)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide(color: AppColors.red),
        ),
      ),
    );
  }

  // ── LIGHT (technician red palette) ──────────────────────────────────────────
  static ThemeData get lightTheme {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.light,
      scaffoldBackgroundColor: const Color(0xFFFFF5F5),
      colorScheme: const ColorScheme.light(
        primary: AppColors.red,
        secondary: AppColors.orange,
        surface: Color(0xFFFFFFFF),
        onPrimary: AppColors.white,
        onSurface: Color(0xFF1C1917),
        outline: Color(0xFFFECACA),
      ),
      textTheme: GoogleFonts.interTextTheme(
        TextTheme(
          displayLarge: TextStyle(color: Color(0xFF1C1917), fontWeight: FontWeight.w700),
          headlineLarge: TextStyle(color: Color(0xFF1C1917), fontWeight: FontWeight.w700),
          headlineMedium: TextStyle(color: Color(0xFF1C1917), fontWeight: FontWeight.w600),
          titleLarge: TextStyle(color: Color(0xFF1C1917), fontWeight: FontWeight.w600),
          titleMedium: TextStyle(color: Color(0xFF1C1917), fontWeight: FontWeight.w500),
          bodyLarge: TextStyle(color: Color(0xFF57534E)),
          bodyMedium: TextStyle(color: Color(0xFF57534E)),
          labelLarge: TextStyle(color: Color(0xFF1C1917), fontWeight: FontWeight.w600),
        ),
      ),
      appBarTheme: const AppBarTheme(
        backgroundColor: Color(0xFFFFF5F5),
        elevation: 0,
        surfaceTintColor: Colors.transparent,
        shadowColor: Color(0x14000000),
        iconTheme: IconThemeData(color: Color(0xFF1C1917)),
        titleTextStyle: TextStyle(
          color: Color(0xFF1C1917),
          fontSize: 18,
          fontWeight: FontWeight.w600,
        ),
      ),
      cardTheme: const CardThemeData(
        color: Color(0xFFFFFFFF),
        elevation: 0,
        shadowColor: Colors.transparent,
      ).copyWith(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: BorderSide(color: Color(0xFFFECACA)),
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.red,
          foregroundColor: AppColors.white,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: const Color(0xFFFFFFFF),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide(color: Color(0xFFFECACA)),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide(color: Color(0xFFFECACA)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide(color: AppColors.red),
        ),
        hintStyle: TextStyle(color: Color(0xFFA8A29E)),
      ),
    );
  }
}