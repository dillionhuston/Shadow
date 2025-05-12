import 'package:flutter/material.dart';
import 'api_service.dart';

class DashboardPage extends StatefulWidget {
  const DashboardPage({super.key});

  @override
  State<DashboardPage> createState() => _DashboardPageState();
}

class _DashboardPageState extends State<DashboardPage> {
  List<dynamic> files = [];
  String _message = '';

  @override
  void initState() {
    super.initState();
    _loadFiles();
  }

  Future<void> _loadFiles() async {
    try {
      final loadedFiles = await ApiService.getDashboardFiles();
      setState(() {
        files = loadedFiles;
      });
    } catch (e) {
      setState(() {
        _message = e.toString();
      });
    }
  }

  Future<void> _uploadFile() async {
    try {
      final result = await ApiService.uploadFile(
        'example.pdf',
        'base64encodeddata',
      );
      setState(() {
        _message = 'Upload successful: ${result['message']}';
        _loadFiles(); // Refresh file list
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
                              'Dashboard',
                              style: TextStyle(
                                fontSize: 26,
                                color: Color(0xFF00BCD4),
                              ),
                            ),
                            const SizedBox(height: 25),
                            ElevatedButton(
                              onPressed: _uploadFile,
                              child: const Text('Upload'),
                            ),
                            const SizedBox(height: 20),
                            const Text(
                              'Files:',
                              style: TextStyle(color: Color(0xFF00BCD4)),
                            ),
                            const SizedBox(height: 10),
                            Expanded(
                              child: ListView.builder(
                                shrinkWrap: true,
                                itemCount: files.length,
                                itemBuilder: (context, index) {
                                  return ListTile(
                                    title: Text(
                                      files[index]['name'] ?? 'File $index.pdf',
                                      style: const TextStyle(
                                        color: Color(0xFFFFFFFF),
                                      ),
                                    ),
                                    onTap: () {},
                                  );
                                },
                              ),
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
