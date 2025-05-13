import 'dart:convert';
import 'package:http/http.dart' as http;

class ApiService {
  static const String baseUrl =
      'http://127.0.0.1:5000/'; // Replace with your actual backend URL
  static String? _token;

  /// Sets the authentication token for API requests
  static Future<void> setToken(String token) async {
    _token = token;
  }

  /// Clears the authentication token (e.g., on logout)
  static void clearToken() {
    _token = null;
  }

  /// Signs up a new user with email and password
  static Future<Map<String, dynamic>> signup(
    String username,
    String email,
    String password,
  ) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/signup'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'username': username,
          'email': email,
          'password': password,
        }),
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        return jsonDecode(response.body) as Map<String, dynamic>;
      } else {
        throw Exception(
          'Failed to sign up: ${response.statusCode} - ${response.body}',
        );
      }
    } catch (e) {
      throw Exception('Signup error: $e');
    }
  }

  /// Logs in a user and retrieves an authentication token
  static Future<Map<String, dynamic>> login(
    String email,
    String password,
  ) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/login'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'email': email, 'password': password}),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body) as Map<String, dynamic>;
        if (data['token'] != null) {
          _token = data['token'] as String;
        }
        return data;
      } else {
        throw Exception(
          'Failed to login: ${response.statusCode} - ${response.body}',
        );
      }
    } catch (e) {
      throw Exception('Login error: $e');
    }
  }

  /// Changes the user's password
  static Future<Map<String, dynamic>> changePassword(
    String currentPassword,
    String newPassword,
  ) async {
    if (_token == null) {
      throw Exception('No authentication token available. Please login first.');
    }

    try {
      final response = await http.post(
        Uri.parse('$baseUrl/change-password'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $_token',
        },
        body: jsonEncode({
          'currentPassword': currentPassword,
          'newPassword': newPassword,
        }),
      );

      if (response.statusCode == 200) {
        return jsonDecode(response.body) as Map<String, dynamic>;
      } else {
        throw Exception(
          'Failed to change password: ${response.statusCode} - ${response.body}',
        );
      }
    } catch (e) {
      throw Exception('Change password error: $e');
    }
  }

  /// Retrieves the list of files for the dashboard
  static Future<List<dynamic>> getDashboardFiles() async {
    if (_token == null) {
      throw Exception('No authentication token available. Please login first.');
    }

    try {
      final response = await http.get(
        Uri.parse('$baseUrl/dashboard'),
        headers: {'Authorization': 'Bearer $_token'},
      );

      if (response.statusCode == 200) {
        return jsonDecode(response.body) as List<dynamic>;
      } else {
        throw Exception(
          'Failed to load dashboard files: ${response.statusCode} - ${response.body}',
        );
      }
    } catch (e) {
      throw Exception('Dashboard files error: $e');
    }
  }

  /// Uploads a file to the dashboard
  static Future<Map<String, dynamic>> uploadFile(
    String fileName,
    String fileData,
  ) async {
    if (_token == null) {
      throw Exception('No authentication token available. Please login first.');
    }

    try {
      final response = await http.post(
        Uri.parse('$baseUrl/dashboard/upload'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $_token',
        },
        body: jsonEncode({'fileName': fileName, 'fileData': fileData}),
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        return jsonDecode(response.body) as Map<String, dynamic>;
      } else {
        throw Exception(
          'Failed to upload file: ${response.statusCode} - ${response.body}',
        );
      }
    } catch (e) {
      throw Exception('File upload error: $e');
    }
  }
}
