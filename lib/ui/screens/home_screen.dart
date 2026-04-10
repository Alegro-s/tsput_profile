import 'package:flutter/material.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';
import 'package:provider/provider.dart';

import '../../core/constants.dart';
import '../../core/providers/exams_provider.dart';
import '../../core/providers/grades_provider.dart';
import '../../core/providers/schedule_provider.dart';
import '../../core/providers/student_provider.dart';
import '../widgets/app_settings_sheet.dart';
import '../widgets/profile_card.dart';
import '../widgets/schedule_card.dart';
import '../widgets/stats_switcher.dart';

class HomeScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppConstants.surfaceWhite,
      appBar: AppBar(
        title: const Text('Главная'),
        actions: [
          IconButton(
            icon: Icon(PhosphorIconsRegular.bell, color: AppConstants.blockBlack),
            tooltip: 'Уведомления',
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Центр уведомлений появится после подключения push.'),
                ),
              );
            },
          ),
        ],
      ),
      body: RefreshIndicator(
        color: AppConstants.terracotta,
        onRefresh: () async {
          await Future.wait([
            context.read<StudentProvider>().loadStudentData(),
            context.read<ScheduleProvider>().loadSchedule(),
            context.read<GradesProvider>().loadGrades(),
            context.read<ExamsProvider>().loadExams(),
          ]);
        },
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.fromLTRB(20, 8, 20, 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              ProfileCard(
                onSettingsPressed: () => showAppSettingsSheet(context),
                onRefreshPressed: () async {
                  await Future.wait([
                    context.read<StudentProvider>().loadStudentData(),
                    context.read<ScheduleProvider>().loadSchedule(),
                    context.read<GradesProvider>().loadGrades(),
                    context.read<ExamsProvider>().loadExams(),
                  ]);
                },
              ),
              const SizedBox(height: 28),
              StatsSwitcher(),
              const SizedBox(height: 28),
              Text(
                'Расписание на сегодня',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w800,
                  color: Colors.grey[900],
                ),
              ),
              const SizedBox(height: 14),
              const ScheduleList(),
            ],
          ),
        ),
      ),
    );
  }
}
