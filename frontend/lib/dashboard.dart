import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:universal_html/html.dart' as html;
import 'api_service.dart';

// UI Constants
const kPrimaryColor = Color(0xFF00BCD4);
const kBackgroundColor = Color(0xFF121212);
const kHeaderColor = Color(0xFF1F1F1F);
const kCardColor = Color(0xFF2A2A2A);
const kErrorColor = Color(0xFFF44336);
const kTextColor = Colors.white;
const kSecondaryTextColor = Color(0xFF777777);
const kSuccessColor = Color(0xFF4CAF50);
const kSecondaryColor = Color(0xFF2A2A2A);
const kSidebarColor = Color(0xFF1A1A1A);

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
    ApiService.setToken(widget.token);
    _fetchFiles();
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
      if (file.bytes == null) {
        setState(() {
          _message = 'File data unavailable';
          _isUploading = false;
        });
        return;
      }

      if (file.size > 10 * 1024 * 1024) {
        setState(() {
          _message = 'File size exceeds 10MB';
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
        _message = 'Upload failed: $e';
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
      setState(() {
        _files = files;
        _message =
            _files.isEmpty ? 'No files available. Try uploading one.' : '';
        _isFetching = false;
      });
    } catch (e) {
      setState(() {
        _message = 'Failed to load files: $e';
        _isFetching = false;
      });
    }
  }

  Future<void> _downloadFile(int fileId, String filename) async {
    setState(() => _message = 'Downloading $filename...');
    try {
      final response = await ApiService.downloadFile(fileId);

      if (response.statusCode == 200) {
        final blob = html.Blob([response.bodyBytes]);
        final url = html.Url.createObjectUrlFromBlob(blob);
        final anchor =
            html.AnchorElement(href: url)
              ..setAttribute('download', filename)
              ..style.display = 'none';
        html.document.body?.append(anchor);
        anchor.click();
        html.Url.revokeObjectUrl(url);
        anchor.remove();
        setState(() => _message = 'Download completed for $filename');
      } else {
        setState(() => _message = 'Download failed: ${response.statusCode}');
      }
    } catch (e) {
      setState(() => _message = 'Download error: $e');
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
          _buildSidebar(),
          Expanded(
            child: Column(
              children: [
                _buildHeader(theme),
                _buildMainContent(theme),
                _buildFooter(),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSidebar() {
    return Container(
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
            route: '/settings',
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
    );
  }

  Widget _buildHeader(ThemeData theme) {
    return Container(
      height: 70,
      padding: const EdgeInsets.symmetric(horizontal: 20),
      color: kHeaderColor,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            'Dashboard',
            style: theme.textTheme.titleLarge?.copyWith(
              color: kTextColor,
              fontWeight: FontWeight.bold,
            ),
          ),
          Row(
            children: [
              Text(
                'Hello, ${widget.userId.isNotEmpty ? widget.userId : "User"}',
                style: theme.textTheme.bodyLarge?.copyWith(color: kTextColor),
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
        ],
      ),
    );
  }

  Widget _buildMainContent(ThemeData theme) {
    return Expanded(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'My Files',
                  style: theme.textTheme.headlineSmall?.copyWith(
                    color: kTextColor,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                _buildActionButtons(),
              ],
            ),
            const SizedBox(height: 20),
            if (_isUploading || _isFetching)
              const LinearProgressIndicator(
                color: kPrimaryColor,
                backgroundColor: kSecondaryColor,
              ),
            if (_message.isNotEmpty)
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 8.0),
                child: Text(
                  _message,
                  style: TextStyle(
                    color:
                        _message.contains('failed') ||
                                _message.contains('Failed') ||
                                _message.contains('error')
                            ? kErrorColor
                            : kSuccessColor,
                  ),
                ),
              ),
            const SizedBox(height: 10),
            _buildFilesList(),
          ],
        ),
      ),
    );
  }

  Widget _buildActionButtons() {
    return Row(
      children: [
        ElevatedButton.icon(
          onPressed: _isUploading ? null : _uploadFile,
          icon: const Icon(Icons.upload_file),
          label: const Text('Upload File'),
          style: ElevatedButton.styleFrom(
            backgroundColor: kPrimaryColor,
            foregroundColor: Colors.white,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
          ),
        ),
        const SizedBox(width: 12),
        IconButton(
          onPressed: _isFetching ? null : _fetchFiles,
          icon: const Icon(Icons.refresh),
          tooltip: 'Refresh files',
          color: kTextColor,
        ),
      ],
    );
  }

  Widget _buildFilesList() {
    return Expanded(
      child:
          _files.isNotEmpty
              ? ListView.builder(
                itemCount: _files.length,
                itemBuilder: (context, index) {
                  final file = _files[index];
                  return Card(
                    color: kCardColor,
                    margin: const EdgeInsets.only(bottom: 10),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: ListTile(
                      leading: _getFileIcon(file['filename'] ?? ''),
                      title: Text(
                        file['filename'] ?? 'Unknown File',
                        style: const TextStyle(
                          color: kTextColor,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      subtitle: Text(
                        'Uploaded: ${file['created_at'] ?? 'N/A'}',
                        style: const TextStyle(color: kSecondaryTextColor),
                      ),
                      trailing: IconButton(
                        icon: const Icon(Icons.download, color: kPrimaryColor),
                        tooltip: 'Download file',
                        onPressed:
                            () => _downloadFile(
                              file['id'] ?? 0,
                              file['filename'] ?? 'unknown',
                            ),
                      ),
                    ),
                  );
                },
              )
              : Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.cloud_upload_outlined,
                      size: 64,
                      color: kSecondaryTextColor.withOpacity(0.5),
                    ),
                    const SizedBox(height: 16),
                    const Text(
                      'No files available',
                      style: TextStyle(
                        color: kSecondaryTextColor,
                        fontSize: 16,
                      ),
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      'Upload your first file to get started',
                      style: TextStyle(
                        color: kSecondaryTextColor,
                        fontSize: 14,
                      ),
                    ),
                  ],
                ),
              ),
    );
  }

  Widget _getFileIcon(String filename) {
    final extension = filename.split('.').last.toLowerCase();

    IconData iconData;
    Color iconColor;

    switch (extension) {
      case 'pdf':
        iconData = Icons.picture_as_pdf;
        iconColor = Colors.red;
        break;
      case 'doc':
      case 'docx':
        iconData = Icons.description;
        iconColor = Colors.blue;
        break;
      case 'txt':
        iconData = Icons.article;
        iconColor = Colors.grey;
        break;
      default:
        iconData = Icons.insert_drive_file;
        iconColor = Colors.amber;
    }

    return Container(
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: kBackgroundColor,
        borderRadius: BorderRadius.circular(6),
      ),
      child: Icon(iconData, color: iconColor, size: 24),
    );
  }

  Widget _buildFooter() {
    return Container(
      padding: const EdgeInsets.all(12),
      color: kHeaderColor,
      child: const Text(
        '© 2025 ShadowBox | Privacy Policy',
        style: TextStyle(color: kSecondaryTextColor, fontSize: 12),
        textAlign: TextAlign.center,
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
