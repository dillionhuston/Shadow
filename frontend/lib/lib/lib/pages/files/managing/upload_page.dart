import 'package:flutter/material.dart';

class FileManagingUploadPage extends StatefulWidget {
  const FileManagingUploadPage({super.key});

  @override
  State<FileManagingUploadPage> createState() => _FileManagingUploadPageState();
}

class _FileManagingUploadPageState extends State<FileManagingUploadPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Upload File", style: TextStyle(color: Colors.white)),
        backgroundColor: Colors.black87,
      ),
      backgroundColor: Colors.black87,
      body: Center(
        child: Container(
          padding: const EdgeInsets.all(16.0),
          margin: const EdgeInsets.symmetric(horizontal: 20.0),
          decoration: BoxDecoration(
            color: Colors.grey[850],
            borderRadius: BorderRadius.circular(12.0),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const Text(
                "Upload Your Files",
                style: TextStyle(
                  color: Color(0xFF00BCD4),
                  fontSize: 24.0,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 20.0),
              const Text(
                "This is a test area for file upload.",
                style: TextStyle(color: Colors.white70),
              ),
              const SizedBox(height: 20.0),
              ElevatedButton(
                onPressed: () {
                  // Placeholder action
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF00BCD4),
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8.0)),
                  padding: const EdgeInsets.symmetric(horizontal: 40.0, vertical: 12.0),
                ),
                child: const Text("Upload"),
              ),
              const SizedBox(height: 10.0),
              TextButton(
                onPressed: () {
                  // Placeholder action (e.g., navigate back)
                },
                child: const Text(
                  "Back to Dashboard",
                  style: TextStyle(color: Color(0xFF00BCD4)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}