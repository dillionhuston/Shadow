import 'package:flutter/material.dart';
import 'api_service.dart';

// UI Constants
const kPrimaryColor = Color(0xFF00BCD4);
const kBackgroundColor = Color(0xFF121212);
const kErrorColor = Color(0xFFF44336);
const kTextColor = Colors.white;

class ChangePasswordPage extends StatefulWidget {
  const ChangePasswordPage({super.key});

  @override
  State<ChangePasswordPage> createState() => _ChangePasswordPageState();
}

class _ChangePasswordPageState extends State<ChangePasswordPage> {
  final _currentPasswordController = TextEditingController();
  final _newPasswordController = TextEditingController();
  String _message = '';
  bool _isSubmitting = false;

  Future<void> _changePassword() async {
    if (_isSubmitting) return;

    final currentPassword = _currentPasswordController.text.trim();
    final newPassword = _newPasswordController.text.trim();

    if (currentPassword.isEmpty || newPassword.isEmpty) {
      setState(() => _message = 'Both fields are required');
      return;
    }
    if (newPassword.length < 8 ||
        !RegExp(r'^(?=.*[A-Za-z])(?=.*\d)').hasMatch(newPassword)) {
      setState(
        () =>
            _message =
                'New password must be 8+ characters with letters and numbers',
      );
      return;
    }

    setState(() {
      _isSubmitting = true;
      _message = 'Changing password...';
    });

    try {
      final result = await ApiService.changePassword(
        currentPassword: currentPassword,
        newPassword: newPassword,
      );
      setState(() {
        _message = result['message'] ?? 'Password changed successfully';
        _isSubmitting = false;
        _currentPasswordController.clear();
        _newPasswordController.clear();
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(_message), backgroundColor: kPrimaryColor),
      );
    } catch (e) {
      setState(() {
        _message = 'Failed to change password: $e';
        _isSubmitting = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(_message), backgroundColor: kErrorColor),
      );
    }
  }

  @override
  void dispose() {
    _currentPasswordController.dispose();
    _newPasswordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: kBackgroundColor,
      appBar: AppBar(
        title: const Text('Change Password'),
        backgroundColor: kPrimaryColor,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            TextField(
              controller: _currentPasswordController,
              decoration: const InputDecoration(labelText: 'Current Password'),
              style: const TextStyle(color: kTextColor),
              obscureText: true,
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _newPasswordController,
              decoration: const InputDecoration(labelText: 'New Password'),
              style: const TextStyle(color: kTextColor),
              obscureText: true,
            ),
            const SizedBox(height: 16),
            if (_message.isNotEmpty)
              Text(_message, style: const TextStyle(color: kErrorColor)),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: _isSubmitting ? null : _changePassword,
              child:
                  _isSubmitting
                      ? const CircularProgressIndicator(color: kTextColor)
                      : const Text('Change Password'),
            ),
          ],
        ),
      ),
    );
  }
}
