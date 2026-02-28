import 'dart:convert';
import 'package:flutter/services.dart';
import '../models/event.dart';

class EventsRepository {
  Future<List<Event>> getEvents() async {
    // В реальном приложении здесь будет запрос к API
    await Future.delayed(Duration(milliseconds: 500));

    // Загрузка из локального JSON
    final jsonString = await rootBundle.loadString('assets/data/events.json');
    final jsonList = json.decode(jsonString) as List;

    return jsonList.map((json) => Event.fromJson(json)).toList();
  }

  Future<List<Event>> getUpcomingEvents() async {
    final allEvents = await getEvents();
    final now = DateTime.now();
    return allEvents.where((event) => event.date.isAfter(now)).toList();
  }

  Future<List<Event>> getPastEvents() async {
    final allEvents = await getEvents();
    final now = DateTime.now();
    return allEvents.where((event) => event.date.isBefore(now)).toList();
  }

  Future<void> registerForEvent(String eventId) async {
    // В реальном приложении здесь будет запрос к API
    await Future.delayed(Duration(seconds: 1));
    print('Регистрация на мероприятие: $eventId');
  }
}