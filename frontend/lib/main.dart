import 'package:flutter/material.dart';
import 'homepage.dart';
import 'signup.dart';
import 'login.dart';
import 'change_password.dart';
import 'dashboard.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Shadowbox',
      theme: ThemeData(
        scaffoldBackgroundColor: const Color(0xFF121212),
        primaryColor: const Color(0xFF00BCD4),
        textTheme: const TextTheme(
          bodyMedium: TextStyle(
            color: Color(0xFFFFFFFF),
            fontFamily: 'Segoe UI',
          ),
          labelLarge: TextStyle(
            color: Color(0xFF00BCD4),
            fontFamily: 'Segoe UI',
          ),
          headlineMedium: TextStyle(
            fontSize: 26,
            color: Color(0xFF00BCD4),
            fontFamily: 'Segoe UI',
          ),
        ),
        cardTheme: const CardTheme(color: Color(0xFF1E1E1E), elevation: 5),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFF03A9F4),
            foregroundColor: Colors.white,
            textStyle: const TextStyle(fontSize: 16, fontFamily: 'Segoe UI'),
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
          ),
        ),
        textButtonTheme: TextButtonThemeData(
          style: TextButton.styleFrom(
            foregroundColor: const Color(0xFFCCCCCC),
            textStyle: const TextStyle(fontFamily: 'Segoe UI'),
          ),
        ),
        inputDecorationTheme: const InputDecorationTheme(
          filled: true,
          fillColor: Color(0xFF2A2A2A),
          labelStyle: TextStyle(
            color: Color(0xFFFFFFFF),
            fontFamily: 'Segoe UI',
          ),
          border: OutlineInputBorder(
            borderSide: BorderSide(color: Color(0xFF333333)),
            borderRadius: BorderRadius.all(Radius.circular(5)),
          ),
        ),
      ),
      initialRoute: '/homepage',
      routes: {
        '/homepage': (context) => const Homepage(),
        '/signup': (context) => const SignupPage(),
        '/login': (context) => const LoginPage(),
        '/change_password': (context) => const ChangePasswordPage(),
        '/dashboard': (context) => const DashboardPage(),
      },
    );
  }
}
