// import 'dart:convert';
// import 'package:http/http.dart' as http;
// import '../constants/api_urls.dart';
// import '../storage/secure_storage.dart';

// class ApiClient {
//   final SecureStorage storage;

//   ApiClient(this.storage);

//   Future<Map<String, String>> _headers() async {
//     final token = await storage.getToken();
//     return {
//       'Content-Type': 'application/json',
//       if (token != null) 'Authorization': 'Bearer $token',
//     };
//   }

//   Future<dynamic> get(String endpoint) async {
//     final response = await http.get(
//       Uri.parse(ApiUrls.baseUrl + endpoint),
//       headers: await _headers(),
//     );
//     return _handleResponse(response);
//   }

//   Future<dynamic> post(String endpoint, Map data) async {
//     final response = await http.post(
//       Uri.parse(ApiUrls.baseUrl + endpoint),
//       headers: await _headers(),
//       body: jsonEncode(data),
//     );
//     return _handleResponse(response);
//   }

//   Future<dynamic> patch(String endpoint, Map data) async {
//     final response = await http.patch(
//       Uri.parse(ApiUrls.baseUrl + endpoint),
//       headers: await _headers(),
//       body: jsonEncode(data),
//     );
//     return _handleResponse(response);
//   }

//   dynamic _handleResponse(http.Response response) {
//     if (response.statusCode >= 200 && response.statusCode < 300) {
//       return response.body.isNotEmpty ? jsonDecode(response.body) : null;
//     } else {
//       throw Exception('API Error ${response.statusCode}: ${response.body}');
//     }
//   }
// }
