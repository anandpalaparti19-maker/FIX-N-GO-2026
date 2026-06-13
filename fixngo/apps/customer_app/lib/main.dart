import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:provider/provider.dart';
import 'package:flutter_stripe/flutter_stripe.dart';
import 'package:firebase_core/firebase_core.dart';
import 'providers/auth_provider.dart';
import 'providers/locale_provider.dart';
import 'providers/theme_provider.dart';
import 'screens/splash_screen.dart';
import 'theme/app_theme.dart';
import 'l10n/app_localizations.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  try {
    if (kIsWeb) {
      await Firebase.initializeApp(
        options: const FirebaseOptions(
          apiKey: 'dummy_api_key',
          appId: 'dummy_app_id',
          messagingSenderId: 'dummy_sender_id',
          projectId: 'dummy_project_id',
        ),
      );
    } else {
      await Firebase.initializeApp();
    }
  } catch (e) {
    debugPrint('Firebase initialization failed: $e');
  }

  const stripePk = String.fromEnvironment(
    'STRIPE_PK',
    defaultValue: 'pk_test_REPLACE_WITH_YOUR_STRIPE_PUBLISHABLE_KEY',
  );
  Stripe.publishableKey = stripePk;

  SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthProvider()),
        ChangeNotifierProvider(create: (_) => LocaleProvider()),
        ChangeNotifierProvider(create: (_) => ThemeProvider()),
      ],
      child: const FixNGoApp(),
    ),
  );
}

class FixNGoApp extends StatelessWidget {
  const FixNGoApp({super.key});

  @override
  Widget build(BuildContext context) {
    final localeProvider = context.watch<LocaleProvider>();
    final themeProvider  = context.watch<ThemeProvider>();

    // Update system UI overlay based on theme
    final isDark = themeProvider.isDark;
    SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: isDark ? Brightness.light : Brightness.dark,
      systemNavigationBarColor: isDark ? AppColors.bgDark : AppColors.bgLight,
      systemNavigationBarIconBrightness: isDark ? Brightness.light : Brightness.dark,
    ));

    return MaterialApp(
      title: 'Fix-N-Go',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: themeProvider.themeMode,
      home: const SplashScreen(),

      // ── Localization ─────────────────────────────────────────────
      locale: localeProvider.locale,
      supportedLocales: AppLocalizations.supportedLanguageCodes
          .map((code) => Locale(code))
          .toList(),
      localizationsDelegates: [
        AppLocalizations.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
    );
  }
}
