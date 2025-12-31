import 'dart:convert';

import '../core/network/api_client.dart';

class DeliveryRequestService {
  final ApiClient _apiClient = ApiClient();

  Future<void> createDeliveryRequest({
    required String productType,
    required String description,
    required double weight,
    required String pickupAddress,
    required String deliveryAddress,
  }) async {
    final response = await _apiClient.post('/delivery-requests/', {
      'product_type': productType,
      'description': description,
      'weight': weight,
      'pickup_address': pickupAddress,
      'delivery_address': deliveryAddress,
    });

    if (response.statusCode != 201) {
      throw Exception('Erreur lors de la création de la demande');
    }
  }
}
