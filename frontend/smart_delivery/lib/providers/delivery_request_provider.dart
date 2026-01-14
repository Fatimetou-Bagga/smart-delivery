import 'package:flutter/material.dart';
import '../models/delivery_request_model.dart';
import '../services/delivery_request_service.dart';

class DeliveryRequestProvider extends ChangeNotifier {
  final DeliveryRequestService _service = DeliveryRequestService();

  bool _loading = false;
  String? error;
  List<DeliveryRequestModel> requests = [];
  bool get loading => _loading;
  Future<void> fetchMyRequests() async {
    _loading = true;
    error = null;
    notifyListeners();

    try {
      requests = await _service.getMyRequests();
    } catch (e) {
      error = e.toString();
    } finally {
      _loading = false;
      notifyListeners();
    }
  }

  Future<void> createRequest({
    required String productType,
    required String description,
    required double weight,
    required String pickupAddress,
    required String deliveryAddress,
  }) async {
    _loading = true;
    error = null;
    notifyListeners();

    try {
      await _service.createDeliveryRequest(
        productType: productType,
        description: description,
        weight: weight,
        pickupAddress: pickupAddress,
        deliveryAddress: deliveryAddress,
      );
      await fetchMyRequests();
    } catch (e) {
      error = e.toString();
    } finally {
      _loading = false;
      notifyListeners();
    }
  }

  Future<void> cancel(int id) async {
    await _service.cancelRequest(id);
    await fetchMyRequests(); // refresh
  }
}
