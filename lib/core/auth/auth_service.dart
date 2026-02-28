import 'dart:convert';
import 'package:http/http.dart' as http;
import '../constants.dart';
import 'secure_storage.dart';

class AuthService {
  // Имитация API авторизации (в реальности будет запрос к серверу)
  static Future<Map<String, dynamic>> login(String login, String password) async {
    await Future.delayed(const Duration(seconds: 1));

    // Демо-проверка (в реальности здесь будет запрос к API)
    if (login == AppConstants.demoLogin && password == AppConstants.demoPassword) {
      // Генерируем mock токен
      final token = 'mock_token_${DateTime.now().millisecondsSinceEpoch}';

      // Сохраняем данные
      await SecureStorage.saveLoginData(login, password);
      await SecureStorage.saveAuthToken(token);

      return {
        'success': true,
        'token': token,
        'user': {
          'id': 'ST001',
          'name': 'Иванов Иван Иванович',
          'group': 'ИТ-21',
        },
      };
    } else {
      return {
        'success': false,
        'error': 'Неверный логин или пароль',
      };
    }
  }

  // Проверка валидности токена
  static Future<bool> validateToken(String token) async {
    // В реальности здесь будет запрос к серверу для проверки токена
    await Future.delayed(const Duration(milliseconds: 500));
    return token.isNotEmpty;
  }

  // Выход из системы
  static Future<void> logout() async {
    await SecureStorage.clearAuthData();
  }

  // Проверка авторизации
  static Future<bool> isAuthenticated() async {
    final token = await SecureStorage.getAuthToken();
    if (token == null) return false;

    return await validateToken(token);
  }

  // Получение сохраненных учетных данных
  static Future<Map<String, String>?> getSavedCredentials() async {
    final login = await SecureStorage.getLogin();
    final password = await SecureStorage.getPassword();

    if (login != null && password != null) {
      return {'login': login, 'password': password};
    }

    return null;
  }

  // Автоматический вход по сохраненным данным
  static Future<bool> autoLogin() async {
    final credentials = await getSavedCredentials();
    if (credentials == null) return false;

    final result = await login(credentials['login']!, credentials['password']!);
    return result['success'] == true;
  }
}