import 'dart:convert';
import 'package:http/http.dart' as http;

class ApiService {
  static const String baseUrl = 'http://127.0.0.1:5000';

  // Signup
  Future<Map<String, dynamic>> signup(String username, String email, String password) async {
    final response = await http.post(
      Uri.parse('$baseUrl/signup'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'username': username,
        'email': email,
        'password': password,
      }),
    );
    return jsonDecode(response.body);
  }

  // Login
  Future<Map<String, dynamic>> login(String username, String password) async {
    final response = await http.post(
      Uri.parse('$baseUrl/login'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'username': username,
        'password': password,
      }),
    );
    return jsonDecode(response.body);
  }

  // Dashboard
  Future<List<Map<String, dynamic>>> getDashboard(String token) async {
    final response = await http.get(
      Uri.parse('$baseUrl/dashboard'),
      headers: {
        'Authorization': 'Bearer $token',
      },
    );
    final data = jsonDecode(response.body);
    return List<Map<String, dynamic>>.from(data['files']);
  }

  // Upload file
  Future<Map<String, dynamic>> uploadFile(String filePath, String token) async {
    var request = http.MultipartRequest('POST', Uri.parse('$baseUrl/upload'));
    request.headers['Authorization'] = 'Bearer $token';
    request.files.add(await http.MultipartFile.fromPath('file', filePath));
    final response = await request.send();
    final responseBody = await response.stream.bytesToString();
    return jsonDecode(responseBody);
  }

  // Download file
  Future<List<int>> downloadFile(int fileId, String token) async {
    final response = await http.get(
      Uri.parse('$baseUrl/download/$fileId'),
      headers: {
        'Authorization': 'Bearer $token',
      },
    );
    if (response.statusCode == 200) {
      return response.bodyBytes;
    } else {
      throw Exception('Failed to download file: ${response.body}');
    }
  }

  // Logout
  Future<Map<String, dynamic>> logout(String token) async {
    final response = await http.post(
      Uri.parse('$baseUrl/logout'),
      headers: {
        'Authorization': 'Bearer $token',
      },
    );
    return jsonDecode(response.body);
  }
}