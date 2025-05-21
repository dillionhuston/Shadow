import 'package:flutter/material.dart';
import 'api_service.dart';

// UI Constants from DashboardPage
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
    setState(() {
      _isSubmitting = true;
      _message = '';
    });

    try {
      final result = await ApiService.changePassword(
        currentPassword: _currentPasswordController.text,
        newPassword: _newPasswordController.text,
      );
      setState(() {
        _message = result['message'] ?? 'Password changed successfully';
        _isSubmitting = false;
        _currentPasswordController.clear();
        _newPasswordController.clear();
      });
    } catch (e) {
      setState(() {
        _message = 'Failed to change password: $e';
        _isSubmitting = false;
      });
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
              decoration: const InputDecoration(
                labelText: 'Current Password',
                labelStyle: TextStyle(color: kTextColor),
                enabledBorder: UnderlineInputBorder(
                  borderSide: BorderSide(color: kTextColor),
                ),
                focusedBorder: UnderlineInputBorder(
                  borderSide: BorderSide(color: kPrimaryColor),
                ),
              ),
              style: const TextStyle(color: kTextColor),
              obscureText: true,
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _newPasswordController,
              decoration: const InputDecoration(
                labelText: 'New Password',
                labelStyle: TextStyle(color: kTextColor),
                enabledBorder: UnderlineInputBorder(
                  borderSide: BorderSide(color: kTextColor),
                ),
                focusedBorder: UnderlineInputBorder(
                  borderSide: BorderSide(color: kPrimaryColor),
                ),
              ),
              style: const TextStyle(color: kTextColor),
              obscureText: true,
            ),
            const SizedBox(height: 16),
            Text(_message, style: const TextStyle(color: kErrorColor)),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: _isSubmitting ? null : _changePassword,
              style: ElevatedButton.styleFrom(
                backgroundColor: kPrimaryColor,
                padding: const EdgeInsets.symmetric(
                  horizontal: 32,
                  vertical: 12,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              child:
                  _isSubmitting
                      ? const CircularProgressIndicator(color: kTextColor)
                      : const Text(
                        'Change Password',
                        style: TextStyle(color: kTextColor),
                      ),
            ),
          ],
        ),
      ),
    );
  }
}
