import 'package:flutter/material.dart';
import '../services/delivery_service.dart';

class DeliveryProvider extends ChangeNotifier {
  final DeliveryService _service = DeliveryService();

  bool _isLoading = false;
  List<dynamic> _availableRequests = [];
  List<dynamic> _myDeliveries = [];

  bool get isLoading => _isLoading;
  List<dynamic> get availableRequests => _availableRequests;
  List<dynamic> get myDeliveries => _myDeliveries;

  /// Charger demandes disponibles
  Future<void> loadAvailableRequests() async {
    _isLoading = true;
    notifyListeners();

    try {
      _availableRequests = await _service.getAvailableRequests();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Accepter une demande
  Future<void> acceptRequest(int requestId) async {
    await _service.acceptRequest(requestId);
    await loadAvailableRequests(); // refresh
  }

  /// Charger mes livraisons
  Future<void> loadMyDeliveries() async {
    _isLoading = true;
    notifyListeners();

    try {
      _myDeliveries = await _service.getMyDeliveries();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}
