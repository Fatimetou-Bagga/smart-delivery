class DeliveryRequestModel {
  final int id;
  final String productType;
  final String description;
  final double weight;
  final String pickupAddress;
  final String deliveryAddress;
  final String status;
  final DateTime createdAt;

  DeliveryRequestModel({
    required this.id,
    required this.productType,
    required this.description,
    required this.weight,
    required this.pickupAddress,
    required this.deliveryAddress,
    required this.status,
    required this.createdAt,
  });

  factory DeliveryRequestModel.fromJson(Map<String, dynamic> json) {
    return DeliveryRequestModel(
      id: json['id'],
      productType: json['product_type'],
      description: json['description'] ?? '',
      weight: (json['weight'] as num).toDouble(),
      pickupAddress: json['pickup_address'],
      deliveryAddress: json['delivery_address'],
      status: json['status'],
      createdAt: DateTime.parse(json['created_at']),
    );
  }
}
