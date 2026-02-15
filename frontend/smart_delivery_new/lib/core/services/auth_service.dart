import '../../models/tokens.dart';
import '../../models/me.dart';
import '../storage/app_prefs.dart';
import 'api_client.dart';

enum AppLoginRole { client, courier }

class AuthService {
  final ApiClient _api = ApiClient();

  String _expectedRoleToBackend(AppLoginRole r) {
    // Adapt if your backend uses different strings.
    switch (r) {
      case AppLoginRole.client:
        return 'CLIENT';
      case AppLoginRole.courier:
        return 'COURIER';
    }
  }

  Future<void> setServerBaseUrlFromInput(String ipOrUrl) async {
    var v = ipOrUrl.trim();
    if (v.isEmpty) throw Exception("Server address is required");

    if (!v.startsWith('http://') && !v.startsWith('https://')) {
      v = 'http://$v';
    }
    await AppPrefs.setBaseUrl(v);
  }

  Future<Map<String, dynamic>> registerClient({
    required String email,
    required String password,
  }) async {
    return _api.postJson('/api/auth/register/', {
      'email': email.trim(),
      'password': password,
      'username': email.trim(),
    });
  }

  Future<Map<String, dynamic>> verifyOtp({
    required String email,
    required String code,
  }) async {
    return _api.postJson('/api/auth/verify-otp/', {
      'email': email.trim(),
      'code': code.trim(),
    });
  }

  Future<Tokens> login({
    required String username,
    required String password,
  }) async {
    final data = await _api.postJson('/api/auth/login/', {
      'username': username.trim(),
      'password': password,
    });
    final tokens = Tokens.fromJson(data);
    await AppPrefs.saveTokens(access: tokens.access, refresh: tokens.refresh);
    return tokens;
  }

  Future<Me> me() async {
    final token = await AppPrefs.getAccessToken();
    if (token == null) throw Exception("Not logged in");
    final data = await _api.getJson('/api/auth/me/', bearerToken: token);
    return Me.fromJson(data);
  }

  /// Secure login:
  /// - login (get tokens)
  /// - /me (get role)
  /// - if mismatch => clear tokens and return null
  ///
  /// This returns Me on success, or null if invalid credentials OR role mismatch.
  Future<Me?> loginAndEnforceRole({
    required String username,
    required String password,
    required AppLoginRole expectedRole,
  }) async {
    // Always start clean
    await AppPrefs.clearTokens();

    try {
      await login(username: username, password: password);
      final meData = await me();

      final expected = _expectedRoleToBackend(expectedRole).toUpperCase();
      final actual = meData.role.toUpperCase();

      if (actual != expected) {
        // Role mismatch: treat like invalid login
        await AppPrefs.clearTokens();
        return null;
      }

      return meData;
    } catch (_) {
      // Any error (wrong password, server error, /me failed) => treat as invalid login
      await AppPrefs.clearTokens();
      return null;
    }
  }

  /// Optional resend endpoint (if your backend supports it)
  Future<void> resendOtpIfAvailable(String email) async {
    await _api.postJson('/api/auth/resend-otp/', {'email': email.trim()});
  }

  Future<void> logout() async {
    await AppPrefs.clearTokens();
  }
}
