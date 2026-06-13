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

  static Color get bg => isDark ? const Color(0xFF120D0A) : const Color(0xFFFFF7F3);
  static Color get surface => isDark ? const Color(0xFF1B1511) : const Color(0xFFFFFFFF);
  static Color get card => isDark ? const Color(0xFF241B17) : const Color(0xFFFFFFFF);
  static Color get cardHigh => isDark ? const Color(0xFF30231D) : const Color(0xFFFFE8E2);

  static Color get border => isDark ? const Color(0xFF413028) : const Color(0xFFF7CDC2);
  static Color get textPrimary => isDark ? const Color(0xFFFFF7F0) : const Color(0xFF291A14);
  static Color get textSecondary => isDark ? const Color(0xFFD8BFB3) : const Color(0xFF725A50);
  static Color get textMuted => isDark ? const Color(0xFFAA9186) : const Color(0xFFB19184);
  static Color get glow => isDark ? const Color(0xFFFF8A5C) : const Color(0xFFFFB08F);

  static Color get bgLight => const Color(0xFFFFF7F3);
  static Color get surfaceLight => const Color(0xFFFFFFFF);
  static Color get cardLight => const Color(0xFFFFFFFF);
  static Color get cardHighLight => const Color(0xFFFFE8E2);

  static Color get textDark => const Color(0xFF291A14);
  static Color get textDarkSecondary => const Color(0xFF725A50);
  static Color get textDarkMuted => const Color(0xFFB19184);
  static Color get borderLight => const Color(0xFFF7CDC2);
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
  static const _darkOutline = Color(0xFF413028);
  static const _lightOutline = Color(0xFFF7CDC2);

  static ThemeData get darkTheme {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      scaffoldBackgroundColor: AppColors.bg,
      colorScheme: const ColorScheme.dark(
        primary: AppColors.red,
        secondary: AppColors.orange,
        primaryContainer: Color(0xFFCC2E26),
        secondaryContainer: Color(0xFF5A2C1B),
        surface: Color(0xFF1B1511),
        outline: _darkOutline,
        onPrimary: AppColors.white,
        onSecondary: Color(0xFFFFF7F0),
        onSurface: Color(0xFFFFF7F0),
      ),
      textTheme: GoogleFonts.interTextTheme(
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
      appBarTheme: const AppBarTheme(
        backgroundColor: Color(0xFF120D0A),
        elevation: 0,
        surfaceTintColor: Colors.transparent,
        iconTheme: IconThemeData(color: Color(0xFFFFF7F0)),
        titleTextStyle: TextStyle(
          color: Color(0xFFFFF7F0),
          fontSize: 18,
          fontWeight: FontWeight.w600,
        ),
      ),
      cardTheme: const CardThemeData(
        color: Color(0xFF241B17),
        elevation: 0,
        shadowColor: Colors.transparent,
      ).copyWith(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: BorderSide(color: _darkOutline),
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.red,
          foregroundColor: AppColors.white,
          elevation: 2,
          padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 15),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: const Color(0xFF1B1511),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide(color: _darkOutline),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide(color: _darkOutline),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide(color: AppColors.red),
        ),
        hintStyle: TextStyle(color: AppColors.textMuted),
      ),
      dividerColor: _darkOutline,
      shadowColor: const Color(0x2A000000),
      switchTheme: SwitchThemeData(
        thumbColor: MaterialStateProperty.resolveWith((states) {
          if (states.contains(MaterialState.selected)) return AppColors.red;
          return AppColors.textMuted;
        }),
        trackColor: MaterialStateProperty.resolveWith((states) {
          if (states.contains(MaterialState.selected)) {
            return AppColors.red.withValues(alpha: 0.35);
          }
          return AppColors.border;
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
        primary: AppColors.red,
        secondary: AppColors.orange,
        primaryContainer: Color(0xFFFFE1D7),
        secondaryContainer: Color(0xFFFFE8D7),
        surface: Color(0xFFFFFFFF),
        onPrimary: AppColors.white,
        onSecondary: Color(0xFF291A14),
        onSurface: Color(0xFF291A14),
        outline: _lightOutline,
      ),
      textTheme: GoogleFonts.interTextTheme(
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
      appBarTheme: const AppBarTheme(
        backgroundColor: Color(0xFFFFF7F3),
        elevation: 0,
        surfaceTintColor: Colors.transparent,
        shadowColor: Color(0x12000000),
        iconTheme: IconThemeData(color: Color(0xFF291A14)),
        titleTextStyle: TextStyle(
          color: Color(0xFF291A14),
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
          side: BorderSide(color: _lightOutline),
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.red,
          foregroundColor: AppColors.white,
          elevation: 2,
          padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 15),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: const Color(0xFFFFFFFF),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide(color: _lightOutline),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide(color: _lightOutline),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide(color: AppColors.red),
        ),
        hintStyle: TextStyle(color: AppColors.textDarkMuted),
      ),
      dividerColor: _lightOutline,
      shadowColor: const Color(0x14000000),
      switchTheme: SwitchThemeData(
        thumbColor: MaterialStateProperty.resolveWith((states) {
          if (states.contains(MaterialState.selected)) return AppColors.red;
          return const Color(0xFFFFFFFF);
        }),
        trackColor: MaterialStateProperty.resolveWith((states) {
          if (states.contains(MaterialState.selected)) {
            return AppColors.red.withValues(alpha: 0.3);
          }
          return const Color(0xFFFFDDD3);
        }),
      ),
    );
  }
}
