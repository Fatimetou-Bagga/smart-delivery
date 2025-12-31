import 'delivery_request_model.dart';
import 'user_model.dart';

class DeliveryModel {
  final int id;
  final DeliveryRequestModel deliveryRequest;
  final UserModel courier;
  final String status;
  final DateTime assignedAt;
  final DateTime? deliveredAt;

  DeliveryModel({
    required this.id,
    required this.deliveryRequest,
    required this.courier,
    required this.status,
    required this.assignedAt,
    this.deliveredAt,
  });

  factory DeliveryModel.fromJson(Map<String, dynamic> json) {
    return DeliveryModel(
      id: json['id'],
      deliveryRequest: DeliveryRequestModel.fromJson(json['delivery_request']),
      courier: UserModel.fromJson(json['courier']),
      status: json['status'],
      assignedAt: DateTime.parse(json['assigned_at']),
      deliveredAt: json['delivered_at'] != null
          ? DateTime.parse(json['delivered_at'])
          : null,
    );
  }
}
