import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppTheme {
  // Core Colors
  static const Color bgDark = Color(0xFF0A0E1A);
  static const Color bgCard = Color(0xFF131927);
  static const Color bgCardLight = Color(0xFF1A2235);
  static const Color accentBlue = Color(0xFF2563EB);
  static const Color accentGreen = Color(0xFF16A34A);
  static const Color accentGreenBright = Color(0xFF22C55E);
  static const Color accentOrange = Color(0xFFF97316);
  static const Color accentYellow = Color(0xFFEAB308);
  static const Color textPrimary = Color(0xFFFFFFFF);
  static const Color textSecondary = Color(0xFF94A3B8);
  static const Color textMuted = Color(0xFF64748B);
  static const Color borderColor = Color(0xFF1E2D45);
  static const Color selectedBorder = Color(0xFF3B82F6);
  static const Color divider = Color(0xFF1E293B);

  static ThemeData get darkTheme {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      scaffoldBackgroundColor: bgDark,
      colorScheme: const ColorScheme.dark(
        primary: accentBlue,
        secondary: accentGreen,
        surface: bgCard,
        background: bgDark,
      ),
      textTheme: GoogleFonts.poppinsTextTheme(ThemeData.dark().textTheme),
      appBarTheme: const AppBarTheme(
        backgroundColor: bgDark,
        elevation: 0,
        iconTheme: IconThemeData(color: textPrimary),
        titleTextStyle: TextStyle(
          color: textPrimary,
          fontSize: 18,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}
