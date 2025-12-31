import 'dart:convert';
import 'package:smart_delivery/core/constants/api_urls.dart';

import '../core/network/api_client.dart';
import '../core/storage/secure_storage.dart';
import '../models/user_model.dart';

class AuthService {
  final ApiClient _apiClient = ApiClient();
  final SecureStorage _storage = SecureStorage();

  /// LOGIN
  /// Appelle /auth/login/ et sauvegarde les tokens
  Future<UserModel> login({
    required String username,
    required String password,
  }) async {
    final response = await _apiClient.post(ApiUrls.login, {
      'username': username,
      'password': password,
    });

    if (response.statusCode != 200) {
      throw Exception('Login failed');
    }

    final data = jsonDecode(response.body);

    // Sauvegarde des tokens JWT
    await _storage.saveTokens(
      accessToken: data['access'],
      refreshToken: data['refresh'],
    );

    // Si ton backend retourne l'utilisateur
    if (data.containsKey('user')) {
      return UserModel.fromJson(data['user']);
    }

    // Sinon (fallback) : on crée un user minimal
    return UserModel(id: 0, username: username, email: '', role: '');
  }

  /// REGISTER
  /// Appelle /auth/register/
  Future<void> register({
    required String username,
    required String email,
    required String password,
    required String role,
  }) async {
    final response = await _apiClient.post(ApiUrls.register, {
      'username': username,
      'email': email,
      'password': password,
      'role': role,
    });

    if (response.statusCode != 201 && response.statusCode != 200) {
      throw Exception('Registration failed');
    }
  }

  /// LOGOUT
  Future<void> logout() async {
    await _storage.clearTokens();
  }

  Future<UserModel> getCurrentUser() async {
    final response = await _apiClient.get('/auth/me/');

    if (response.statusCode == 200) {
      return UserModel.fromJson(jsonDecode(response.body));
    } else {
      throw Exception('Not authenticated');
    }
  }
}
