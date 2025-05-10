import 'package:flutter/foundation.dart';
import '../services/api_service.dart';

class AppState extends ChangeNotifier {
  String? _token;
  int? _userId;
  List<Map<String, dynamic>> _files = [];
  String? _errorMessage;

  String? get token => _token;
  int? get userId => _userId;
  List<Map<String, dynamic>> get files => _files;
  String? get errorMessage => _errorMessage;

  final ApiService _apiService = ApiService();

  Future<void> signup(String username, String email, String password) async {
    try {
      final response = await _apiService.signup(username, email, password);
      if (response['error'] != null) {
        _errorMessage = response['error'];
      } else {
        _errorMessage = null;
      }
      notifyListeners();
    } catch (e) {
      _errorMessage = 'Signup failed: $e';
      notifyListeners();
    }
  }

  Future<void> login(String username, String password) async {
    try {
      final response = await _apiService.login(username, password);
      if (response['token'] != null) {
        _token = response['token'];
        _userId = response['user_id'];
        _errorMessage = null;
        await fetchFiles(); // Load files after login
      } else {
        _errorMessage = response['error'];
      }
      notifyListeners();
    } catch (e) {
      _errorMessage = 'Login failed: $e';
      notifyListeners();
    }
  }

  Future<void> fetchFiles() async {
    if (_token == null) return;
    try {
      _files = await _apiService.getDashboard(_token!);
      _errorMessage = null;
      notifyListeners();
    } catch (e) {
      _errorMessage = 'Failed to fetch files: $e';
      notifyListeners();
    }
  }

  Future<void> uploadFile(String filePath) async {
    if (_token == null) return;
    try {
      final response = await _apiService.uploadFile(filePath, _token!);
      if (response['error'] != null) {
        _errorMessage = response['error'];
      } else {
        _errorMessage = null;
        await fetchFiles(); // Refresh file list
      }
      notifyListeners();
    } catch (e) {
      _errorMessage = 'Upload failed: $e';
      notifyListeners();
    }
  }

  Future<List<int>> downloadFile(int fileId) async {
    if (_token == null) throw Exception('Not authenticated');
    try {
      final fileData = await _apiService.downloadFile(fileId, _token!);
      _errorMessage = null;
      notifyListeners();
      return fileData;
    } catch (e) {
      _errorMessage = 'Download failed: $e';
      notifyListeners();
      rethrow;
    }
  }

  Future<void> logout() async {
    if (_token == null) return;
    try {
      await _apiService.logout(_token!);
      _token = null;
      _userId = null;
      _files = [];
      _errorMessage = null;
      notifyListeners();
    } catch (e) {
      _errorMessage = 'Logout failed: $e';
      notifyListeners();
    }
  }
}