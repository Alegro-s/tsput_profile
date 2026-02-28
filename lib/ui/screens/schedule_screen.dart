import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../../core/providers/schedule_provider.dart';
import '../../data/models/schedule.dart';

class ScheduleScreen extends StatefulWidget {
  @override
  _ScheduleScreenState createState() => _ScheduleScreenState();
}

class _ScheduleScreenState extends State<ScheduleScreen> {
  DateTime _selectedDate = DateTime.now();
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final scheduleProvider = context.read<ScheduleProvider>();
      scheduleProvider.loadSchedule();
    });
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Расписание'),
        actions: [
          IconButton(
            icon: Icon(Icons.filter_list),
            onPressed: () {
              // TODO: Реализовать фильтрацию
            },
          ),
          IconButton(
            icon: Icon(Icons.refresh),
            onPressed: () {
              context.read<ScheduleProvider>().loadSchedule();
            },
          ),
        ],
      ),
      body: SafeArea(
        bottom: false, // Отключаем SafeArea снизу для навигейшн бара
        child: Consumer<ScheduleProvider>(
          builder: (context, provider, child) {
            if (provider.isLoading) {
              return Center(child: CircularProgressIndicator());
            }

            return Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Верхняя панель с выбором даты
                _buildDateSelector(),

                // Заголовок дня
                _buildDayHeader(provider),

                // Основное содержимое календаря
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.only(bottom: 8.0), // Отступ снизу
                    child: _buildCalendarView(provider),
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }

  Widget _buildDateSelector() {
    return Container(
      color: Colors.white,
      padding: EdgeInsets.symmetric(vertical: 12, horizontal: 16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          IconButton(
            icon: Icon(Icons.chevron_left, color: Colors.black),
            onPressed: () {
              setState(() {
                _selectedDate = _selectedDate.subtract(Duration(days: 1));
              });
            },
          ),

          GestureDetector(
            onTap: () => _showDatePicker(context),
            child: Container(
              padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              decoration: BoxDecoration(
                color: Colors.black,
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text(
                DateFormat('d MMMM, EEEE', 'ru_RU').format(_selectedDate),
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ),

          IconButton(
            icon: Icon(Icons.chevron_right, color: Colors.black),
            onPressed: () {
              setState(() {
                _selectedDate = _selectedDate.add(Duration(days: 1));
              });
            },
          ),
        ],
      ),
    );
  }

  Widget _buildDayHeader(ScheduleProvider provider) {
    final scheduleForDay = _getScheduleForDate(provider.schedule, _selectedDate);

    return Container(
      color: Colors.grey[50],
      padding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            'Расписание на день:',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
            ),
          ),
          Text(
            '${scheduleForDay.length} занятий',
            style: TextStyle(
              color: Colors.grey[600],
              fontSize: 14,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCalendarView(ScheduleProvider provider) {
    final scheduleForDay = _getScheduleForDate(provider.schedule, _selectedDate);

    if (scheduleForDay.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.event_busy,
                size: 64,
                color: Colors.grey[300],
              ),
              SizedBox(height: 16),
              Text(
                'Нет занятий на выбранный день',
                style: TextStyle(
                  color: Colors.grey[500],
                  fontSize: 16,
                ),
              ),
              SizedBox(height: 8),
              TextButton(
                onPressed: () {
                  setState(() {
                    _selectedDate = DateTime.now();
                  });
                },
                child: Text('Вернуться к сегодняшнему дню'),
              ),
            ],
          ),
        ),
      );
    }

    // Сортируем занятия по времени
    scheduleForDay.sort((a, b) => a.startTime.compareTo(b.startTime));

    return ListView.builder(
      controller: _scrollController,
      padding: EdgeInsets.symmetric(horizontal: 16),
      physics: BouncingScrollPhysics(),
      itemCount: scheduleForDay.length,
      itemBuilder: (context, index) {
        final item = scheduleForDay[index];

        return Container(
          margin: EdgeInsets.only(bottom: 12),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Время
              Container(
                width: 70,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      DateFormat('HH:mm').format(item.startTime),
                      style: TextStyle(
                        fontWeight: FontWeight.w600,
                        fontSize: 14,
                      ),
                    ),
                    SizedBox(height: 2),
                    Text(
                      DateFormat('HH:mm').format(item.endTime),
                      style: TextStyle(
                        color: Colors.grey[500],
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ),

              // Вертикальная линия времени
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 12),
                child: Container(
                  width: 2,
                  height: 80, // Уменьшил высоту
                  color: _getTypeColor(item.type),
                ),
              ),

              // Карточка занятия
              Expanded(
                child: Container(
                  constraints: BoxConstraints(
                    minHeight: 80, // Минимальная высота карточки
                  ),
                  decoration: BoxDecoration(
                    color: Colors.black,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  padding: EdgeInsets.all(12), // Уменьшил padding
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(
                            child: Text(
                              item.subject,
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 14, // Уменьшил шрифт
                                fontWeight: FontWeight.w600,
                              ),
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          SizedBox(width: 8),
                          Container(
                            padding: EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 4,
                            ),
                            decoration: BoxDecoration(
                              color: _getTypeColor(item.type),
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: Text(
                              _getTypeShortName(item.type),
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 10,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        ],
                      ),

                      SizedBox(height: 6),

                      Row(
                        children: [
                          Icon(
                            Icons.person_outline,
                            color: Colors.grey[400],
                            size: 12,
                          ),
                          SizedBox(width: 4),
                          Expanded(
                            child: Text(
                              item.teacher,
                              style: TextStyle(
                                color: Colors.grey[400],
                                fontSize: 11,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),

                      SizedBox(height: 2),

                      Row(
                        children: [
                          Icon(
                            Icons.location_on_outlined,
                            color: Colors.grey[400],
                            size: 12,
                          ),
                          SizedBox(width: 4),
                          Text(
                            item.classroom,
                            style: TextStyle(
                              color: Colors.grey[400],
                              fontSize: 11,
                            ),
                          ),
                        ],
                      ),

                      if (item.additionalInfo != null) ...[
                        SizedBox(height: 6),
                        Container(
                          padding: EdgeInsets.all(6),
                          decoration: BoxDecoration(
                            color: Colors.grey[900],
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: Row(
                            children: [
                              Icon(
                                Icons.info_outline,
                                color: Colors.grey[400],
                                size: 12,
                              ),
                              SizedBox(width: 6),
                              Expanded(
                                child: Text(
                                  item.additionalInfo!,
                                  style: TextStyle(
                                    color: Colors.grey[400],
                                    fontSize: 11,
                                  ),
                                  maxLines: 2,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  List<Schedule> _getScheduleForDate(List<Schedule> allSchedule, DateTime date) {
    return allSchedule.where((item) {
      return item.startTime.year == date.year &&
          item.startTime.month == date.month &&
          item.startTime.day == date.day;
    }).toList();
  }

  Color _getTypeColor(String type) {
    switch (type.toLowerCase()) {
      case 'лекция':
        return Colors.blue;
      case 'практика':
        return Colors.green;
      case 'лабораторная':
        return Colors.orange;
      default:
        return Colors.grey;
    }
  }

  String _getTypeShortName(String type) {
    switch (type.toLowerCase()) {
      case 'лекция':
        return 'ЛЕК';
      case 'практика':
        return 'ПРАК';
      case 'лабораторная':
        return 'ЛАБ';
      default:
        return type.toUpperCase();
    }
  }

  Future<void> _showDatePicker(BuildContext context) async {
    final pickedDate = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime(2023),
      lastDate: DateTime(2027),
      locale: Locale('ru', 'RU'),
    );

    if (pickedDate != null) {
      setState(() {
        _selectedDate = pickedDate;
      });
    }
  }
}