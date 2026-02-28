import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:flutter/services.dart' show rootBundle;
import '../../core/network.dart';

class ApiService {
  static Future<Map<String, dynamic>> fetchStudentData() async {
    await Future.delayed(const Duration(seconds: 1));

    final jsonString = await rootBundle.loadString('assets/data/student.json');
    return json.decode(jsonString);
  }

  static Future<List<dynamic>> fetchGrades() async {
    await Future.delayed(const Duration(milliseconds: 800));
    final jsonString = await rootBundle.loadString('assets/data/grades.json');
    return json.decode(jsonString);
  }

  static Future<List<dynamic>> fetchExams() async {
    await Future.delayed(const Duration(milliseconds: 800));
    final jsonString = await rootBundle.loadString('assets/data/exams.json');
    return json.decode(jsonString);
  }

  static Future<List<dynamic>> fetchSchedule() async {
    await Future.delayed(const Duration(milliseconds: 800));
    final jsonString = await rootBundle.loadString('assets/data/schedule.json');
    return json.decode(jsonString);
  }

  static Future<List<dynamic>> fetchEvents() async {
    await Future.delayed(const Duration(milliseconds: 800));
    final jsonString = await rootBundle.loadString('assets/data/events.json');
    return json.decode(jsonString);
  }

  static Future<List<dynamic>> fetchTeachers() async {
    await Future.delayed(const Duration(milliseconds: 800));
    final jsonString = await rootBundle.loadString('assets/data/teachers.json');
    return json.decode(jsonString);
  }

  static Future<void> syncWith1C() async {
    await Future.delayed(const Duration(seconds: 2));
    print('Синхронизация с 1С выполнена');
  }
}