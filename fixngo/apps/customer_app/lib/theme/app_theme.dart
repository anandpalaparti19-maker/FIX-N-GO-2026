import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppColors {
  // Primary Dark Background
  static const Color bgDark = Color(0xFF0A0E1A);
  static const Color bgCard = Color(0xFF111827);
  static const Color bgCardLight = Color(0xFF1A2235);
  static const Color bgCardMedium = Color(0xFF162032);

  // Brand Colors
  static const Color brandBlue = Color(0xFF2563EB);
  static const Color brandBlueDark = Color(0xFF1D4ED8);
  static const Color brandGreen = Color(0xFF16A34A);
  static const Color brandGreenLight = Color(0xFF22C55E);
  static const Color accentCyan = Color(0xFF06B6D4);
  static const Color accentOrange = Color(0xFFF97316);

  // Text Colors
  static const Color textPrimary = Color(0xFFF1F5F9);
  static const Color textSecondary = Color(0xFF94A3B8);
  static const Color textMuted = Color(0xFF64748B);
  static const Color textWhite = Color(0xFFFFFFFF);

  // Status Colors
  static const Color statusGreen = Color(0xFF22C55E);
  static const Color statusOrange = Color(0xFFF97316);
  static const Color statusRed = Color(0xFFEF4444);
  static const Color starYellow = Color(0xFFFBBF24);

  // Border Colors
  static const Color borderColor = Color(0xFF1E293B);
  static const Color borderBlue = Color(0xFF2563EB);

  // Gradient Colors
  static const Color gradientStart = Color(0xFF0A0E1A);
  static const Color gradientEnd = Color(0xFF111827);
}

class AppTheme {
  static ThemeData get darkTheme {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      scaffoldBackgroundColor: AppColors.bgDark,
      colorScheme: const ColorScheme.dark(
        primary: AppColors.brandBlue,
        secondary: AppColors.brandGreen,
        surface: AppColors.bgCard,
        onPrimary: AppColors.textWhite,
        onSurface: AppColors.textPrimary,
      ),
      textTheme: GoogleFonts.poppinsTextTheme(
        const TextTheme(
          displayLarge: TextStyle(color: AppColors.textPrimary, fontWeight: FontWeight.w700),
          headlineLarge: TextStyle(color: AppColors.textPrimary, fontWeight: FontWeight.w700),
          headlineMedium: TextStyle(color: AppColors.textPrimary, fontWeight: FontWeight.w600),
          titleLarge: TextStyle(color: AppColors.textPrimary, fontWeight: FontWeight.w600),
          titleMedium: TextStyle(color: AppColors.textPrimary, fontWeight: FontWeight.w500),
          bodyLarge: TextStyle(color: AppColors.textSecondary),
          bodyMedium: TextStyle(color: AppColors.textSecondary),
          labelLarge: TextStyle(color: AppColors.textPrimary, fontWeight: FontWeight.w600),
        ),
      ),
      bottomNavigationBarTheme: const BottomNavigationBarThemeData(
        backgroundColor: AppColors.bgCard,
        selectedItemColor: AppColors.brandBlue,
        unselectedItemColor: AppColors.textMuted,
        type: BottomNavigationBarType.fixed,
        elevation: 0,
      ),
      appBarTheme: const AppBarTheme(
        backgroundColor: AppColors.bgDark,
        elevation: 0,
        iconTheme: IconThemeData(color: AppColors.textPrimary),
        titleTextStyle: TextStyle(
          color: AppColors.textPrimary,
          fontSize: 18,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}
