import 'package:flutter/material.dart';
import '../widgets/profile_card.dart';
import '../widgets/schedule_card.dart';
import '../widgets/stats_switcher.dart';

class HomeScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Главная'),
        actions: [
          IconButton(
            icon: Icon(Icons.notifications_outlined),
            onPressed: () {},
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: () async {
          // Обновление данных при наличии интернета
          await Future.delayed(Duration(seconds: 1));
        },
        child: SingleChildScrollView(
          padding: EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Карточка профиля
              ProfileCard(),
              SizedBox(height: 20),

              // Блок с переключателем статистики
              StatsSwitcher(),
              SizedBox(height: 24),

              // Расписание на день
              Text(
                'Расписание на день:',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                  color: Colors.black,
                ),
              ),
              SizedBox(height: 12),

              // Список расписания
              ScheduleList(),
            ],
          ),
        ),
      ),
    );
  }
}