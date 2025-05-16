import 'package:flutter/material.dart';
import 'api_service.dart';

// UI Constants from DashboardPage
const kPrimaryColor = Color(0xFF00BCD4);
const kBackgroundColor = Color(0xFF121212);
const kCardColor = Color(0xFF2A2A2A);
const kErrorColor = Color(0xFFF44336);
const kTextColor = Colors.white;
const kSecondaryTextColor = Colors.white70;

class FilesPage extends StatefulWidget {
  const FilesPage({super.key});

  @override
  State<FilesPage> createState() => _FilesPageState();
}

class _FilesPageState extends State<FilesPage> {
  List<dynamic> _files = [];
  String _message = '';
  bool _isFetching = false;

  @override
  void initState() {
    super.initState();
    _loadFiles();
  }

  /// Load files from /files endpoint
  Future<void> _loadFiles() async {
    setState(() {
      _isFetching = true;
      _message = 'Loading files...';
    });

    try {
      final files = await ApiService.getServerFiles();
      print('Fetched server files: $files'); // Debug log
      setState(() {
        _files = files;
        _message =
            _files.isEmpty
                ? 'No files available. Try uploading one.'
                : 'Files loaded successfully';
        _isFetching = false;
      });
    } catch (e) {
      setState(() {
        _message = 'Failed to load files: $e. Tap Retry or check connection.';
        _isFetching = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: kBackgroundColor,
      appBar: AppBar(
        title: const Text('Server Files'),
        backgroundColor: kPrimaryColor,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                ElevatedButton.icon(
                  onPressed: _isFetching ? null : _loadFiles,
                  icon: const Icon(Icons.refresh),
                  label: const Text('Refresh'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: kPrimaryColor,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                ),
                if (_message.contains('Failed')) ...[
                  const SizedBox(width: 12),
                  ElevatedButton.icon(
                    onPressed: _loadFiles,
                    icon: const Icon(Icons.replay),
                    label: const Text('Retry'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.white10,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                  ),
                ],
              ],
            ),
            const SizedBox(height: 16),
            Text(_message, style: const TextStyle(color: kErrorColor)),
            const SizedBox(height: 16),
            Expanded(
              child:
                  _isFetching
                      ? const Center(
                        child: CircularProgressIndicator(color: kPrimaryColor),
                      )
                      : _files.isEmpty
                      ? const Center(
                        child: Text(
                          'No files available',
                          style: TextStyle(color: kSecondaryTextColor),
                        ),
                      )
                      : ListView.builder(
                        itemCount: _files.length,
                        itemBuilder: (context, index) {
                          final file = _files[index];
                          return Card(
                            color: kCardColor,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: ListTile(
                              title: Text(
                                file['filename'] ?? 'Unknown File',
                                style: const TextStyle(color: kTextColor),
                              ),
                              subtitle: Text(
                                'Size: ${(file['size'] / 1024).toStringAsFixed(1)} KB\nUploaded: ${file['created_at'] ?? 'N/A'}',
                                style: const TextStyle(
                                  color: kSecondaryTextColor,
                                ),
                              ),
                            ),
                          );
                        },
                      ),
            ),
          ],
        ),
      ),
    );
  }
}
