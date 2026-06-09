import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:flutter_stripe/flutter_stripe.dart';
import 'providers/auth_provider.dart';
import 'screens/splash_screen.dart';
import 'theme/app_theme.dart';
import 'config/api_config.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();

  // Stripe publishable key — override via:
  //   flutter run --dart-define=STRIPE_PK=pk_live_xxx
  const stripePk = String.fromEnvironment(
    'STRIPE_PK',
    defaultValue: 'pk_test_REPLACE_WITH_YOUR_STRIPE_PUBLISHABLE_KEY',
  );
  Stripe.publishableKey = stripePk;

  SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);
  SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
    statusBarColor: Colors.transparent,
    statusBarIconBrightness: Brightness.light,
  ));

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthProvider()),
      ],
      child: const FixNGoApp(),
    ),
  );
}

class FixNGoApp extends StatelessWidget {
  const FixNGoApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Fix-N-Go',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.darkTheme,
      home: const SplashScreen(),
    );
  }
}
