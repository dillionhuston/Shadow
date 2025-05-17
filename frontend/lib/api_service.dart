import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:http_parser/http_parser.dart';

class ApiService {
  static const String _baseUrl = String.fromEnvironment(
    'API_BASE_URL',
    defaultValue: 'http://127.0.0.1:5000/',
  );
  static String? _token;
  static const Duration _timeoutDuration = Duration(seconds: 45);
  static const int _maxRetries = 3;

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
    final data = await _makeRequest(
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
    return data;
  }

  static Future<Map<String, dynamic>> login({
    required String username,
    required String password,
  }) async {
    print('Attempting login to ${_baseUrl}login with username: $username');
    final data = await _makeRequest(
      () => http.post(
        Uri.parse('${_baseUrl}login'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'username': username, 'password': password}),
      ),
      'login',
    );
    if (data['token'] is String) setToken(data['token']);
    print('Login successful, token set');
    return data;
  }

  static Future<void> logout({String? token}) async {
    final authToken = token ?? _token;
    _validateToken(authToken);
    await _makeRequest(
      () => http.post(
        Uri.parse('${_baseUrl}logout'),
        headers: {'Authorization': 'Bearer $authToken'},
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
    final data = await _makeRequest(
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
    return data;
  }

  static Future<List<dynamic>> getDashboardFiles() async {
    _validateToken();
    final data = await _makeRequest(
      () => http.get(
        Uri.parse('${_baseUrl}dashboard'),
        headers: {'Authorization': 'Bearer $_token'},
      ),
      'dashboard',
    );
    return data['files'] ?? [];
  }

  static Future<List<dynamic>> getServerFiles() async {
    _validateToken();
    final data = await _makeRequest(
      () => http.get(
        Uri.parse('${_baseUrl}files'),
        headers: {'Authorization': 'Bearer $_token'},
      ),
      'files',
    );
    return data['files'] ?? [];
  }

  static Future<Map<String, dynamic>> uploadFile({
    required String fileName,
    required List<int> fileBytes,
    String? token,
  }) async {
    final authToken = token ?? _token;
    _validateToken(authToken);
    if (fileBytes.isEmpty) throw ApiException('Empty file');
    final request =
        http.MultipartRequest('POST', Uri.parse('${_baseUrl}upload'))
          ..headers['Authorization'] = 'Bearer $authToken'
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

  static Future<http.Response> downloadFile(int fileId) async {
    _validateToken();
    return await _makeDownloadRequest(
      () => http.get(
        Uri.parse('${_baseUrl}download/$fileId'),
        headers: {'Authorization': 'Bearer $_token'},
      ),
      'download/$fileId',
    );
  }

  static void _validateToken([String? token]) {
    final authToken = token ?? _token;
    if (authToken == null || authToken.isEmpty)
      throw ApiException('Not logged in');
  }

  static Future<Map<String, dynamic>> _makeRequest(
    Future<http.Response> Function() requestFn,
    String endpoint,
  ) async {
    for (int attempt = 1; attempt <= _maxRetries; attempt++) {
      try {
        print('Attempt $attempt: Requesting ${_baseUrl}$endpoint');
        final response = await requestFn().timeout(
          _timeoutDuration,
          onTimeout: () {
            print('Timeout on $endpoint (attempt $attempt)');
            throw ApiException('Timeout on $endpoint');
          },
        );
        print('Response: ${response.statusCode} ${response.body}');
        try {
          final data = jsonDecode(response.body);
          if (response.statusCode >= 200 && response.statusCode < 300)
            return data;
          if (response.statusCode == 401) clearToken();
          throw ApiException(data['error'] ?? 'Failed: ${response.statusCode}');
        } on FormatException {
          throw ApiException('Invalid JSON response: ${response.body}');
        }
      } on SocketException catch (e) {
        print('SocketException on $endpoint (attempt $attempt): $e');
        if (attempt == _maxRetries) {
          throw ApiException(
            'Cannot connect to server. Check URL ($_baseUrl) or server status.',
          );
        }
      }
      await Future.delayed(
        Duration(seconds: attempt * 2),
      ); // Exponential backoff
    }
    throw ApiException('Failed after $_maxRetries attempts.');
  }

  static Future<http.Response> _makeDownloadRequest(
    Future<http.Response> Function() requestFn,
    String endpoint,
  ) async {
    for (int attempt = 1; attempt <= _maxRetries; attempt++) {
      try {
        print('Attempt $attempt: Downloading ${_baseUrl}$endpoint');
        final response = await requestFn().timeout(
          _timeoutDuration,
          onTimeout: () {
            print('Timeout on $endpoint (attempt $attempt)');
            throw ApiException('Timeout on $endpoint');
          },
        );
        print('Download response: ${response.statusCode}');
        if (response.statusCode >= 200 && response.statusCode < 300) {
          return response;
        }
        if (response.statusCode == 401) clearToken();
        final data = jsonDecode(response.body);
        throw ApiException(
          data['error'] ?? 'Download failed: ${response.statusCode}',
        );
      } on SocketException catch (e) {
        print('SocketException on $endpoint (attempt $attempt): $e');
        if (attempt == _maxRetries) {
          throw ApiException(
            'Cannot connect to server for download. Check URL ($_baseUrl).',
          );
        }
      } on FormatException {
        throw ApiException('Invalid response format from server.');
      }
      await Future.delayed(
        Duration(seconds: attempt * 2),
      ); // Exponential backoff
    }
    throw ApiException('Download failed after $_maxRetries attempts.');
  }
}

class ApiException implements Exception {
  final String message;
  ApiException(this.message);
  @override
  String toString() => message;
}
