import 'package:flutter/material.dart';
import 'api_service.dart';
import 'dart:developer' as developer;

// UI Constants from DashboardPage
const kPrimaryColor = Color(0xFF00BCD4);
const kBackgroundColor = Color(0xFF121212);
const kHeaderColor = Color(0xFF1F1F1F);
const kCardColor = Color(0xFF2A2A2A);
const kErrorColor = Color(0xFFF44336);
const kTextColor = Colors.white;

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _usernameController = TextEditingController();
  final _passwordController = TextEditingController();
  String _message = '';
  bool _isLoading = false;
  static const int _maxRetries = 3;

  @override
  void dispose() {
    _usernameController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  /// Handle login request with retries
  Future<void> _login() async {
    if (_isLoading) return;

    final username = _usernameController.text.trim();
    final password = _passwordController.text.trim();

    // Validate inputs
    if (username.isEmpty || password.isEmpty) {
      setState(() => _message = 'Username and password are required');
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Username and password are required'),
          backgroundColor: kErrorColor,
        ),
      );
      return;
    }
    if (username.length < 3) {
      setState(() => _message = 'Username must be 3+ characters');
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Username must be 3+ characters'),
          backgroundColor: kErrorColor,
        ),
      );
      return;
    }
    if (password.length < 8 ||
        !RegExp(r'^(?=.*[A-Za-z])(?=.*\d)').hasMatch(password)) {
      setState(
        () =>
            _message =
                'Password must be 8+ characters with letters and numbers',
      );
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Password must be 8+ characters with letters and numbers',
          ),
          backgroundColor: kErrorColor,
        ),
      );
      return;
    }

    setState(() {
      _isLoading = true;
      _message = '';
    });

    for (int attempt = 1; attempt <= _maxRetries; attempt++) {
      try {
        final result = await ApiService.login(
          username: username,
          password: password,
        );
        if (!mounted) return;
        developer.log('Login successful: $result');
        setState(() => _message = result['message'] ?? 'Login successful');
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Login successful'),
            backgroundColor: kPrimaryColor,
          ),
        );
        Navigator.pushNamedAndRemoveUntil(
          context,
          '/dashboard',
          (route) => false,
        );
        return;
      } catch (e) {
        final errorMessage = e.toString().replaceAll('ApiException: ', '');
        developer.log('Login attempt $attempt failed: $errorMessage');
        setState(() {
          _message = 'Error (Attempt $attempt/$_maxRetries): $errorMessage';
        });
        if (attempt == _maxRetries) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Login failed: $errorMessage'),
              backgroundColor: kErrorColor,
            ),
          );
        }
        await Future.delayed(
          Duration(seconds: attempt * 2),
        ); // Exponential backoff
      } finally {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      color: kBackgroundColor, // Fallback background
      child: Scaffold(
        backgroundColor: kBackgroundColor,
        body: Column(
          children: [
            // Header
            Container(
              height: 70,
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
              color: kHeaderColor,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'ShadowBox',
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: kPrimaryColor,
                    ),
                  ),
                  TextButton(
                    onPressed: () => Navigator.pushNamed(context, '/signup'),
                    child: const Text(
                      'Sign Up',
                      style: TextStyle(color: kPrimaryColor),
                    ),
                  ),
                ],
              ),
            ),
            // Main Content
            Expanded(
              child: Center(
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 400),
                  child: Card(
                    elevation: 4,
                    color: kCardColor,
                    child: Padding(
                      padding: const EdgeInsets.all(24),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          Text(
                            'Log In',
                            style: theme.textTheme.headlineSmall?.copyWith(
                              color: kPrimaryColor,
                              fontWeight: FontWeight.bold,
                            ),
                            textAlign: TextAlign.center,
                          ),
                          const SizedBox(height: 20),
                          TextField(
                            controller: _usernameController,
                            decoration: const InputDecoration(
                              labelText: 'Username',
                              border: OutlineInputBorder(),
                              prefixIcon: Icon(Icons.person, color: kTextColor),
                              labelStyle: TextStyle(color: kTextColor),
                              enabledBorder: OutlineInputBorder(
                                borderSide: BorderSide(color: kTextColor),
                              ),
                              focusedBorder: OutlineInputBorder(
                                borderSide: BorderSide(color: kPrimaryColor),
                              ),
                            ),
                            style: const TextStyle(color: kTextColor),
                          ),
                          const SizedBox(height: 16),
                          TextField(
                            controller: _passwordController,
                            decoration: const InputDecoration(
                              labelText: 'Password',
                              border: OutlineInputBorder(),
                              prefixIcon: Icon(Icons.lock, color: kTextColor),
                              labelStyle: TextStyle(color: kTextColor),
                              enabledBorder: OutlineInputBorder(
                                borderSide: BorderSide(color: kTextColor),
                              ),
                              focusedBorder: OutlineInputBorder(
                                borderSide: BorderSide(color: kPrimaryColor),
                              ),
                            ),
                            style: const TextStyle(color: kTextColor),
                            obscureText: true,
                          ),
                          const SizedBox(height: 20),
                          ElevatedButton(
                            onPressed: _isLoading ? null : _login,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: kPrimaryColor,
                              padding: const EdgeInsets.symmetric(vertical: 12),
                            ),
                            child:
                                _isLoading
                                    ? const CircularProgressIndicator(
                                      color: kTextColor,
                                    )
                                    : const Text(
                                      'Log In',
                                      style: TextStyle(
                                        fontSize: 16,
                                        color: kTextColor,
                                      ),
                                    ),
                          ),
                          const SizedBox(height: 12),
                          Text(
                            _message,
                            style: const TextStyle(color: kErrorColor),
                            textAlign: TextAlign.center,
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),
            // Footer
            Container(
              padding: const EdgeInsets.all(10),
              color: kBackgroundColor,
              child: const Text(
                '© 2025 ShadowBox | Privacy Policy',
                style: TextStyle(color: Color(0xFF777777)),
                textAlign: TextAlign.center,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
