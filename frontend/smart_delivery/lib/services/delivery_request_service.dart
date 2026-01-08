import 'dart:convert';

import 'package:smart_delivery/core/constants/api_urls.dart';
import 'package:smart_delivery/models/delivery_request_model.dart';

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

  Future<List<DeliveryRequestModel>> getMyRequests() async {
    final response = await _apiClient.get(ApiUrls.deliveryRequests);

    if (response.statusCode == 200) {
      final List data = jsonDecode(response.body);
      return data.map((e) => DeliveryRequestModel.fromJson(e)).toList();
    }
    throw Exception('Erreur chargement requests: ${response.body}');
  }
}
