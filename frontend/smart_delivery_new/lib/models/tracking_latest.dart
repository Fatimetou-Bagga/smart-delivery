class TrackingLatest {
  final int deliveryId;
  final String deliveryStatus;
  final double lat;
  final double lng;
  final DateTime updatedAt;

  TrackingLatest({
    required this.deliveryId,
    required this.deliveryStatus,
    required this.lat,
    required this.lng,
    required this.updatedAt,
  });

  factory TrackingLatest.fromJson(Map<String, dynamic> json) {
    return TrackingLatest(
      deliveryId: (json['delivery_id'] as num).toInt(),
      deliveryStatus: (json['delivery_status'] ?? '') as String,
      lat: (json['lat'] as num).toDouble(),
      lng: (json['lng'] as num).toDouble(),
      updatedAt: DateTime.tryParse((json['updated_at'] ?? '').toString()) ?? DateTime.now(),
    );
  }
}
