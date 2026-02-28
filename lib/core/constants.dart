import 'package:flutter/material.dart';

class AppConstants {
  static const String appName = 'TSPUT Student Account';
  static const String demoLogin = 'student@university.ru';
  static const String demoPassword = 'password123';

  // Keys for secure storage
  static const String authTokenKey = 'auth_token';
  static const String userLoginKey = 'user_login';
  static const String userPasswordKey = 'user_password';
  static const String biometricEnabledKey = 'biometric_enabled';

  // API endpoints (для будущей интеграции)
  static const String baseUrl = 'https://api.university.ru';
  static const String loginEndpoint = '/api/auth/login';
  static const String studentEndpoint = '/api/student';
  static const String scheduleEndpoint = '/api/schedule';
  static const String eventsEndpoint = '/api/events';
  static const String gradesEndpoint = '/api/grades';
  static const String examsEndpoint = '/api/exams';

  // Design constants
  static const double cardRadius = 12.0;
  static const double buttonHeight = 48.0;
  static const Color backgroundColor = Colors.white;
  static const Color primaryColor = Colors.black;
  static const Color secondaryColor = Color(0xFF6B7280);
}