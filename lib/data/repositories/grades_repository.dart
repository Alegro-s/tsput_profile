import '../../core/auth/secure_storage.dart';
import '../models/grade.dart';
import '../services/api_service.dart';

class GradesRepository {
  final ApiService _apiService = ApiService();

  Future<List<Grade>> getGrades() async {
    final token = await SecureStorage.getAuthToken() ?? '';
    final jsonList = await _apiService.fetchGrades(token);
    return jsonList.map((json) => Grade.fromJson(json)).toList();
  }

  Future<double> getAverageGrade() async {
    final grades = await getGrades();

    // Фильтруем только оценки с числовым значением
    final validGrades = grades.where((g) => g.value > 0 && g.value <= 5);

    if (validGrades.isEmpty) return 0.0;

    final sum = validGrades.map((g) => g.value).reduce((a, b) => a + b);
    return sum / validGrades.length;
  }
}