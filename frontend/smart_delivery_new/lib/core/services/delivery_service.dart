import '../../models/delivery_request.dart';
import '../../models/tracking_latest.dart';
import '../../models/delivery.dart';
import '../storage/app_prefs.dart';
import 'api_client.dart';

class DeliveryService {
  final ApiClient _api = ApiClient();

  Future<String> _token() async {
    final t = await AppPrefs.getAccessToken();
    if (t == null) throw Exception('Not logged in');
    return t;
  }

  Future<List<DeliveryRequest>> myRequests() async {
    final token = await _token();
    final data = await _api.getJson('/api/delivery-requests/', bearerToken: token);

    List<dynamic> list = [];
    if (data['results'] is List) {
      list = data['results'] as List<dynamic>;
    } else if (data['data'] is List) {
      list = data['data'] as List<dynamic>;
    }

    return list
        .map((e) => DeliveryRequest.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  Future<DeliveryRequest> getRequest(int id) async {
    final token = await _token();
    final data = await _api.getJson('/api/delivery-requests/$id/', bearerToken: token);
    return DeliveryRequest.fromJson(data);
  }

  Future<DeliveryRequest> createRequest({
    required String productType,
    required String description,
    required double weight,
    required String pickupAddress,
    required String deliveryAddress,
  }) async {
    final token = await _token();
    final res = await _api.postJson(
      '/api/delivery-requests/',
      {
        'product_type': productType,
        'description': description,
        'weight': weight,
        'pickup_address': pickupAddress,
        'delivery_address': deliveryAddress,
      },
      headers: {'Authorization': 'Bearer $token'},
    );
    return DeliveryRequest.fromJson(res);
  }

  Future<void> confirmReceived(int requestId) async {
    final token = await _token();
    await _api.postJson(
      '/api/delivery-requests/$requestId/confirm-received/',
      {},
      headers: {'Authorization': 'Bearer $token'},
    );
  }

  Future<TrackingLatest> trackingLatest(int requestId) async {
    final token = await _token();
    final res = await _api.getJson(
      '/api/delivery-requests/$requestId/tracking/latest/',
      bearerToken: token,
    );
    return TrackingLatest.fromJson(res);
  }

  // Courier
  Future<List<Delivery>> myDeliveries() async {
    final token = await _token();
    final data = await _api.getJson('/api/deliveries/', bearerToken: token);

    List<dynamic> list = [];
    if (data['results'] is List) {
      list = data['results'] as List<dynamic>;
    } else if (data['data'] is List) {
      list = data['data'] as List<dynamic>;
    }

    return list.map((e) => Delivery.fromJson(e as Map<String, dynamic>)).toList();
  }

  Future<void> updateDeliveryStatus(int deliveryId, String status) async {
    final token = await _token();
    await _api.patchJson(
      '/api/deliveries/$deliveryId/',
      {'status': status},
      headers: {'Authorization': 'Bearer $token'},
    );
  }

  Future<void> pushCourierLocation(double lat, double lng) async {
    final token = await _token();
    await _api.postJson(
      '/api/deliveries/location/',
      {'lat': lat, 'lng': lng},
      headers: {'Authorization': 'Bearer $token'},
    );
  }
}
