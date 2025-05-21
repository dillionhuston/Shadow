import 'package:flutter/material.dart';
import 'api_service.dart';

// UI Constants
const kPrimaryColor = Color(0xFF00BCD4);
const kBackgroundColor = Color(0xFF121212);
const kHeaderColor = Color(0xFF1F1F1F);
const kCardColor = Color(0xFF2A2A2A);
const kErrorColor = Color(0xFFF44336);
const kTextColor = Colors.white;

class SignupPage extends StatefulWidget {
  const SignupPage({super.key});

  @override
  State<SignupPage> createState() => _SignupPageState();
}

class _SignupPageState extends State<SignupPage> {
  final _usernameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  String _message = '';
  bool _isSubmitting = false;

  @override
  void dispose() {
    _usernameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _signup() async {
    if (_isSubmitting) return;

    final username = _usernameController.text.trim();
    final email = _emailController.text.trim();
    final password = _passwordController.text.trim();

    if (username.isEmpty || email.isEmpty || password.isEmpty) {
      setState(() => _message = 'All fields are required');
      return;
    }
    if (username.length < 3) {
      setState(() => _message = 'Username must be 3+ characters');
      return;
    }
    if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(email)) {
      setState(() => _message = 'Invalid email format');
      return;
    }
    if (password.length < 8 ||
        !RegExp(r'^(?=.*[A-Za-z])(?=.*\d)').hasMatch(password)) {
      setState(
        () =>
            _message =
                'Password must be 8+ characters with letters and numbers',
      );
      return;
    }

    setState(() {
      _isSubmitting = true;
      _message = 'Signing up...';
    });

    try {
      final response = await ApiService.signup(
        username: username,
        email: email,
        password: password,
      );

      if (!mounted) return;

      setState(() {
        _message = response['message'] ?? 'Signup successful';
        _usernameController.clear();
        _emailController.clear();
        _passwordController.clear();
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(_message), backgroundColor: kPrimaryColor),
      );
      Navigator.pushNamed(context, '/login');
    } catch (e) {
      setState(() {
        _message = 'Signup error: $e';
        _isSubmitting = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(_message), backgroundColor: kErrorColor),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: kBackgroundColor,
      body: Column(
        children: [
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
                  onPressed: () => Navigator.pushNamed(context, '/login'),
                  child: const Text('Log In'),
                ),
              ],
            ),
          ),
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
                        const Text(
                          'Sign Up',
                          style: TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                            color: kPrimaryColor,
                          ),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 20),
                        TextField(
                          controller: _usernameController,
                          decoration: const InputDecoration(
                            labelText: 'Username',
                            border: OutlineInputBorder(),
                            prefixIcon: Icon(Icons.person),
                          ),
                          style: const TextStyle(color: kTextColor),
                        ),
                        const SizedBox(height: 16),
                        TextField(
                          controller: _emailController,
                          decoration: const InputDecoration(
                            labelText: 'Email',
                            border: OutlineInputBorder(),
                            prefixIcon: Icon(Icons.email),
                          ),
                          style: const TextStyle(color: kTextColor),
                          keyboardType: TextInputType.emailAddress,
                        ),
                        const SizedBox(height: 16),
                        TextField(
                          controller: _passwordController,
                          decoration: const InputDecoration(
                            labelText: 'Password',
                            border: OutlineInputBorder(),
                            prefixIcon: Icon(Icons.lock),
                          ),
                          style: const TextStyle(color: kTextColor),
                          obscureText: true,
                        ),
                        const SizedBox(height: 20),
                        ElevatedButton(
                          onPressed: _isSubmitting ? null : _signup,
                          child:
                              _isSubmitting
                                  ? const CircularProgressIndicator(
                                    color: kTextColor,
                                  )
                                  : const Text('Sign Up'),
                        ),
                        const SizedBox(height: 12),
                        if (_message.isNotEmpty)
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
    );
  }
}
