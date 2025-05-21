import 'package:flutter/material.dart';
import 'login.dart';
import 'signup.dart';
import 'dashboard.dart';
import 'files.dart';
import 'change_password.dart';

// UI Constants
const kPrimaryColor = Color(0xFF00BCD4);
const kBackgroundColor = Color(0xFF121212);
const kTextColor = Colors.white;

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: ThemeData(
        scaffoldBackgroundColor: kBackgroundColor,
        primaryColor: kPrimaryColor,
        textTheme: const TextTheme(
          bodyMedium: TextStyle(color: kTextColor),
          headlineSmall: TextStyle(color: kTextColor),
        ),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            foregroundColor: kTextColor,
            backgroundColor: kPrimaryColor,
          ),
        ),
        textButtonTheme: TextButtonThemeData(
          style: TextButton.styleFrom(foregroundColor: kPrimaryColor),
        ),
        inputDecorationTheme: const InputDecorationTheme(
          labelStyle: TextStyle(color: kTextColor),
          enabledBorder: OutlineInputBorder(
            borderSide: BorderSide(color: kTextColor),
          ),
          focusedBorder: OutlineInputBorder(
            borderSide: BorderSide(color: kPrimaryColor),
          ),
        ),
      ),
      initialRoute: '/login',
      routes: {
        '/login': (context) => const LoginPage(),
        '/signup': (context) => const SignupPage(),
        '/dashboard': (context) {
          final args =
              ModalRoute.of(context)!.settings.arguments
                  as Map<String, String>?;
          final userId = args?['userId'] ?? '';
          final token = args?['token'] ?? '';
          return DashboardPage(userId: userId, token: token);
        },
        '/files': (context) => const FilesPage(),
        '/change_password': (context) => const ChangePasswordPage(),
      },
    );
  }
}
