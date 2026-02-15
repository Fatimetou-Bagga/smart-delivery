class DeliveryRequest {
  final int id;
  final String productType;
  final String description;
  final double weight;
  final String pickupAddress;
  final String deliveryAddress;
  final String status;
  final DateTime createdAt;
  final DateTime updatedAt;

  final double? distanceKm;
  final double? priceMru;

  DeliveryRequest({
    required this.id,
    required this.productType,
    required this.description,
    required this.weight,
    required this.pickupAddress,
    required this.deliveryAddress,
    required this.status,
    required this.createdAt,
    required this.updatedAt,
    this.distanceKm,
    this.priceMru,
  });

  factory DeliveryRequest.fromJson(Map<String, dynamic> json) {
    return DeliveryRequest(
      id: (json['id'] as num).toInt(),
      productType: (json['product_type'] ?? '') as String,
      description: (json['description'] ?? '') as String,
      weight: (json['weight'] as num?)?.toDouble() ?? 0,
      pickupAddress: (json['pickup_address'] ?? '') as String,
      deliveryAddress: (json['delivery_address'] ?? '') as String,
      status: (json['status'] ?? '') as String,
      createdAt: DateTime.tryParse((json['created_at'] ?? '').toString()) ?? DateTime.now(),
      updatedAt: DateTime.tryParse((json['updated_at'] ?? '').toString()) ?? DateTime.now(),
      distanceKm: (json['distance_km'] as num?)?.toDouble(),
      priceMru: (json['price_mru'] as num?)?.toDouble(),
    );
  }

  bool get isActive => status == 'PENDING' || status == 'ACCEPTED' || status == 'IN_PROGRESS';
  bool get isFinished => status == 'DELIVERED' || status == 'CANCELLED';
}
