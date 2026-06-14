import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

// ─── Color Tokens (Navy + Gold palette matching FixTech logo) ───────────────
class AppColors {
  static bool isDark = true;

  // ── Brand — derived from FixTech logo ─────────────────────────────────────
  static const Color amber      = Color(0xFFF5B731);
  static const Color amberDark  = Color(0xFFD9A028);
  static const Color amberLight = Color(0xFFFFCC4D);
  static const Color navy       = Color(0xFF2C3550);
  static const Color navyDeep   = Color(0xFF1A2238);

  // ── Semantic ──────────────────────────────────────────────────────────────
  static const Color green      = Color(0xFF00C853);
  static const Color greenDark  = Color(0xFF00A843);
  static const Color orange     = Color(0xFFFF6B35);
  static const Color red        = Color(0xFFEF4444);
  static const Color yellow     = Color(0xFFFFD60A);

  static const Color white      = Colors.white;
  static const Color grey       = Color(0xFF8896AB);
  static const Color greyLight  = Color(0xFFAAB4C4);

  static const Color online     = Color(0xFF00C853);
  static const Color offline    = Color(0xFF8896AB);

  // ── Dark/Light adaptive getters ───────────────────────────────────────────
  static Color get bg        => isDark ? const Color(0xFF0D1117) : const Color(0xFFF5F3EF);
  static Color get surface   => isDark ? const Color(0xFF151B28) : const Color(0xFFFFFFFF);
  static Color get card      => isDark ? const Color(0xFF1C2333) : const Color(0xFFFFFFFF);
  static Color get cardHigh  => isDark ? const Color(0xFF232B3E) : const Color(0xFFFFF8E7);

  static Color get border    => isDark ? const Color(0xFF2A3448) : const Color(0xFFE8DFD0);

  static Color get textPrimary   => isDark ? const Color(0xFFF1F5F9) : const Color(0xFF1A2238);
  static Color get textSecondary => isDark ? const Color(0xFF8896AB) : const Color(0xFF57657A);
  static Color get textMuted     => isDark ? const Color(0xFF5A6A82) : const Color(0xFF9AA5B4);

  // Light-mode explicit
  static Color get bgLight       => const Color(0xFFF5F3EF);
  static Color get surfaceLight  => const Color(0xFFFFFFFF);
  static Color get cardLight     => const Color(0xFFFFFFFF);
  static Color get cardHighLight => const Color(0xFFFFF8E7);

  static Color get textDark          => const Color(0xFF1A2238);
  static Color get textDarkSecondary => const Color(0xFF57657A);
  static Color get textDarkMuted     => const Color(0xFF9AA5B4);
  static Color get borderLight       => const Color(0xFFE8DFD0);
}

// ─── Shadows ────────────────────────────────────────────────────────────────
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
      color: Color(0x1AF5B731),
      blurRadius: 20,
      offset: Offset(0, 8),
    ),
  ];

  static List<BoxShadow> get amber => [
    BoxShadow(
      color: AppColors.amber.withValues(alpha: 0.35),
      blurRadius: 24,
      offset: const Offset(0, 8),
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

// ─── Theme Builder ──────────────────────────────────────────────────────────
class AppTheme {
  // ── DARK ─────────────────────────────────────────────────────────────────
  static ThemeData get darkTheme {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      scaffoldBackgroundColor: AppColors.bg,
      colorScheme: ColorScheme.dark(
        primary: AppColors.amber,
        secondary: AppColors.orange,
        surface: AppColors.surface,
        onPrimary: AppColors.navyDeep,
        onSurface: AppColors.white,
        outline: AppColors.border,
      ),
      textTheme: GoogleFonts.interTextTheme(
        TextTheme(
          displayLarge:   TextStyle(color: AppColors.white,     fontWeight: FontWeight.w700),
          headlineLarge:  TextStyle(color: AppColors.white,     fontWeight: FontWeight.w700),
          headlineMedium: TextStyle(color: AppColors.white,     fontWeight: FontWeight.w600),
          titleLarge:     TextStyle(color: AppColors.white,     fontWeight: FontWeight.w600),
          titleMedium:    TextStyle(color: AppColors.white,     fontWeight: FontWeight.w500),
          bodyLarge:      TextStyle(color: AppColors.greyLight),
          bodyMedium:     TextStyle(color: AppColors.greyLight),
          labelLarge:     TextStyle(color: AppColors.white,     fontWeight: FontWeight.w600),
        ),
      ),
      appBarTheme: AppBarTheme(
        backgroundColor: AppColors.bg,
        elevation: 0,
        surfaceTintColor: Colors.transparent,
        iconTheme: const IconThemeData(color: AppColors.white),
        titleTextStyle: const TextStyle(
          color: AppColors.white,
          fontSize: 18,
          fontWeight: FontWeight.w600,
        ),
      ),
      cardTheme: CardThemeData(
        color: AppColors.card,
        elevation: 0,
        shadowColor: Colors.transparent,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: BorderSide(color: AppColors.border),
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.amber,
          foregroundColor: AppColors.navyDeep,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: AppColors.surface,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide(color: AppColors.border),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide(color: AppColors.border),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide(color: AppColors.amber),
        ),
        hintStyle: TextStyle(color: AppColors.textMuted),
      ),
      switchTheme: SwitchThemeData(
        thumbColor: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) return AppColors.amber;
          return const Color(0xFFE2E8F0);
        }),
        trackColor: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) return AppColors.amber.withValues(alpha: 0.35);
          return const Color(0xFF334155);
        }),
      ),
      dividerColor: AppColors.border,
    );
  }

  // ── LIGHT (warm ivory palette) ────────────────────────────────────────────
  static ThemeData get lightTheme {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.light,
      scaffoldBackgroundColor: AppColors.bgLight,
      colorScheme: ColorScheme.light(
        primary: AppColors.amber,
        secondary: AppColors.orange,
        surface: const Color(0xFFFFFFFF),
        onPrimary: AppColors.navyDeep,
        onSurface: AppColors.textDark,
        outline: AppColors.borderLight,
      ),
      textTheme: GoogleFonts.interTextTheme(
        TextTheme(
          displayLarge:   TextStyle(color: AppColors.textDark, fontWeight: FontWeight.w700),
          headlineLarge:  TextStyle(color: AppColors.textDark, fontWeight: FontWeight.w700),
          headlineMedium: TextStyle(color: AppColors.textDark, fontWeight: FontWeight.w600),
          titleLarge:     TextStyle(color: AppColors.textDark, fontWeight: FontWeight.w600),
          titleMedium:    TextStyle(color: AppColors.textDark, fontWeight: FontWeight.w500),
          bodyLarge:      TextStyle(color: AppColors.textDarkSecondary),
          bodyMedium:     TextStyle(color: AppColors.textDarkSecondary),
          labelLarge:     TextStyle(color: AppColors.textDark, fontWeight: FontWeight.w600),
        ),
      ),
      appBarTheme: AppBarTheme(
        backgroundColor: AppColors.bgLight,
        elevation: 0,
        surfaceTintColor: Colors.transparent,
        shadowColor: const Color(0x14000000),
        iconTheme: IconThemeData(color: AppColors.textDark),
        titleTextStyle: TextStyle(
          color: AppColors.textDark,
          fontSize: 18,
          fontWeight: FontWeight.w600,
        ),
      ),
      cardTheme: CardThemeData(
        color: const Color(0xFFFFFFFF),
        elevation: 0,
        shadowColor: Colors.transparent,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: BorderSide(color: AppColors.borderLight),
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.amber,
          foregroundColor: AppColors.navyDeep,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: const Color(0xFFFFFFFF),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide(color: AppColors.borderLight),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide(color: AppColors.borderLight),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide(color: AppColors.amber),
        ),
        hintStyle: TextStyle(color: AppColors.textDarkMuted),
      ),
      switchTheme: SwitchThemeData(
        thumbColor: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) return AppColors.amber;
          return const Color(0xFFFFFFFF);
        }),
        trackColor: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) return AppColors.amber.withValues(alpha: 0.35);
          return const Color(0xFFCBD5E1);
        }),
      ),
      dividerColor: AppColors.borderLight,
    );
  }
}
