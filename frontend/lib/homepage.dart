import 'package:flutter/material.dart';
import 'api_service.dart';

// UI Constants
const kPrimaryColor = Color(0xFF00BCD4);
const kBackgroundColor = Color(0xFF121212);
const kSidebarColor = Color(0xFF1E1E1E);
const kHeaderColor = Color(0xFF1F1F1F);
const kErrorColor = Color(0xFFF44336);

class Homepage extends StatefulWidget {
  const Homepage({super.key});

  @override
  State<Homepage> createState() => _HomepageState();
}

class _HomepageState extends State<Homepage> {
  int fileCount = 0;
  String _message = '';

  @override
  void initState() {
    super.initState();
    _loadFiles();
  }

  Future<void> _loadFiles() async {
    setState(() => _message = 'Loading files...');
    try {
      final files = await ApiService.getDashboardFiles();
      setState(() {
        fileCount = files.length;
        _message = '';
      });
    } catch (e) {
      setState(() => _message = 'Failed to load files: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(_message), backgroundColor: kErrorColor),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: kBackgroundColor,
      body: Row(
        children: [
          Container(
            width: 240,
            color: kSidebarColor,
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'ShadowBox',
                  style: TextStyle(fontSize: 26, color: kPrimaryColor),
                ),
                const SizedBox(height: 30),
                TextButton(
                  onPressed: () => Navigator.pushNamed(context, '/dashboard'),
                  child: const Text('Dashboard'),
                ),
                TextButton(
                  onPressed: () => Navigator.pushNamed(context, '/files'),
                  child: const Text('My Files'),
                ),
                TextButton(
                  onPressed:
                      () => Navigator.pushNamed(context, '/change_password'),
                  child: const Text('Settings'),
                ),
                TextButton(
                  onPressed: () async {
                    await ApiService.logout();
                    Navigator.pushNamedAndRemoveUntil(
                      context,
                      '/login',
                      (route) => false,
                    );
                  },
                  child: const Text('Logout'),
                ),
              ],
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
                  color: kHeaderColor,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: const [
                      Text('Hello, User'),
                      SizedBox(width: 14),
                      CircleAvatar(radius: 20, child: Icon(Icons.person)),
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
                              'Welcome to ShadowBox',
                              style: TextStyle(
                                fontSize: 26,
                                color: kPrimaryColor,
                              ),
                            ),
                            const SizedBox(height: 25),
                            Text('You have $fileCount files.'),
                            if (_message.isNotEmpty)
                              Text(
                                _message,
                                style: const TextStyle(color: kErrorColor),
                              ),
                            const SizedBox(height: 20),
                            ElevatedButton(
                              onPressed:
                                  () => Navigator.pushNamed(
                                    context,
                                    '/dashboard',
                                  ),
                              child: const Text('Get Started'),
                            ),
                          ],
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
