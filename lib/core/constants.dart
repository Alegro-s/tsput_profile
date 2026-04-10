import 'package:flutter/material.dart';

class AppConstants {
  static const String appName = 'ТГПУ профиль';
  static const String demoLogin = 'student@university.ru';
  static const String demoPassword = 'password123';

  /// Регистрация на портале вуза (витрина / карта партнёров).
  static const String portalRegisterUrl = 'https://tsput.ru';

  /// Локальный флаг: пользователь подтвердил регистрацию на портале (до API).
  static const String prefPartnerMapUnlocked = 'partner_map_portal_unlocked';

  /// Один базовый URL для интеграционного backend (Docker / прод).
  /// Сборка: `--dart-define=INTEGRATION_BASE_URL=https://api.example.com`
  static const String integrationBaseUrl = String.fromEnvironment(
    'INTEGRATION_BASE_URL',
    defaultValue: 'http://127.0.0.1:8080',
  );

  /// Демо-вход без сети (тот же логин/пароль), если сервер недоступен.
  static const bool offlineDemoEnabled = true;

  // Keys for secure storage
  static const String authTokenKey = 'auth_token';
  static const String userLoginKey = 'user_login';
  static const String userPasswordKey = 'user_password';
  static const String biometricEnabledKey = 'biometric_enabled';

  // API endpoints
  static String get oneCBaseUrl => integrationBaseUrl;
  static String get moodleBaseUrl => integrationBaseUrl;
  static String get portalBaseUrl => integrationBaseUrl;
  static const String loginEndpoint = '/api/auth/login';
  static const String syncEndpoint = '/api/sync';
  static const String studentEndpoint = '/api/student';
  static const String scheduleEndpoint = '/api/schedule';
  static const String gradesEndpoint = '/api/grades';
  static const String examsEndpoint = '/api/exams';
  static const String portfolioEndpoint = '/api/portfolio';
  static const String moodleLabsEndpoint = '/webservice/rest/server.php';

  // Design — ориентир T-Bank: бирюза, светлый фон, жёлтая CTA
  static const double cardRadius = 20.0;
  static const double buttonHeight = 52.0;
  static const Color backgroundColor = Color(0xFFF5F7FA);
  static const Color primaryColor = Color(0xFF2AAB9F);
  static const Color primaryDark = Color(0xFF1F8A82);
  static const Color secondaryColor = Color(0xFF5F6B7A);
  static const Color accentYellow = Color(0xFFFFDD2D);
  static const Color accentOrange = Color(0xFFE84E26);
  static const Color cardWhite = Colors.white;

  @Deprecated('Use accentYellow for акцентные кнопки в стиле T-Bank')
  static const Color accentColor = accentYellow;
}
