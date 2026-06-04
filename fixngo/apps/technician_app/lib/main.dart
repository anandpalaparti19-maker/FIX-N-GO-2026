import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'login_screen.dart';
import 'home_screen.dart';
import 'earnings_screen.dart';
import 'my_jobs_screen.dart';
import 'profile_screen.dart';

void main() {
  runApp(const FixNGoTechApp());
}

class FixNGoTechApp extends StatelessWidget {
  const FixNGoTechApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Fix-N-Go Tech',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Colors.blue,
        textTheme: GoogleFonts.interTextTheme(Theme.of(context).textTheme),
      ),
      initialRoute: '/',
      routes: {
        '/': (context) => LoginScreen(),
        '/home': (context) => HomeScreen(),
        '/earnings': (context) => EarningsScreen(),
        '/my_jobs': (context) => MyJobsScreen(),
        '/profile': (context) => ProfileScreen(),
      },
    );
  }
}
