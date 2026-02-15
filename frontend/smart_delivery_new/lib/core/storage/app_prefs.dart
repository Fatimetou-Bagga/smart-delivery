import 'package:shared_preferences/shared_preferences.dart';

class AppPrefs {
  static const _kBaseUrl = 'base_url';
  static const _kAccess = 'access_token';
  static const _kRefresh = 'refresh_token';

  static Future<String> getBaseUrl() async {
    final sp = await SharedPreferences.getInstance();
    return sp.getString(_kBaseUrl) ?? 'http://localhost:8000';
  }

  static Future<void> setBaseUrl(String value) async {
    final sp = await SharedPreferences.getInstance();
    await sp.setString(_kBaseUrl, value);
  }

  static Future<void> saveTokens({required String access, String? refresh}) async {
    final sp = await SharedPreferences.getInstance();
    await sp.setString(_kAccess, access);
    if (refresh != null) await sp.setString(_kRefresh, refresh);
  }

  static Future<String?> getAccessToken() async {
    final sp = await SharedPreferences.getInstance();
    return sp.getString(_kAccess);
  }

  static Future<void> clearTokens() async {
    final sp = await SharedPreferences.getInstance();
    await sp.remove(_kAccess);
    await sp.remove(_kRefresh);
  }
}
