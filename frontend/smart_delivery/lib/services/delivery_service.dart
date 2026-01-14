import 'dart:convert';
import '../core/network/api_client.dart';
import 'package:http/http.dart' as http;

class DeliveryService {
  final ApiClient _api = ApiClient();

  /// Demandes disponibles (PENDING)
  Future<List<dynamic>> getAvailableRequests() async {
    final response = await _api.get('/delivery-requests/available/');

    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    }
    throw Exception('Erreur chargement demandes');
  }

  /// Accepter une demande
  Future<void> acceptRequest(int requestId) async {
    final response = await _api.post('/deliveries/accept/', {
      'delivery_request_id': requestId,
    });

    if (response.statusCode != 201) {
      throw Exception('Impossible accepter la demande');
    }
  }

  /// Mes livraisons
  Future<List<dynamic>> getMyDeliveries() async {
    final response = await _api.get('/deliveries/');

    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    }
    throw Exception('Erreur chargement livraisons');
  }

  Future<void> updateDeliveryStatus(int deliveryId, String status) async {
    final response = await _api.patch('/deliveries/$deliveryId/', {
      'status': status,
    });

    if (response.statusCode != 200) {
      throw Exception('Erreur changement de statut');
    }
  }

  Future<void> cancelRequest(int id) async {
    final response = await _api.post('/delivery-requests/$id/cancel/', {});

    if (response.statusCode != 200) {
      throw Exception('Impossible d’annuler');
    }
  }
}
