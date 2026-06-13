import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

// ─── Color Tokens ──────────────────────────────────────────────────────────────
class AppColors {
  static bool isDark = true;

  // ── Brand ─────────────────────────────────────────────────────────────────────
  static const Color brandBlue      = Color(0xFF2563EB);
  static const Color brandBlueDark  = Color(0xFF1D4ED8);
  static const Color brandGreen     = Color(0xFF16A34A);
  static const Color brandGreenLight= Color(0xFF22C55E);
  static const Color accentCyan     = Color(0xFF06B6D4);
  static const Color accentOrange   = Color(0xFFF97316);

  static const Color statusGreen  = Color(0xFF22C55E);
  static const Color statusOrange = Color(0xFFF97316);
  static const Color statusRed    = Color(0xFFEF4444);
  static const Color starYellow   = Color(0xFFFBBF24);

  // ── Dark/Light adaptive getters ─────────────────────────────────────────────
  static Color get bgDark => isDark ? const Color(0xFF0A0E1A) : const Color(0xFFF8F9FA);
  static Color get bgCard => isDark ? const Color(0xFF111827) : const Color(0xFFFFFFFF);
  static Color get bgCardLight => isDark ? const Color(0xFF1A2235) : const Color(0xFFF1F5F9);
  static Color get bgCardMedium => isDark ? const Color(0xFF162032) : const Color(0xFFFFFFFF);

  static Color get textPrimary => isDark ? const Color(0xFFF1F5F9) : const Color(0xFF0F172A);
  static Color get textSecondary => isDark ? const Color(0xFF94A3B8) : const Color(0xFF475569);
  static Color get textMuted => isDark ? const Color(0xFF64748B) : const Color(0xFF94A3B8);
  static Color get textWhite => const Color(0xFFFFFFFF);

  static Color get borderColor => isDark ? const Color(0xFF1E293B) : const Color(0xFFCBD5E1);
  static Color get borderBlue => const Color(0xFF2563EB);

  static Color get gradientStart => isDark ? const Color(0xFF0A0E1A) : const Color(0xFFF8F9FA);
  static Color get gradientEnd => isDark ? const Color(0xFF111827) : const Color(0xFFF1F5F9);

  // Exposing old light names if they were still used
  static Color get bgLight => const Color(0xFFF8F9FA);
  static Color get bgCardLightMode => const Color(0xFFFFFFFF);
  static Color get textDark => const Color(0xFF0F172A);
  static Color get textDarkSecondary => const Color(0xFF475569);
  static Color get textDarkMuted => const Color(0xFF94A3B8);
  static Color get borderLight => const Color(0xFFE2E8F0);
}

// ─── Theme Builder ────────────────────────────────────────────────────────────
class AppTheme {
  // ── DARK ─────────────────────────────────────────────────────────────────────
  static ThemeData get darkTheme {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      scaffoldBackgroundColor: const Color(0xFF0A0E1A),
      colorScheme: const ColorScheme.dark(
        primary: AppColors.brandBlue,
        secondary: AppColors.brandGreen,
        surface: Color(0xFF111827),
        onPrimary: Color(0xFFFFFFFF),
        onSurface: Color(0xFFF1F5F9),
      ),
      textTheme: GoogleFonts.poppinsTextTheme(
        TextTheme(
          displayLarge:  TextStyle(color: Color(0xFFF1F5F9),   fontWeight: FontWeight.w700),
          headlineLarge: TextStyle(color: Color(0xFFF1F5F9),   fontWeight: FontWeight.w700),
          headlineMedium:TextStyle(color: Color(0xFFF1F5F9),   fontWeight: FontWeight.w600),
          titleLarge:    TextStyle(color: Color(0xFFF1F5F9),   fontWeight: FontWeight.w600),
          titleMedium:   TextStyle(color: Color(0xFFF1F5F9),   fontWeight: FontWeight.w500),
          bodyLarge:     TextStyle(color: Color(0xFF94A3B8)),
          bodyMedium:    TextStyle(color: Color(0xFF94A3B8)),
          labelLarge:    TextStyle(color: Color(0xFFF1F5F9),   fontWeight: FontWeight.w600),
        ),
      ),
      bottomNavigationBarTheme: const BottomNavigationBarThemeData(
        backgroundColor: Color(0xFF111827),
        selectedItemColor: AppColors.brandBlue,
        unselectedItemColor: Color(0xFF64748B),
        type: BottomNavigationBarType.fixed,
        elevation: 0,
      ),
      appBarTheme: const AppBarTheme(
        backgroundColor: Color(0xFF0A0E1A),
        elevation: 0,
        iconTheme: IconThemeData(color: Color(0xFFF1F5F9)),
        titleTextStyle: TextStyle(
          color: Color(0xFFF1F5F9),
          fontSize: 18,
          fontWeight: FontWeight.w600,
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: const Color(0xFF111827),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Color(0xFF1E293B)),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Color(0xFF1E293B)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: AppColors.brandBlue, width: 1.5),
        ),
        hintStyle: TextStyle(color: Color(0xFF64748B)),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.brandBlue,
          foregroundColor: Colors.white,
          elevation: 0,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        ),
      ),
      dividerColor: const Color(0xFF1E293B),
      cardColor: const Color(0xFF111827),
    );
  }

  // ── LIGHT (minimalist silver/grey palette) ───────────────────────────────────
  static ThemeData get lightTheme {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.light,
      scaffoldBackgroundColor: const Color(0xFFF8F9FA),
      colorScheme: const ColorScheme.light(
        primary: AppColors.brandBlue,
        secondary: AppColors.brandGreen,
        surface: Color(0xFFFFFFFF),
        onPrimary: Colors.white,
        onSurface: Color(0xFF0F172A),
        outline: Color(0xFFE2E8F0),
      ),
      textTheme: GoogleFonts.poppinsTextTheme(
        TextTheme(
          displayLarge:  TextStyle(color: Color(0xFF0F172A),          fontWeight: FontWeight.w700),
          headlineLarge: TextStyle(color: Color(0xFF0F172A),          fontWeight: FontWeight.w700),
          headlineMedium:TextStyle(color: Color(0xFF0F172A),          fontWeight: FontWeight.w600),
          titleLarge:    TextStyle(color: Color(0xFF0F172A),          fontWeight: FontWeight.w600),
          titleMedium:   TextStyle(color: Color(0xFF0F172A),          fontWeight: FontWeight.w500),
          bodyLarge:     TextStyle(color: Color(0xFF475569)),
          bodyMedium:    TextStyle(color: Color(0xFF475569)),
          labelLarge:    TextStyle(color: Color(0xFF0F172A),          fontWeight: FontWeight.w600),
        ),
      ),
      bottomNavigationBarTheme: const BottomNavigationBarThemeData(
        backgroundColor: Color(0xFFFFFFFF),
        selectedItemColor: AppColors.brandBlue,
        unselectedItemColor: Color(0xFF94A3B8),
        type: BottomNavigationBarType.fixed,
        elevation: 0,
      ),
      appBarTheme: const AppBarTheme(
        backgroundColor: Color(0xFFFFFFFF),
        elevation: 0,
        surfaceTintColor: Colors.transparent,
        shadowColor: Color(0x14000000),
        iconTheme: IconThemeData(color: Color(0xFF0F172A)),
        titleTextStyle: TextStyle(
          color: Color(0xFF0F172A),
          fontSize: 18,
          fontWeight: FontWeight.w600,
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: const Color(0xFFFFFFFF),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Color(0xFFE2E8F0)),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Color(0xFFE2E8F0)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: AppColors.brandBlue, width: 1.5),
        ),
        hintStyle: TextStyle(color: Color(0xFF94A3B8)),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.brandBlue,
          foregroundColor: Colors.white,
          elevation: 0,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        ),
      ),
      dividerColor: const Color(0xFFE2E8F0),
      cardColor: const Color(0xFFFFFFFF),
      shadowColor: const Color(0x0C000000),
    );
  }
}
