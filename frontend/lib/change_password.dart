import 'package:flutter/material.dart';
import 'api_service.dart';

class ChangePasswordPage extends StatefulWidget {
  const ChangePasswordPage({super.key});

  @override
  State<ChangePasswordPage> createState() => _ChangePasswordPageState();
}

class _ChangePasswordPageState extends State<ChangePasswordPage> {
  final _currentPasswordController = TextEditingController();
  final _newPasswordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  String _message = '';

  Future<void> _changePassword() async {
    if (_newPasswordController.text != _confirmPasswordController.text) {
      setState(() {
        _message = 'Passwords do not match';
      });
      return;
    }
    try {
      final result = await ApiService.changePassword(
        _currentPasswordController.text,
        _newPasswordController.text,
      );
      setState(() {
        _message = 'Password changed: ${result['message']}';
      });
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
                              'Change Password',
                              style: TextStyle(
                                fontSize: 26,
                                color: Color(0xFF00BCD4),
                              ),
                            ),
                            const SizedBox(height: 25),
                            Container(
                              padding: const EdgeInsets.all(12),
                              color: const Color(0xFFF44336),
                              child: const Text(
                                'Always use a strong, unique password to protect your account.',
                                style: TextStyle(
                                  color: Color(0xFFFFFFFF),
                                  fontWeight: FontWeight.bold,
                                ),
                                textAlign: TextAlign.center,
                              ),
                            ),
                            const SizedBox(height: 20),
                            TextField(
                              controller: _currentPasswordController,
                              decoration: const InputDecoration(
                                labelText: 'Current Password',
                              ),
                              style: const TextStyle(color: Color(0xFFFFFFFF)),
                              obscureText: true,
                            ),
                            const SizedBox(height: 20),
                            TextField(
                              controller: _newPasswordController,
                              decoration: const InputDecoration(
                                labelText: 'New Password',
                              ),
                              style: const TextStyle(color: Color(0xFFFFFFFF)),
                              obscureText: true,
                            ),
                            const SizedBox(height: 20),
                            TextField(
                              controller: _confirmPasswordController,
                              decoration: const InputDecoration(
                                labelText: 'Confirm New Password',
                              ),
                              style: const TextStyle(color: Color(0xFFFFFFFF)),
                              obscureText: true,
                            ),
                            const SizedBox(height: 20),
                            ElevatedButton(
                              onPressed: _changePassword,
                              child: const Text('Update Password'),
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
