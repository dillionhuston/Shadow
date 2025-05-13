import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'api_service.dart';

class DashboardPage extends StatefulWidget {
  const DashboardPage({super.key});

  @override
  State<DashboardPage> createState() => _DashboardPageState();
}

class _DashboardPageState extends State<DashboardPage> {
  String _message = '';

  Future<void> _login() async {
    final response = await ApiService.login('your_username', 'your_password');
    ApiService.setToken(response['token']);
  }

  Future<void> _uploadFile() async {
    FilePickerResult? result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['txt'],
    );
    if (result != null && result.files.isNotEmpty) {
      PlatformFile file = result.files.first;
      String base64Data = base64Encode(file.bytes!);
      setState(() => _message = 'Uploading ${file.name}...');
      try {
        final response = await ApiService.uploadFile(file.name, base64Data);
        setState(() => _message = 'Upload result: ${response['message']}');
      } catch (e) {
        setState(() => _message = 'Upload failed: $e');
      }
    } else {
      setState(() => _message = 'No file selected');
    }
  }

  @override
  void initState() {
    super.initState();
    _login();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            ElevatedButton(
              onPressed: _uploadFile,
              child: Text('Select and Upload File'),
            ),
            SizedBox(height: 20),
            Text(_message, style: TextStyle(color: Color(0xFFF44336))),
          ],
        ),
      ),
    );
  }
}
