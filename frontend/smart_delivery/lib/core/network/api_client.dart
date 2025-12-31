import 'dart:convert';
import 'package:http/http.dart' as http;
import '../storage/secure_storage.dart';

class ApiClient {
  final SecureStorage _storage = SecureStorage();

  // Base URL de ton backend Django
  static const String baseUrl = 'http://localhost:8000/api';

  Future<http.Response> get(String endpoint) async {
    final token = await _storage.getAccessToken();

    return http.get(Uri.parse('$baseUrl$endpoint'), headers: _headers(token));
  }

  Future<http.Response> post(String endpoint, Map<String, dynamic> body) async {
    final token = await _storage.getAccessToken();

    return http.post(
      Uri.parse('$baseUrl$endpoint'),
      headers: _headers(token),
      body: jsonEncode(body),
    );
  }

  Future<http.Response> patch(
    String endpoint,
    Map<String, dynamic> body,
  ) async {
    final token = await _storage.getAccessToken();

    return http.patch(
      Uri.parse('$baseUrl$endpoint'),
      headers: _headers(token),
      body: jsonEncode(body),
    );
  }

  Map<String, String> _headers(String? token) {
    return {
      'Content-Type': 'application/json',
      'Accept': 'application/json',
      if (token != null) 'Authorization': 'Bearer $token',
    };
  }
}
