import 'dart:convert';
import 'package:http/http.dart' as http;
import '../../core/constants.dart';

class ApiService {
  ApiService({http.Client? client}) : _client = client ?? http.Client();

  final http.Client _client;

  static const Duration _timeout = Duration(seconds: 12);

  static bool _isOfflineToken(String token) => token.startsWith('offline_');

  String get _base => AppConstants.integrationBaseUrl.replaceAll(RegExp(r'/$'), '');

  Future<Map<String, dynamic>> login({
    required String login,
    required String password,
  }) async {
    final url = '$_base${AppConstants.loginEndpoint}';
    try {
      final response = await _client
          .post(
            Uri.parse(url),
            headers: const {'Content-Type': 'application/json'},
            body: jsonEncode({'login': login, 'password': password}),
          )
          .timeout(_timeout);
      if (response.statusCode >= 200 && response.statusCode < 300) {
        return jsonDecode(response.body) as Map<String, dynamic>;
      }
      try {
        final decoded = jsonDecode(response.body);
        if (decoded is Map<String, dynamic>) {
          return decoded;
        }
      } catch (_) {}
      return {'success': false, 'error': 'Ошибка входа (${response.statusCode})'};
    } catch (_) {
      return {
        'success': false,
        '_offline': true,
        'error': 'Нет подключения к серверу',
      };
    }
  }

  Future<Map<String, dynamic>> fetchStudentData(String token) async {
    if (_isOfflineToken(token)) {
      return Map<String, dynamic>.from(_mockStudent);
    }
    return _getJson(
      '$_base${AppConstants.studentEndpoint}',
      token: token,
      fallback: _mockStudent,
    );
  }

  Future<List<dynamic>> fetchSchedule(String token) async {
    if (_isOfflineToken(token)) {
      return List<dynamic>.from(_mockSchedule);
    }
    return _getList(
      '$_base${AppConstants.scheduleEndpoint}',
      token: token,
      fallback: _mockSchedule,
    );
  }

  Future<List<dynamic>> fetchGrades(String token) async {
    if (_isOfflineToken(token)) {
      return List<dynamic>.from(_mockGrades);
    }
    return _getList(
      '$_base${AppConstants.gradesEndpoint}',
      token: token,
      fallback: _mockGrades,
    );
  }

  Future<List<dynamic>> fetchExams(String token) async {
    if (_isOfflineToken(token)) {
      return List<dynamic>.from(_mockExams);
    }
    return _getList(
      '$_base${AppConstants.examsEndpoint}',
      token: token,
      fallback: _mockExams,
    );
  }

  Future<List<dynamic>> fetchPortfolio(String token) async {
    if (_isOfflineToken(token)) {
      return List<dynamic>.from(_mockPortfolio);
    }
    return _getList(
      '$_base${AppConstants.portfolioEndpoint}',
      token: token,
      fallback: _mockPortfolio,
    );
  }

  Future<void> syncWith1C() async {
    final url = '$_base${AppConstants.syncEndpoint}';
    try {
      await _client
          .post(
            Uri.parse(url),
            headers: const {'Content-Type': 'application/json'},
            body: jsonEncode({}),
          )
          .timeout(_timeout);
    } catch (_) {}
  }

  Future<Map<String, dynamic>> _getJson(
    String url, {
    required String token,
    required Map<String, dynamic> fallback,
  }) async {
    try {
      final response = await _client
          .get(
            Uri.parse(url),
            headers: {'Authorization': 'Bearer $token'},
          )
          .timeout(_timeout);
      if (response.statusCode >= 200 && response.statusCode < 300) {
        return jsonDecode(response.body) as Map<String, dynamic>;
      }
    } catch (_) {}
    return Map<String, dynamic>.from(fallback);
  }

  Future<List<dynamic>> _getList(
    String url, {
    required String token,
    required List<dynamic> fallback,
  }) async {
    try {
      final response = await _client
          .get(
            Uri.parse(url),
            headers: {'Authorization': 'Bearer $token'},
          )
          .timeout(_timeout);
      if (response.statusCode >= 200 && response.statusCode < 300) {
        return jsonDecode(response.body) as List<dynamic>;
      }
    } catch (_) {}
    return List<dynamic>.from(fallback);
  }

  static const Map<String, dynamic> _mockStudent = {
    'id': 'ST001',
    'fullName': 'Виноградов Игорь Денисович',
    'group': '1521621',
    'faculty': 'Институт передовых информационных технологий',
    'specialty': 'Математическое обеспечение и администрирование информационных систем',
    'course': 4,
    'admissionDate': '2022-09-01T00:00:00.000Z',
    'graduationDate': '2026-06-30T00:00:00.000Z',
    'email': 'lorm2053@gmail.com',
    'phone': '+7 (900) 000-00-00',
    'address': 'Tula',
    'additionalInfo': {
      'educationForm': 'Очная',
      'city': 'Tula',
      'timezone': 'Etc/GMT-3',
      'birthDate': '2004-10-21',
      'studentStatus': 'Является студентом',
      'trainingLevel': 'Бакалавриат',
      'profile': 'Информационные системы и базы данных',
      'recordBook': '22031-15',
      'scholarship': 0,
      'dormitory': 'Не указано',
      'averageGrade': 4.7,
      'examsCount': 8,
      'partnerMapAccess': false,
    },
  };

  static final List<dynamic> _mockSchedule = [
    {
      'id': 'S1',
      'subject': 'Математический анализ',
      'teacher': 'Петров А.А.',
      'classroom': '312',
      'startTime': DateTime.now().add(const Duration(hours: 1)).toIso8601String(),
      'endTime': DateTime.now().add(const Duration(hours: 2, minutes: 30)).toIso8601String(),
      'type': 'lecture',
    }
  ];

  static const List<dynamic> _mockGrades = [
    {
      'id': 'G1',
      'subject': 'Базы данных',
      'teacher': 'Сидоров И.И.',
      'value': 5,
      'type': 'зачет',
      'date': '2026-03-15T00:00:00.000Z',
    }
  ];

  static final List<dynamic> _mockExams = [
    {
      'id': 'E1',
      'subject': 'Компьютерные сети',
      'date': '20.04.2026',
      'time': '10:00',
      'type': 'exam',
      'teacher': 'Иванова Н.В.',
      'classroom': 'ауд. 102',
      'isCompleted': false,
    }
  ];

  static final List<dynamic> _mockPortfolio = [
    {
      'id': 'P1',
      'title': 'Методы оптимизации 2025 - 2026',
      'category': 'Учебная дисциплина',
      'status': 'Подтверждено',
      'date': DateTime.now().subtract(const Duration(days: 120)).toIso8601String(),
      'source': '1C/Учебный план',
    },
    {
      'id': 'P2',
      'title': 'Большие данные и распределенные системы 2025 - 2026',
      'category': 'Учебная дисциплина',
      'status': 'Подтверждено',
      'date': DateTime.now().subtract(const Duration(days: 110)).toIso8601String(),
      'source': '1C/Учебный план',
    },
    {
      'id': 'P3',
      'title': 'Производственная преддипломная практика 2025 - 2026',
      'category': 'Практика',
      'status': 'В процессе',
      'date': DateTime.now().subtract(const Duration(days: 90)).toIso8601String(),
      'source': '1C/Практика',
    },
    {
      'id': 'P4',
      'title': 'Экономико-математические методы и модели 2025 - 2026',
      'category': 'Учебная дисциплина',
      'status': 'Подтверждено',
      'date': DateTime.now().subtract(const Duration(days: 80)).toIso8601String(),
      'source': '1C/Учебный план',
    },
    {
      'id': 'P5',
      'title': 'Подготовка к процедуре защиты ВКР 2025 - 2026',
      'category': 'ВКР',
      'status': 'В процессе',
      'date': DateTime.now().subtract(const Duration(days: 60)).toIso8601String(),
      'source': '1C/ВКР',
    },
    {
      'id': 'P6',
      'title': 'Компьютерное моделирование 2025 - 2026',
      'category': 'Учебная дисциплина',
      'status': 'Подтверждено',
      'date': DateTime.now().subtract(const Duration(days: 50)).toIso8601String(),
      'source': '1C/Учебный план',
    },
    {
      'id': 'P7',
      'title': 'Рекурсивно-логическое программирование 2025 - 2026',
      'category': 'Учебная дисциплина',
      'status': 'Подтверждено',
      'date': DateTime.now().subtract(const Duration(days: 40)).toIso8601String(),
      'source': '1C/Учебный план',
    },
  ];
}