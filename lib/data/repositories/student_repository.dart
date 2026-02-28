import 'dart:convert';
import 'package:flutter/services.dart';
import '../models/student.dart';

class StudentRepository {
  Future<Student> getStudentData() async {
    await Future.delayed(Duration(milliseconds: 500));

    final jsonString = await rootBundle.loadString('assets/data/student.json');
    final jsonData = json.decode(jsonString);

    return Student.fromJson(jsonData);
  }

  Future<void> updateStudentInfo(Map<String, dynamic> updates) async {
    await Future.delayed(Duration(seconds: 1));
    print('Обновление данных студента: $updates');
  }
}