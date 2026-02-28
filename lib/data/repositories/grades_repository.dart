import 'dart:convert';
import 'package:flutter/services.dart';
import '../models/grade.dart';

class GradesRepository {
  Future<List<Grade>> getGrades() async {
    // В реальном приложении здесь будет запрос к API
    await Future.delayed(Duration(milliseconds: 500));

    // Загрузка из локального JSON
    final jsonString = await rootBundle.loadString('assets/data/grades.json');
    final jsonList = json.decode(jsonString) as List;

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