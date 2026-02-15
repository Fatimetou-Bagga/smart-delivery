import 'dart:convert';
import 'package:http/http.dart' as http;
import '../storage/app_prefs.dart';

class ApiClient {
  Future<Uri> _uri(String path) async {
    final base = (await AppPrefs.getBaseUrl()).replaceAll(RegExp(r'/$'), '');
    final p = path.startsWith('/') ? path : '/$path';
    return Uri.parse('$base$p');
  }

  Future<Map<String, dynamic>> postJson(String path, Map<String, dynamic> body,
      {Map<String, String>? headers}) async {
    final url = await _uri(path);
    final res = await http.post(
      url,
      headers: {
        'Accept': 'application/json',
        'Content-Type': 'application/json',
        ...?headers,
      },
      body: jsonEncode(body),
    );

    final decoded = _decode(res.body);
    if (res.statusCode < 200 || res.statusCode >= 300) {
      throw ApiException(res.statusCode, decoded);
    }
    return decoded;
  }

  Future<Map<String, dynamic>> getJson(String path, {String? bearerToken}) async {
    final url = await _uri(path);
    final res = await http.get(
      url,
      headers: {
        'Accept': 'application/json',
        if (bearerToken != null) 'Authorization': 'Bearer $bearerToken',
      },
    );

    final decoded = _decode(res.body);
    if (res.statusCode < 200 || res.statusCode >= 300) {
      throw ApiException(res.statusCode, decoded);
    }
    return decoded;
  }

  Map<String, dynamic> _decode(String body) {
    try {
      final v = jsonDecode(body);
      if (v is Map<String, dynamic>) return v;
      return {'data': v};
    } catch (_) {
      return {'detail': body};
    }
  }
  Future<Map<String, dynamic>> patchJson(String path, Map<String, dynamic> body,
    {Map<String, String>? headers}) async {
  final url = await _uri(path);
  final res = await http.patch(
    url,
    headers: {
      'Accept': 'application/json',
      'Content-Type': 'application/json',
      ...?headers,
    },
    body: jsonEncode(body),
  );

  final decoded = _decode(res.body);
  if (res.statusCode < 200 || res.statusCode >= 300) {
    throw ApiException(res.statusCode, decoded);
  }
  return decoded;
}

}

class ApiException implements Exception {
  final int statusCode;
  final Map<String, dynamic> body;
  ApiException(this.statusCode, this.body);

  String message() {
    // Your backend commonly uses {"detail": "..."}
    final d = body['detail'];
    if (d is String && d.isNotEmpty) return d;
    return 'Request failed ($statusCode)';
  }

  @override
  String toString() => message();
}
