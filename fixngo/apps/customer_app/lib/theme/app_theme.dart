import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppColors {
  static bool isDark = true;

  static const Color brandBlue = Color(0xFF2563EB);
  static const Color brandBlueDark = Color(0xFF1D4ED8);
  static const Color brandGreen = Color(0xFF16A34A);
  static const Color brandGreenLight = Color(0xFF22C55E);
  static const Color accentCyan = Color(0xFF06B6D4);
  static const Color accentOrange = Color(0xFFF97316);

  static const Color statusGreen  = Color(0xFF22C55E);
  static const Color statusOrange = Color(0xFFF97316);
  static const Color statusRed    = Color(0xFFEF4444);
  static const Color starYellow   = Color(0xFFFBBF24);

  static Color get bgDark => isDark ? const Color(0xFF07111F) : const Color(0xFFF4F8FF);
  static Color get bgCard => isDark ? const Color(0xFF101C2E) : const Color(0xFFFFFFFF);
  static Color get bgCardLight => isDark ? const Color(0xFF18263C) : const Color(0xFFEAF2FF);
  static Color get bgCardMedium => isDark ? const Color(0xFF132238) : const Color(0xFFF8FBFF);

  static Color get textPrimary => isDark ? const Color(0xFFF8FBFF) : const Color(0xFF10213A);
  static Color get textSecondary => isDark ? const Color(0xFF9DB0C9) : const Color(0xFF51637D);
  static Color get textMuted => isDark ? const Color(0xFF6E84A3) : const Color(0xFF8EA2BF);
  static Color get textWhite => const Color(0xFFFFFFFF);

  static Color get borderColor => isDark ? const Color(0xFF21314C) : const Color(0xFFD5E2F5);
  static Color get borderBlue => const Color(0xFF2563EB);

  static Color get gradientStart => isDark ? const Color(0xFF07111F) : const Color(0xFFF4F8FF);
  static Color get gradientEnd => isDark ? const Color(0xFF10203A) : const Color(0xFFE8F1FF);
  static Color get glassHighlight => isDark ? const Color(0xFF29456C) : const Color(0xFFFFFFFF);
  static Color get primaryGlow => isDark ? const Color(0xFF5DA9FF) : const Color(0xFF93C5FD);

  static Color get bgLight => const Color(0xFFF4F8FF);
  static Color get bgCardLightMode => const Color(0xFFFFFFFF);
  static Color get textDark => const Color(0xFF10213A);
  static Color get textDarkSecondary => const Color(0xFF51637D);
  static Color get textDarkMuted => const Color(0xFF8EA2BF);
  static Color get borderLight => const Color(0xFFD5E2F5);
}

class AppTheme {
  static const _darkOutline = Color(0xFF22344F);
  static const _lightOutline = Color(0xFFD6E3F5);

  static ThemeData get darkTheme {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      scaffoldBackgroundColor: AppColors.bgDark,
      colorScheme: const ColorScheme.dark(
        primary: AppColors.brandBlue,
        primaryContainer: Color(0xFF1D4ED8),
        secondary: AppColors.accentCyan,
        secondaryContainer: Color(0xFF0F766E),
        surface: Color(0xFF101C2E),
        outline: _darkOutline,
        onPrimary: Color(0xFFFFFFFF),
        onSecondary: Color(0xFF07111F),
        onSurface: Color(0xFFF8FBFF),
      ),
      textTheme: GoogleFonts.poppinsTextTheme(
        TextTheme(
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
        backgroundColor: Color(0xFF101C2E),
        selectedItemColor: AppColors.brandBlue,
        unselectedItemColor: Color(0xFF6E84A3),
        type: BottomNavigationBarType.fixed,
        elevation: 0,
      ),
      appBarTheme: const AppBarTheme(
        backgroundColor: Color(0xFF07111F),
        elevation: 0,
        surfaceTintColor: Colors.transparent,
        iconTheme: IconThemeData(color: Color(0xFFF8FBFF)),
        titleTextStyle: TextStyle(
          color: Color(0xFFF8FBFF),
          fontSize: 18,
          fontWeight: FontWeight.w600,
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: const Color(0xFF101C2E),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: _darkOutline),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: _darkOutline),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: AppColors.brandBlue, width: 1.5),
        ),
        hintStyle: TextStyle(color: AppColors.textMuted),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.brandBlue,
          foregroundColor: Colors.white,
          elevation: 2,
          padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        ),
      ),
      cardTheme: CardThemeData(
        color: AppColors.bgCard,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(18),
          side: const BorderSide(color: _darkOutline),
        ),
      ),
      dividerColor: _darkOutline,
      cardColor: AppColors.bgCard,
      shadowColor: const Color(0x26000000),
      switchTheme: SwitchThemeData(
        thumbColor: MaterialStateProperty.resolveWith((states) {
          if (states.contains(MaterialState.selected)) return AppColors.brandBlue;
          return AppColors.textMuted;
        }),
        trackColor: MaterialStateProperty.resolveWith((states) {
          if (states.contains(MaterialState.selected)) {
            return AppColors.brandBlue.withValues(alpha: 0.4);
          }
          return AppColors.borderColor;
        }),
      ),
    );
  }

  static ThemeData get lightTheme {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.light,
      scaffoldBackgroundColor: AppColors.bgLight,
      colorScheme: const ColorScheme.light(
        primary: AppColors.brandBlue,
        primaryContainer: Color(0xFFDCE9FF),
        secondary: AppColors.accentCyan,
        secondaryContainer: Color(0xFFD9FBFF),
        surface: Color(0xFFFFFFFF),
        onPrimary: Colors.white,
        onSecondary: Color(0xFF10213A),
        onSurface: Color(0xFF10213A),
        outline: _lightOutline,
      ),
      textTheme: GoogleFonts.poppinsTextTheme(
        TextTheme(
          displayLarge: TextStyle(color: AppColors.textDark, fontWeight: FontWeight.w700),
          headlineLarge: TextStyle(color: AppColors.textDark, fontWeight: FontWeight.w700),
          headlineMedium: TextStyle(color: AppColors.textDark, fontWeight: FontWeight.w600),
          titleLarge: TextStyle(color: AppColors.textDark, fontWeight: FontWeight.w600),
          titleMedium: TextStyle(color: AppColors.textDark, fontWeight: FontWeight.w500),
          bodyLarge: TextStyle(color: AppColors.textDarkSecondary),
          bodyMedium: TextStyle(color: AppColors.textDarkSecondary),
          labelLarge: TextStyle(color: AppColors.textDark, fontWeight: FontWeight.w600),
        ),
      ),
      bottomNavigationBarTheme: const BottomNavigationBarThemeData(
        backgroundColor: Color(0xFFFFFFFF),
        selectedItemColor: AppColors.brandBlue,
        unselectedItemColor: Color(0xFF8EA2BF),
        type: BottomNavigationBarType.fixed,
        elevation: 0,
      ),
      appBarTheme: const AppBarTheme(
        backgroundColor: Color(0xFFFFFFFF),
        elevation: 0,
        surfaceTintColor: Colors.transparent,
        shadowColor: Color(0x100C2340),
        iconTheme: IconThemeData(color: Color(0xFF10213A)),
        titleTextStyle: TextStyle(
          color: Color(0xFF10213A),
          fontSize: 18,
          fontWeight: FontWeight.w600,
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: const Color(0xFFFFFFFF),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: _lightOutline),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: _lightOutline),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: AppColors.brandBlue, width: 1.5),
        ),
        hintStyle: TextStyle(color: AppColors.textDarkMuted),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.brandBlue,
          foregroundColor: Colors.white,
          elevation: 2,
          padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        ),
      ),
      cardTheme: CardThemeData(
        color: AppColors.bgCardLightMode,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(18),
          side: const BorderSide(color: _lightOutline),
        ),
      ),
      dividerColor: _lightOutline,
      cardColor: const Color(0xFFFFFFFF),
      shadowColor: const Color(0x140C2340),
      switchTheme: SwitchThemeData(
        thumbColor: MaterialStateProperty.resolveWith((states) {
          if (states.contains(MaterialState.selected)) return AppColors.brandBlue;
          return const Color(0xFFFFFFFF);
        }),
        trackColor: MaterialStateProperty.resolveWith((states) {
          if (states.contains(MaterialState.selected)) {
            return AppColors.brandBlue.withValues(alpha: 0.35);
          }
          return const Color(0xFFD7E3F6);
        }),
      ),
    );
  }
}
