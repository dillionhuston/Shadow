import 'package:flutter/material.dart';
import 'api_service.dart';

class SignupPage extends StatefulWidget {
  const SignupPage({super.key});

  @override
  State<SignupPage> createState() => _SignupPageState();
}

class _SignupPageState extends State<SignupPage> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  String _message = '';

  Future<void> _signup() async {
    try {
      final result = await ApiService.signup(
        _emailController.text,
        _passwordController.text,
      );
      setState(() {
        _message = 'Signup successful: ${result['message']}';
      });
      Navigator.pushNamed(context, '/login');
    } catch (e) {
      setState(() {
        _message = e.toString();
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Row(
        children: [
          SizedBox(
            width: 240,
            child: Container(
              color: const Color(0xFF1E1E1E),
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'ShadowBox',
                    style: TextStyle(fontSize: 26, color: Color(0xFF00BCD4)),
                  ),
                  const SizedBox(height: 30),
                  TextButton(
                    onPressed: () => Navigator.pushNamed(context, '/dashboard'),
                    child: const Text('Dashboard'),
                  ),
                  TextButton(onPressed: () {}, child: const Text('My Files')),
                  TextButton(
                    onPressed:
                        () => Navigator.pushNamed(context, '/change_password'),
                    child: const Text('Settings'),
                  ),
                  TextButton(onPressed: () {}, child: const Text('Logout')),
                ],
              ),
            ),
          ),
          Expanded(
            child: Column(
              children: [
                Container(
                  height: 70,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 33,
                    vertical: 17,
                  ),
                  color: const Color(0xFF1F1F1F),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      const Text('Hello, User'),
                      const SizedBox(width: 14),
                      Container(
                        width: 40,
                        height: 40,
                        decoration: const BoxDecoration(
                          shape: BoxShape.circle,
                          border: Border(
                            top: BorderSide(color: Color(0xFF03A9F4), width: 2),
                            left: BorderSide(
                              color: Color(0xFF03A9F4),
                              width: 2,
                            ),
                            right: BorderSide(
                              color: Color(0xFF03A9F4),
                              width: 2,
                            ),
                            bottom: BorderSide(
                              color: Color(0xFF03A9F4),
                              width: 2,
                            ),
                          ),
                        ),
                        child: ClipOval(
                          child: Image.network(
                            'https://via.placeholder.com/40',
                            fit: BoxFit.cover,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                Expanded(
                  child: Center(
                    child: Card(
                      child: Padding(
                        padding: const EdgeInsets.all(40),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Text(
                              'Create Your Account',
                              style: TextStyle(
                                fontSize: 26,
                                color: Color(0xFF00BCD4),
                              ),
                            ),
                            const SizedBox(height: 25),
                            TextField(
                              controller: _emailController,
                              decoration: const InputDecoration(
                                labelText: 'Email',
                              ),
                              style: const TextStyle(color: Color(0xFFFFFFFF)),
                            ),
                            const SizedBox(height: 20),
                            TextField(
                              controller: _passwordController,
                              decoration: const InputDecoration(
                                labelText: 'Password',
                              ),
                              style: const TextStyle(color: Color(0xFFFFFFFF)),
                              obscureText: true,
                            ),
                            const SizedBox(height: 20),
                            ElevatedButton(
                              onPressed: _signup,
                              child: const Text('Sign Up'),
                            ),
                            const SizedBox(height: 10),
                            Text(
                              _message,
                              style: const TextStyle(color: Color(0xFFF44336)),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
                Container(
                  padding: const EdgeInsets.all(10),
                  color: const Color(0xFF121212),
                  child: const Text(
                    '© 2025 ShadowBox | Privacy Policy',
                    style: TextStyle(color: Color(0xFF777777)),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
