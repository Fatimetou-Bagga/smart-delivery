import 'package:flutter/foundation.dart';
import '../services/auth_service.dart';
import '../models/user_model.dart';

class AuthProvider extends ChangeNotifier {
  final AuthService _authService = AuthService();

  UserModel? _user;
  bool _isAuthenticated = false;
  bool _isLoading = false;

  bool get isAuthenticated => _isAuthenticated;
  bool get isLoading => _isLoading;
  String? get role => _user?.role;
  UserModel? get user => _user;

  Future<void> login({
    required String username,
    required String password,
  }) async {
    _isLoading = true;
    notifyListeners();

    try {
      final user = await _authService.login(
        username: username,
        password: password,
      );

      _user = user;
      _isAuthenticated = true;
      await restoreSession();
    } catch (e) {
      _isAuthenticated = false;
      rethrow;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> logout() async {
    await _authService.logout();
    _user = null;
    _isAuthenticated = false;
    notifyListeners();
  }

  Future<void> restoreSession() async {
    _isLoading = true;
    notifyListeners();

    try {
      final user = await _authService.getCurrentUser();
      _user = user;
      _isAuthenticated = true;
    } catch (e) {
      _isAuthenticated = false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> registerClient({
    required String username,
    required String email,
    required String password,
    required String password2,
    required String phoneNumber,
  }) async {
    _isLoading = true;
    notifyListeners();

    try {
      await _authService.registerClient(
        username: username,
        email: email,
        password: password,
        password2: password2,
        phoneNumber: phoneNumber,
      );
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}
