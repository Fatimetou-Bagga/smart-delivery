class DeliveryRequest {
  final int id;
  final String productType;
  final String pickupAddress;
  final String deliveryAddress;
  final String status;

  DeliveryRequest.fromJson(Map<String, dynamic> json)
    : id = json['id'],
      productType = json['product_type'],
      pickupAddress = json['pickup_address'],
      deliveryAddress = json['delivery_address'],
      status = json['status'];
}
