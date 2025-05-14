import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:http_parser/http_parser.dart';

class ApiService {
  static const String _baseUrl = String.fromEnvironment(
    'API_BASE_URL',
    defaultValue: 'http://192.168.0.14:5000/',
  );
  static String? _token;
  static const Duration _timeoutDuration = Duration(
    seconds: 30,
  ); // Increased for reliability

  static void setToken(String token) {
    if (token.trim().isEmpty) throw ApiException('Invalid token');
    _token = token.trim();
  }

  static String? getToken() => _token;

  static void clearToken() => _token = null;

  static Future<Map<String, dynamic>> signup({
    required String username,
    required String email,
    required String password,
  }) async {
    return _makeRequest(
      () => http.post(
        Uri.parse('${_baseUrl}signup'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'username': username,
          'email': email,
          'password': password,
        }),
      ),
      'signup',
    );
  }

  static Future<Map<String, dynamic>> login({
    required String username,
    required String password,
  }) async {
    final data = await _makeRequest(
      () => http.post(
        Uri.parse('${_baseUrl}login'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'username': username, 'password': password}),
      ),
      'login',
    );
    if (data['token'] is String) setToken(data['token']);
    return data;
  }

  static Future<void> logout() async {
    _validateToken();
    await _makeRequest(
      () => http.post(
        Uri.parse('${_baseUrl}logout'),
        headers: {'Authorization': 'Bearer $_token'},
      ),
      'logout',
    );
    clearToken();
  }

  static Future<Map<String, dynamic>> changePassword({
    required String currentPassword,
    required String newPassword,
  }) async {
    _validateToken();
    return _makeRequest(
      () => http.post(
        Uri.parse('${_baseUrl}change-password'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $_token',
        },
        body: jsonEncode({
          'currentPassword': currentPassword,
          'newPassword': newPassword,
        }),
      ),
      'change-password',
    );
  }

  static Future<List<dynamic>> getDashboardFiles() async {
    _validateToken();
    final data = await _makeRequest(
      () => http.get(
        Uri.parse('${_baseUrl}files'),
        headers: {'Authorization': 'Bearer $_token'},
      ),
      'dashboard',
    );
    return data['files'] ?? [];
  }

  static Future<Map<String, dynamic>> uploadFile({
    required String fileName,
    required List<int> fileBytes,
  }) async {
    _validateToken();
    if (fileBytes.isEmpty) throw ApiException('Empty file');
    final request =
        http.MultipartRequest('POST', Uri.parse('${_baseUrl}upload'))
          ..headers['Authorization'] = 'Bearer $_token'
          ..files.add(
            http.MultipartFile.fromBytes(
              'file',
              fileBytes,
              filename: fileName,
              contentType: MediaType('application', 'octet-stream'),
            ),
          );
    final response = await request.send().timeout(_timeoutDuration);
    final body = await response.stream.bytesToString();
    final data = jsonDecode(body);
    if (response.statusCode == 201) return data;
    if (response.statusCode == 401) clearToken();
    throw ApiException(
      data['error'] ?? 'Upload failed: ${response.statusCode}',
    );
  }

  static void _validateToken() {
    if (_token == null || _token!.isEmpty) throw ApiException('Not logged in');
  }

  static Future<Map<String, dynamic>> _makeRequest(
    Future<http.Response> Function() requestFn,
    String endpoint,
  ) async {
    try {
      print('Requesting: $_baseUrl$endpoint');
      final response = await requestFn().timeout(
        _timeoutDuration,
        onTimeout: () => throw ApiException('Timeout on $endpoint'),
      );
      print('Response: ${response.statusCode} ${response.body}');
      final data = jsonDecode(response.body);
      if (response.statusCode >= 200 && response.statusCode < 300) return data;
      if (response.statusCode == 401) clearToken();
      throw ApiException(data['error'] ?? 'Failed: ${response.statusCode}');
    } on SocketException {
      throw ApiException(
        'Cannot connect to server. Check server and URL ($_baseUrl).',
      );
    }
  }
}

class ApiException implements Exception {
  final String message;
  ApiException(this.message);
  @override
  String toString() => message;
}
