import 'delivery_request.dart';

class Delivery {
  final int id;
  final String status; // ASSIGNED / IN_PROGRESS / DELIVERED
  final DeliveryRequest deliveryRequest;

  Delivery({required this.id, required this.status, required this.deliveryRequest});

  factory Delivery.fromJson(Map<String, dynamic> json) {
    return Delivery(
      id: (json['id'] as num).toInt(),
      status: (json['status'] ?? '') as String,
      deliveryRequest: DeliveryRequest.fromJson(json['delivery_request'] as Map<String, dynamic>),
    );
  }
}
