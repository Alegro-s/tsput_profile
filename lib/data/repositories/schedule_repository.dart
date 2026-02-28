import 'dart:convert';
import 'package:flutter/services.dart';
import '../models/schedule.dart';

class ScheduleRepository {
  Future<List<Schedule>> getSchedule() async {
    // В реальном приложении здесь будет запрос к API
    await Future.delayed(Duration(milliseconds: 500));

    // Загрузка из локального JSON
    final jsonString = await rootBundle.loadString('assets/data/schedule.json');
    final jsonList = json.decode(jsonString) as List;

    return jsonList.map((json) => Schedule.fromJson(json)).toList();
  }

  Future<List<Schedule>> getScheduleForDate(DateTime date) async {
    final allSchedule = await getSchedule();
    return allSchedule.where((item) {
      return item.startTime.year == date.year &&
          item.startTime.month == date.month &&
          item.startTime.day == date.day;
    }).toList();
  }
}