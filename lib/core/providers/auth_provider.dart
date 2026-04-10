import 'package:flutter/material.dart';
import '../auth/auth_service.dart';
import '../auth/secure_storage.dart';

class AuthProvider extends ChangeNotifier {
  bool _isAuthenticated = false;
  bool _isLoading = false;
  String? _error;
  bool _biometricAvailable = false;
  bool _biometricEnabled = false;
  String? _userName;

  bool get isAuthenticated => _isAuthenticated;
  bool get isLoading => _isLoading;
  String? get error => _error;
  bool get biometricAvailable => _biometricAvailable;
  bool get biometricEnabled => _biometricEnabled;
  String? get userName => _userName;

  AuthProvider() {
    _init();
  }

  Future<bool> login(String login, String password, {bool rememberMe = true}) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final result = await AuthService.login(login, password);

      if (result['success'] == true) {
        _isAuthenticated = true;
        _userName = (result['user'] as Map<String, dynamic>?)?['name'] as String?;

        if (rememberMe) {
          await SecureStorage.saveLoginData(login, password);
        }

        return true;
      } else {
        _error = result['error'] ?? 'Ошибка авторизации';
        return false;
      }
    } catch (e) {
      _error = 'Ошибка соединения: $e';
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> logout() async {
    _isLoading = true;
    notifyListeners();

    try {
      await AuthService.logout();
      _isAuthenticated = false;
      _userName = null;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> checkAuthStatus() async {
    _isLoading = true;
    notifyListeners();

    try {
      final hasCredentials = await SecureStorage.hasSavedCredentials();
      final isAuthenticated = await AuthService.isAuthenticated();

      if (hasCredentials && isAuthenticated) {
        _isAuthenticated = true;
        return true;
      }

      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  void clearError() {
    _error = null;
    notifyListeners();
  }
  void setAuthenticated(bool value, {String? userName}) {
    _isAuthenticated = value;
    if (userName != null) {
      _userName = userName;
    }
    notifyListeners();
  }

  Future<void> _init() async {
    await checkAuthStatus();
  }

}