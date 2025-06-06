import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'package:universal_html/html.dart' as html;

import 'api_service.dart';

// Constants for UI (unchanged)
const kPrimaryColor = Color(0xFF00BCD4);
const kBackgroundColor = Color(0xFF121212);
const kSidebarColor = Color(0xFF1E1E1E);
const kHeaderColor = Color(0xFF1F1F1F);
const kCardColor = Color(0xFF2A2A2A);
const kErrorColor = Color(0xFFF44336);
const kTextColor = Colors.white;
const kSecondaryTextColor = Colors.white70;

class DashboardPage extends StatefulWidget {
  final String userId;
  final String token;

  const DashboardPage({required this.userId, required this.token, super.key});

  @override
  State<DashboardPage> createState() => _DashboardPageState();
}

class _DashboardPageState extends State<DashboardPage> {
  String _message = '';
  bool _isUploading = false;
  bool _isFetching = false;
  List<dynamic> _files = [];

  @override
  void initState() {
    super.initState();
    print('Setting token in DashboardPage: ${widget.token}');
    ApiService.setToken(widget.token);
    _initialize();
  }

  Future<void> _initialize() async {
    await _fetchFiles();
  }

  Future<void> _uploadFile() async {
    if (_isUploading) return;
    setState(() {
      _isUploading = true;
      _message = '';
    });

    try {
      FilePickerResult? result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['txt', 'pdf', 'doc', 'docx'],
      );

      if (result == null || result.files.isEmpty) {
        setState(() {
          _message = 'No file selected';
          _isUploading = false;
        });
        return;
      }

      PlatformFile file = result.files.first;
      if (file.bytes == null || file.size > 10 * 1024 * 1024) {
        setState(() {
          _message =
              file.bytes == null
                  ? 'File data unavailable'
                  : 'File size exceeds 10MB';
          _isUploading = false;
        });
        return;
      }

      setState(() => _message = 'Uploading ${file.name}...');

      final response = await ApiService.uploadFile(
        fileName: file.name,
        fileBytes: file.bytes!,
        token: widget.token,
      );

      setState(() {
        _message = response['message'] ?? 'Upload successful';
        _isUploading = false;
      });

      await _fetchFiles();
    } catch (e) {
      setState(() {
        _message = 'Upload failed: $e. Tap Retry or check connection.';
        _isUploading = false;
      });
    }
  }

  Future<void> _fetchFiles() async {
    setState(() {
      _isFetching = true;
      _message = 'Loading files...';
    });

    try {
      final files = await ApiService.getDashboardFiles();
      print('Fetched dashboard files: $files');
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

  Future<void> _downloadFile(int fileId, String filename) async {
    setState(() => _message = 'Downloading $filename...');
    try {
      final response = await ApiService.downloadFile(fileId);
      print(
        'Download response status: ${response.statusCode}, body length: ${response.bodyBytes.length}',
      );
      if (response.statusCode == 200) {
        final extension = filename.split('.').last.toLowerCase();
        final mimeTypes = {
          'txt': 'text/plain',
          'pdf': 'application/pdf',
          'doc': 'application/msword',
          'docx':
              'application/vnd.openxmlformats-officedocument.wordprocessingml.document',
        };
        final mimeType = mimeTypes[extension] ?? 'application/octet-stream';
        final blob = html.Blob([response.bodyBytes], mimeType);
        final url = html.Url.createObjectUrlFromBlob(blob);
        final anchor =
            html.AnchorElement(href: url)
              ..setAttribute('download', filename)
              ..style.display = 'none';
        html.document.body?.append(anchor);
        anchor.click();
        anchor.remove();
        html.Url.revokeObjectUrl(url);
        setState(() => _message = 'Download completed for $filename');
        print('Download triggered for $filename with MIME type: $mimeType');
      } else {
        setState(() => _message = 'Download failed: ${response.body}');
        print('Download failed: ${response.body}');
      }
    } catch (e) {
      setState(() => _message = 'Download error: $e');
      print('Download error: $e');
    }
  }

  // New method: Delete a file
  Future<void> _deleteFile(int fileId, String filename) async {
    try {
      // Show confirmation dialog
      final confirm = await showDialog<bool>(
        context: context,
        builder:
            (context) => AlertDialog(
              backgroundColor: kCardColor,
              title: const Text(
                'Delete File',
                style: TextStyle(color: kTextColor),
              ),
              content: Text(
                'Are you sure you want to delete $filename?',
                style: const TextStyle(color: kSecondaryTextColor),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context, false),
                  child: const Text(
                    'Cancel',
                    style: TextStyle(color: kTextColor),
                  ),
                ),
                TextButton(
                  onPressed: () => Navigator.pop(context, true),
                  child: const Text(
                    'Delete',
                    style: TextStyle(color: kErrorColor),
                  ),
                ),
              ],
            ),
      );

      if (confirm != true) return;

      setState(() => _message = 'Deleting $filename...');
      final response = await ApiService.deleteFile(fileId);
      setState(() {
        _message = response['message'] ?? 'File deleted successfully';
      });
      await _fetchFiles(); // Refresh the file list
    } catch (e) {
      setState(() {
        _message = 'Failed to delete $filename: $e';
      });
    }
  }

  Future<void> _logout() async {
    try {
      await ApiService.logout(token: widget.token);
      if (!mounted) return;
      Navigator.pushNamedAndRemoveUntil(context, '/login', (route) => false);
    } catch (e) {
      setState(() => _message = 'Logout failed: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      backgroundColor: kBackgroundColor,
      body: Row(
        children: [
          // Sidebar (unchanged)
          Container(
            width: 240,
            color: kSidebarColor,
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'ShadowBox',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: kPrimaryColor,
                  ),
                ),
                const SizedBox(height: 32),
                _buildSidebarButton(
                  label: 'Dashboard',
                  route: '/dashboard',
                  icon: Icons.dashboard,
                  isActive: true,
                ),
                _buildSidebarButton(
                  label: 'Files',
                  route: '/files',
                  icon: Icons.folder,
                ),
                _buildSidebarButton(
                  label: 'Settings',
                  route: '/change_password',
                  icon: Icons.settings,
                ),
                const Spacer(),
                _buildSidebarButton(
                  label: 'Logout',
                  onPressed: _logout,
                  icon: Icons.logout,
                ),
              ],
            ),
          ),
          // Main Content
          Expanded(
            child: Column(
              children: [
                // Header (unchanged)
                Container(
                  height: 70,
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  color: kHeaderColor,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      Text(
                        'Hello, ${widget.userId.isNotEmpty ? widget.userId : "User"}',
                        style: theme.textTheme.bodyLarge?.copyWith(
                          color: kTextColor,
                        ),
                      ),
                      const SizedBox(width: 12),
                      CircleAvatar(
                        radius: 18,
                        backgroundColor: Colors.transparent,
                        child: ClipOval(
                          child: Image.network(
                            'https://via.placeholder.com/40',
                            fit: BoxFit.cover,
                            errorBuilder:
                                (context, error, stackTrace) => const Icon(
                                  Icons.person,
                                  color: kSecondaryTextColor,
                                ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                // Main Content
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.all(20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Dashboard',
                          style: theme.textTheme.headlineSmall?.copyWith(
                            color: kPrimaryColor,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 20),
                        Row(
                          children: [
                            ElevatedButton.icon(
                              onPressed: _isUploading ? null : _uploadFile,
                              icon: const Icon(Icons.upload_file),
                              label: const Text('Upload File'),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: kPrimaryColor,
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 16,
                                  vertical: 12,
                                ),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(8),
                                ),
                              ),
                            ),
                            const SizedBox(width: 12),
                            ElevatedButton.icon(
                              onPressed: _isFetching ? null : _fetchFiles,
                              icon: const Icon(Icons.refresh),
                              label: const Text('Refresh'),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.white10,
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 16,
                                  vertical: 12,
                                ),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(8),
                                ),
                              ),
                            ),
                            if (_message.contains('Failed')) ...[
                              const SizedBox(width: 12),
                              ElevatedButton.icon(
                                onPressed: _fetchFiles,
                                icon: const Icon(Icons.replay),
                                label: const Text('Retry'),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.white10,
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 16,
                                    vertical: 12,
                                  ),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                ),
                              ),
                            ],
                          ],
                        ),
                        const SizedBox(height: 20),
                        if (_isUploading || _isFetching)
                          const Center(
                            child: CircularProgressIndicator(
                              color: kPrimaryColor,
                            ),
                          ),
                        Text(
                          _message,
                          style: const TextStyle(color: kErrorColor),
                        ),
                        const SizedBox(height: 20),
                        Expanded(
                          child:
                              _files.isNotEmpty
                                  ? ListView.builder(
                                    itemCount: _files.length,
                                    itemBuilder: (context, index) {
                                      final file = _files[index];
                                      return Card(
                                        color: kCardColor,
                                        shape: RoundedRectangleBorder(
                                          borderRadius: BorderRadius.circular(
                                            8,
                                          ),
                                        ),
                                        child: ListTile(
                                          title: Text(
                                            file['filename'] ?? 'Unknown File',
                                            style: const TextStyle(
                                              color: kTextColor,
                                            ),
                                          ),
                                          subtitle: Text(
                                            'Uploaded: ${file['created_at'] ?? 'N/A'}',
                                            style: const TextStyle(
                                              color: kSecondaryTextColor,
                                            ),
                                          ),
                                          trailing: Row(
                                            mainAxisSize: MainAxisSize.min,
                                            children: [
                                              IconButton(
                                                icon: const Icon(
                                                  Icons.download,
                                                  color: kSecondaryTextColor,
                                                ),
                                                onPressed:
                                                    () => _downloadFile(
                                                      file['id'] ?? 0,
                                                      file['filename'] ??
                                                          'unknown',
                                                    ),
                                              ),
                                              IconButton(
                                                icon: const Icon(
                                                  Icons.delete,
                                                  color: kErrorColor,
                                                ),
                                                onPressed:
                                                    () => _deleteFile(
                                                      file['id'] ?? 0,
                                                      file['filename'] ??
                                                          'unknown',
                                                    ),
                                              ),
                                            ],
                                          ),
                                        ),
                                      );
                                    },
                                  )
                                  : const Center(
                                    child: Text(
                                      'No files available',
                                      style: TextStyle(
                                        color: kSecondaryTextColor,
                                      ),
                                    ),
                                  ),
                        ),
                      ],
                    ),
                  ),
                ),
                // Footer (unchanged)
                Container(
                  padding: const EdgeInsets.all(12),
                  color: kHeaderColor,
                  child: const Text(
                    '© 2025 ShadowBox | Privacy Policy',
                    style: TextStyle(color: Color(0xFF777777), fontSize: 12),
                    textAlign: TextAlign.center,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSidebarButton({
    required String label,
    String? route,
    VoidCallback? onPressed,
    required IconData icon,
    bool isActive = false,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: TextButton(
        onPressed:
            onPressed ??
            () {
              if (route != null && mounted) {
                Navigator.pushNamed(context, route);
              }
            },
        style: TextButton.styleFrom(
          foregroundColor: isActive ? kPrimaryColor : kTextColor,
          backgroundColor: isActive ? Colors.white.withOpacity(0.1) : null,
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        ),
        child: Row(
          children: [
            Icon(icon, size: 20, color: isActive ? kPrimaryColor : kTextColor),
            const SizedBox(width: 8),
            Text(
              label,
              style: TextStyle(
                fontSize: 16,
                color: isActive ? kPrimaryColor : kTextColor,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
