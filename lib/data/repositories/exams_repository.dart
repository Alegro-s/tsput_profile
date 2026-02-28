import 'dart:convert';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import '../models/exam.dart';

class ExamsRepository {
  Future<List<Exam>> getExams() async {
    // В реальном приложении здесь будет запрос к API
    await Future.delayed(Duration(milliseconds: 500));

    // Загрузка из локального JSON
    final jsonString = await rootBundle.loadString('assets/data/exams.json');
    final jsonList = json.decode(jsonString) as List;

    return jsonList.map((json) => Exam.fromJson(json)).toList();
  }

  Future<List<Exam>> getUpcomingExams() async {
    final allExams = await getExams();
    final now = DateTime.now();

    return allExams.where((exam) {
      if (exam.isCompleted) return false;

      try {
        // Парсим дату из формата "dd.MM.yyyy"
        final examDate = DateFormat('dd.MM.yyyy').parse(exam.date);
        return examDate.isAfter(now) || examDate.isAtSameMomentAs(now);
      } catch (e) {
        // Если не удалось распарсить, вернем false
        return false;
      }
    }).toList();
  }

  Future<List<Exam>> getCompletedExams() async {
    final allExams = await getExams();
    return allExams.where((exam) => exam.isCompleted).toList();
  }
}