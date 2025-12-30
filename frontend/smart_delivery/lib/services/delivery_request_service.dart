class DeliveryRequestService {
  final ApiClient api;

  DeliveryRequestService(this.api);

  Future<List<DeliveryRequest>> getMyRequests() async {
    final response = await api.get("/delivery-requests/");
    return response
        .map<DeliveryRequest>((e) => DeliveryRequest.fromJson(e))
        .toList();
  }

  Future<void> createRequest(Map data) async {
    await api.post("/delivery-requests/", data);
  }
}
