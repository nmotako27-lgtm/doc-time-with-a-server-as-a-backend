import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter/foundation.dart';

class ApiService {
  // Use localhost for Web/iOS and 10.0.2.2 for Android emulator
  static String get baseUrl => kIsWeb ? 'http://localhost:5000/api' : 'http://192.168.137.210:5000/api';

  // Helper to get full image URL (prepends server address to relative paths)
  static String getFullImageUrl(String? path) {
    if (path == null || path.isEmpty) return '';
    if (path.startsWith('http')) return path;
    // Remove /api from baseUrl to get the root server URL
    final rootUrl = baseUrl.replaceAll('/api', '');
    return '$rootUrl$path';
  }

  // Generic method for POST requests
  static Future<Map<String, dynamic>> post(String endpoint, Map<String, dynamic> data, {bool requiresAuth = false}) async {
    final headers = {'Content-Type': 'application/json'};
    
    if (requiresAuth) {
      final token = await getToken();
      if (token != null) {
        headers['x-auth-token'] = token;
      }
    }

    try {
      final url = '$baseUrl/$endpoint';
      print('🚀 Calling API: $url');
      final response = await http.post(
        Uri.parse(url),
        headers: headers,
        body: jsonEncode(data),
      );

      return _handleResponse(response);
    } catch (e) {
      return {'success': false, 'msg': 'Network error: $e'};
    }
  }

  // Generic method for PUT requests
  static Future<Map<String, dynamic>> put(String endpoint, Map<String, dynamic> data, {bool requiresAuth = false}) async {
    final headers = {'Content-Type': 'application/json'};
    
    if (requiresAuth) {
      final token = await getToken();
      if (token != null) {
        headers['x-auth-token'] = token;
      }
    }

    try {
      final url = '$baseUrl/$endpoint';
      print('🚀 Calling API (PUT): $url');
      final response = await http.put(
        Uri.parse(url),
        headers: headers,
        body: jsonEncode(data),
      );

      return _handleResponse(response);
    } catch (e) {
      return {'success': false, 'msg': 'Network error: $e'};
    }
  }

  // Generic method for DELETE requests
  static Future<Map<String, dynamic>> delete(String endpoint, {bool requiresAuth = false}) async {
    final headers = {'Content-Type': 'application/json'};
    
    if (requiresAuth) {
      final token = await getToken();
      if (token != null) {
        headers['x-auth-token'] = token;
      }
    }

    try {
      final url = '$baseUrl/$endpoint';
      print('🚀 Calling API (DELETE): $url');
      final response = await http.delete(
        Uri.parse(url),
        headers: headers,
      );

      return _handleResponse(response);
    } catch (e) {
      return {'success': false, 'msg': 'Network error: $e'};
    }
  }

  // Generic method for GET requests
  static Future<Map<String, dynamic>> get(String endpoint, {Map<String, String>? queryParams, bool requiresAuth = false}) async {
    final headers = {'Content-Type': 'application/json'};
    
    if (requiresAuth) {
      final token = await getToken();
      if (token != null) {
        headers['x-auth-token'] = token;
      }
    }

    try {
      var uri = Uri.parse('$baseUrl/$endpoint');
      if (queryParams != null && queryParams.isNotEmpty) {
        uri = uri.replace(queryParameters: queryParams);
      }
      print('🚀 Calling API (GET): $uri');

      final response = await http.get(uri, headers: headers);
      return _handleResponse(response);
    } catch (e) {
      return {'success': false, 'msg': 'Network error: $e'};
    }
  }

  // Method for File Upload (Cross-platform)
  static Future<Map<String, dynamic>> uploadFile(String endpoint, dynamic fileSource) async {
    try {
      var request = http.MultipartRequest('POST', Uri.parse('$baseUrl/$endpoint'));
      
      if (kIsWeb) {
        // fileSource should be XFile on Web
        final bytes = await fileSource.readAsBytes();
        request.files.add(http.MultipartFile.fromBytes(
          'image',
          bytes,
          filename: fileSource.name,
        ));
      } else {
        // fileSource should be String (filePath) on Mobile
        request.files.add(await http.MultipartFile.fromPath('image', fileSource));
      }
      
      var streamedResponse = await request.send();
      var response = await http.Response.fromStream(streamedResponse);
      
      return _handleResponse(response);
    } catch (e) {
      return {'success': false, 'msg': 'Upload error: $e'};
    }
  }

  static Map<String, dynamic> _handleResponse(http.Response response) {
    if (response.statusCode >= 200 && response.statusCode < 300) {
      final data = jsonDecode(response.body);
      return {'success': true, 'data': data};
    } else {
      try {
        final data = jsonDecode(response.body);
        String msg = data['msg'] ?? 'Unknown error';
        if (data['errors'] != null && data['errors'].isNotEmpty) {
           msg = data['errors'][0]['msg'];
        }
        return {'success': false, 'msg': msg};
      } catch (e) {
         return {'success': false, 'msg': 'Server error: ${response.statusCode}'};
      }
    }
  }

  // Token management
  static Future<void> saveAuthData(String token, Map<String, dynamic> user) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('token', token);
    await prefs.setString('user', jsonEncode(user));
  }

  static Future<String?> getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('token');
  }

  static Future<Map<String, dynamic>?> getUser() async {
    final prefs = await SharedPreferences.getInstance();
    final userStr = prefs.getString('user');
    if (userStr != null) {
      return jsonDecode(userStr);
    }
    return null;
  }

  static Future<void> logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('token');
    await prefs.remove('user');
  }
}
