class ApiUrls {
  // AUTH
  static const String login = '/auth/login/';
  static const String refresh = '/auth/refresh/';
  static const String register = '/auth/register/';

  // USERS
  static const String users = '/users/';

  // DELIVERY REQUESTS (client)
  static const String deliveryRequests = '/delivery-requests/';
  static const String availableRequests = '/delivery-requests/available/';

  // DELIVERIES (courier)
  static const String deliveries = '/deliveries/';
  static const String acceptDelivery = '/deliveries/accept/';
  static String updateDeliveryStatus(int id) => '/deliveries/$id/';
}
