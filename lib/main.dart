import 'package:flutter/material.dart';
import 'services/db_helper.dart';
import 'screens/login_screen.dart';
import 'screens/register_screen.dart';
import 'screens/home_screen.dart';
import 'screens/profile_screen.dart';
import 'screens/settings_screen.dart';
import 'screens/content_screen.dart';
import 'screens/help_screen.dart';

void main() {
  runApp(const SecondHandMarketApp());
}

class SecondHandMarketApp extends StatelessWidget {
  const SecondHandMarketApp({super.key});

  @override
  Widget build(BuildContext context) {
    final DBHelper dbHelper = DBHelper();

    return MaterialApp(
      title: 'Campus Second-hand Trading Platform',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(
          seedColor: Colors.teal,
          primary: Colors.teal,
          secondary: Colors.orangeAccent,
        ),
        appBarTheme: const AppBarTheme(
          backgroundColor: Colors.teal,
          foregroundColor: Colors.white,
          centerTitle: true,
        ),
      ),
      // Intercept and resolve system routing node based on active authentication cache
      home: FutureBuilder<Map<String, dynamic>?>(
        future: dbHelper.getCurrentSession(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Scaffold(
              body: Center(child: CircularProgressIndicator()),
            );
          }
          // If valid user session found on storage layer, directly pass to Home dashboard
          if (snapshot.hasData && snapshot.data != null) {
            return const HomeScreen();
          }
          return const LoginScreen();
        },
      ),
      routes: {
        '/login': (context) => const LoginScreen(),
        '/register': (context) => const RegisterScreen(),
        '/home': (context) => const HomeScreen(),
        '/profile': (context) => const ProfileScreen(),
        '/settings': (context) => const SettingsScreen(),
        '/content': (context) => const ContentScreen(),
        '/help': (context) => const HelpScreen(),
      },
    );
  }
}
