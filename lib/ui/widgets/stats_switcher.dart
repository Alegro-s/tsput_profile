import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/providers/events_provider.dart';
import '../../core/providers/exams_provider.dart';
import '../../core/providers/grades_provider.dart';
import '../../data/models/event.dart';
import '../../data/models/grade.dart';
import '../../data/models/exam.dart';

class StatsSwitcher extends StatefulWidget {
  @override
  _StatsSwitcherState createState() => _StatsSwitcherState();
}

class _StatsSwitcherState extends State<StatsSwitcher> {
  int _selectedTab = 0;
  final List<String> _tabs = ['Оценки', 'Сессия', 'Статистика'];
  Map<String, bool> _expandedSemesters = {};

  // Детальные окна
  void _showGradesDetails(BuildContext context, GradesProvider provider) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => _buildGradesDetails(provider),
    );
  }

  void _showSessionDetails(BuildContext context, ExamsProvider provider) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => _buildSessionDetails(provider),
    );
  }

  void _showStatsDetails(BuildContext context,
      GradesProvider gradesProvider, EventsProvider eventsProvider) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => _buildStatsDetails(gradesProvider, eventsProvider),
    );
  }

  // Группировка оценок по семестрам
  Map<String, List<Grade>> _groupGradesBySemester(List<Grade> grades) {
    Map<String, List<Grade>> grouped = {};

    for (var grade in grades) {
      String semesterKey;

      int year = grade.date.year;
      int month = grade.date.month;

      if (month >= 9 || month <= 1) {
        semesterKey = 'Осенний семестр ${year}-${year+1}';
      } else {
        semesterKey = 'Весенний семестр $year';
      }

      grouped.putIfAbsent(semesterKey, () => []).add(grade);
    }

    return grouped;
  }

  @override
  Widget build(BuildContext context) {
    final gradesProvider = context.watch<GradesProvider>();
    final examsProvider = context.watch<ExamsProvider>();
    final eventsProvider = context.watch<EventsProvider>();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Кнопки-вкладки
        Container(
          height: 40,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            itemCount: _tabs.length,
            itemBuilder: (context, index) {
              return GestureDetector(
                onTap: () {
                  setState(() {
                    _selectedTab = index;
                  });
                },
                child: Container(
                  constraints: BoxConstraints(minWidth: 80),
                  padding: EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                  margin: EdgeInsets.only(right: 12),
                  decoration: BoxDecoration(
                    color: _selectedTab == index ? Colors.black : Colors.grey[100],
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    _tabs[index],
                    style: TextStyle(
                      color: _selectedTab == index ? Colors.white : Colors.black,
                      fontWeight: FontWeight.w500,
                      fontSize: 14,
                    ),
                  ),
                ),
              );
            },
          ),
        ),
        SizedBox(height: 16),

        // Контент в зависимости от выбранной вкладки
        Container(
          height: 150,
          child: _buildContent(gradesProvider, examsProvider, eventsProvider),
        ),
      ],
    );
  }

  Widget _buildContent(
      GradesProvider gradesProvider,
      ExamsProvider examsProvider,
      EventsProvider eventsProvider,
      ) {
    switch (_selectedTab) {
      case 0: // Оценки
        return _buildGradesTab(gradesProvider);
      case 1: // Сессия
        return _buildSessionTab(examsProvider);
      case 2: // Статистика
        return _buildStatsTab(gradesProvider, eventsProvider);
      default:
        return Container();
    }
  }

  Widget _buildGradesTab(GradesProvider provider) {
    final grades = provider.grades;
    final averageGrade = provider.averageGrade;

    return Row(
      children: [
        Expanded(
          child: GestureDetector(
            onTap: () => _showGradesDetails(context, provider),
            child: _buildSquareCard(
              icon: Icons.trending_up,
              title: 'Средний балл',
              value: averageGrade.toStringAsFixed(2),
              subtitle: 'За все время',
              color: Colors.blue[100]!,
              textColor: Colors.blue[800]!,
            ),
          ),
        ),
        SizedBox(width: 12),
        Expanded(
          child: GestureDetector(
            onTap: () => _showGradesDetails(context, provider),
            child: _buildSquareCard(
              icon: Icons.subject,
              title: 'Всего предметов',
              value: grades.length.toString(),
              subtitle: 'Всего',
              color: Colors.green[100]!,
              textColor: Colors.green[800]!,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildSessionTab(ExamsProvider provider) {
    final upcomingExams = provider.upcomingExams;
    final completedExams = provider.completedExams;

    return Row(
      children: [
        Expanded(
          child: GestureDetector(
            onTap: () => _showSessionDetails(context, provider),
            child: _buildSquareCard(
              icon: Icons.calendar_today,
              title: 'Предстоящие',
              value: upcomingExams.length.toString(),
              subtitle: 'экзаменов',
              color: Colors.orange[100]!,
              textColor: Colors.orange[800]!,
            ),
          ),
        ),
        SizedBox(width: 12),
        Expanded(
          child: GestureDetector(
            onTap: () => _showSessionDetails(context, provider),
            child: _buildSquareCard(
              icon: Icons.check_circle,
              title: 'Сдано',
              value: completedExams.length.toString(),
              subtitle: 'экзаменов',
              color: Colors.green[100]!,
              textColor: Colors.green[800]!,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildStatsTab(GradesProvider gradesProvider, EventsProvider eventsProvider) {
    final grades = gradesProvider.grades;
    final pastEvents = eventsProvider.pastEvents;

    // Считаем лабораторные
    final labs = grades.where((g) => g.type.toLowerCase().contains('лабораторная')).toList();
    final passedLabs = labs.where((l) => l.value >= 3).length;
    final totalEventsPoints = pastEvents.fold(0, (sum, event) => sum + event.points);

    return Row(
      children: [
        Expanded(
          child: GestureDetector(
            onTap: () => _showStatsDetails(context, gradesProvider, eventsProvider),
            child: _buildSquareCard(
              icon: Icons.science,
              title: 'Лабораторные',
              value: '$passedLabs/${labs.length}',
              subtitle: 'сдано/всего',
              color: Colors.purple[100]!,
              textColor: Colors.purple[800]!,
            ),
          ),
        ),
        SizedBox(width: 12),
        Expanded(
          child: GestureDetector(
            onTap: () => _showStatsDetails(context, gradesProvider, eventsProvider),
            child: _buildSquareCard(
              icon: Icons.notifications_active,
              title: 'Уведомления',
              value: totalEventsPoints.toString(),
              subtitle: 'лабораторные',
              color: Colors.amber[100]!,
              textColor: Colors.amber[800]!,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildSquareCard({
    required IconData icon,
    required String title,
    required String value,
    required String subtitle,
    required Color color,
    required Color textColor,
  }) {
    return Container(
      constraints: BoxConstraints(
        minHeight: 150,
        maxHeight: 150,
      ),
      padding: EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey[200]!),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 8,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: color,
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(
              icon,
              color: textColor,
              size: 20,
            ),
          ),
          SizedBox(height: 12),
          Text(
            value,
            style: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.w700,
              color: Colors.black,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          SizedBox(height: 4),
          Text(
            title,
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w500,
              color: Colors.grey[700],
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            textAlign: TextAlign.center,
          ),
          Text(
            subtitle,
            style: TextStyle(
              fontSize: 11,
              color: Colors.grey[500],
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  // ========== ДЕТАЛЬНЫЕ ОКНА ==========

  Widget _buildGradesDetails(GradesProvider provider) {
    final grades = provider.grades;
    final groupedBySemester = _groupGradesBySemester(grades);

    // Инициализируем состояние для каждого семестра
    groupedBySemester.keys.forEach((semester) {
      _expandedSemesters.putIfAbsent(semester, () => false);
    });

    return DraggableScrollableSheet(
      initialChildSize: 0.85,
      minChildSize: 0.5,
      maxChildSize: 0.95,
      expand: false,
      builder: (context, scrollController) {
        return Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
          ),
          child: Column(
            children: [
              // Шапка
              Container(
                padding: EdgeInsets.all(20),
                decoration: BoxDecoration(
                  border: Border(bottom: BorderSide(color: Colors.grey[200]!)),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Оценки по семестрам',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    Container(
                      padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(
                        color: Colors.black,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        'Средний: ${provider.averageGrade.toStringAsFixed(2)}',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              // Контент
              Expanded(
                child: grades.isEmpty
                    ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.grade_outlined, size: 64, color: Colors.grey[300]),
                      SizedBox(height: 16),
                      Text(
                        'Нет данных об оценках',
                        style: TextStyle(color: Colors.grey[600]),
                      ),
                    ],
                  ),
                )
                    : ListView.builder(
                  controller: scrollController,
                  padding: EdgeInsets.all(16),
                  itemCount: groupedBySemester.length,
                  itemBuilder: (context, index) {
                    final semester = groupedBySemester.keys.toList()[index];
                    final semesterGrades = groupedBySemester[semester]!;
                    final semesterAverage = _calculateAverage(semesterGrades);

                    return _buildSemesterExpansionTile(
                      semester: semester,
                      grades: semesterGrades,
                      average: semesterAverage,
                    );
                  },
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildSemesterExpansionTile({
    required String semester,
    required List<Grade> grades,
    required double average,
  }) {
    return Container(
      margin: EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 6,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Theme(
        data: Theme.of(context).copyWith(
          dividerColor: Colors.transparent,
          cardColor: Colors.white,
        ),
        child: ExpansionTile(
          key: Key(semester),
          tilePadding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          childrenPadding: EdgeInsets.only(left: 16, right: 16, bottom: 8),
          initiallyExpanded: _expandedSemesters[semester] ?? false,
          onExpansionChanged: (expanded) {
            setState(() {
              _expandedSemesters[semester] = expanded;
            });
          },
          title: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Text(
                  semester,
                  style: TextStyle(
                    fontWeight: FontWeight.w600,
                    fontSize: 16,
                  ),
                ),
              ),
              Container(
                padding: EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                decoration: BoxDecoration(
                  color: Colors.black,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      'Средний: ${average.toStringAsFixed(2)}',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    SizedBox(width: 6),
                    Text(
                      '(${grades.length})',
                      style: TextStyle(
                        color: Colors.grey[300],
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          trailing: Container(
            width: 30,
            height: 30,
            decoration: BoxDecoration(
              color: Colors.grey[100],
              shape: BoxShape.circle,
            ),
            child: Icon(
              _expandedSemesters[semester] ?? false
                  ? Icons.expand_less
                  : Icons.expand_more,
              color: Colors.black,
              size: 20,
            ),
          ),
          children: [
            ...grades.map((grade) => _buildDetailedGradeItem(grade)).toList(),
          ],
        ),
      ),
    );
  }

  Widget _buildDetailedGradeItem(Grade grade) {
    return Container(
      margin: EdgeInsets.only(left: 16, right: 16, bottom: 12),
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.grey[200]!),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Оценка
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: _getGradeColor(grade.value),
              borderRadius: BorderRadius.circular(8),
            ),
            alignment: Alignment.center,
            child: Text(
              grade.value.toString(),
              style: TextStyle(
                color: Colors.white,
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),

          SizedBox(width: 16),

          // Информация
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  grade.subject,
                  style: TextStyle(
                    fontWeight: FontWeight.w600,
                    fontSize: 16,
                  ),
                ),
                SizedBox(height: 4),
                Text(
                  grade.teacher,
                  style: TextStyle(
                    color: Colors.grey[600],
                    fontSize: 14,
                  ),
                ),
                SizedBox(height: 2),
                Row(
                  children: [
                    Container(
                      padding: EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                      decoration: BoxDecoration(
                        color: Colors.grey[100],
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Text(
                        grade.type,
                        style: TextStyle(
                          color: Colors.grey[700],
                          fontSize: 12,
                        ),
                      ),
                    ),
                    SizedBox(width: 8),
                    Text(
                      '${grade.date.day.toString().padLeft(2, '0')}.'
                          '${grade.date.month.toString().padLeft(2, '0')}.${grade.date.year}',
                      style: TextStyle(
                        color: Colors.grey[500],
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSessionDetails(ExamsProvider provider) {
    final upcomingExams = provider.upcomingExams;
    final completedExams = provider.completedExams;

    return DraggableScrollableSheet(
      initialChildSize: 0.85,
      minChildSize: 0.5,
      maxChildSize: 0.95,
      expand: false,
      builder: (context, scrollController) {
        return Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
          ),
          child: Column(
            children: [
              // Шапка
              Container(
                padding: EdgeInsets.all(20),
                decoration: BoxDecoration(
                  border: Border(bottom: BorderSide(color: Colors.grey[200]!)),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Сессия',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    Row(
                      children: [
                        _buildExamBadge('Осталось', upcomingExams.length, Colors.orange),
                        SizedBox(width: 8),
                        _buildExamBadge('Сдано', completedExams.length, Colors.green),
                      ],
                    ),
                  ],
                ),
              ),

              // Контент
              Expanded(
                child: ListView(
                  controller: scrollController,
                  padding: EdgeInsets.all(16),
                  children: [
                    if (upcomingExams.isNotEmpty) ...[
                      Text(
                        'Предстоящие экзамены',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      SizedBox(height: 12),
                      ...upcomingExams.map((exam) => _buildDetailedExamItem(exam, false)).toList(),
                      SizedBox(height: 20),
                    ],

                    if (completedExams.isNotEmpty) ...[
                      Text(
                        'Сданные экзамены',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      SizedBox(height: 12),
                      ...completedExams.map((exam) => _buildDetailedExamItem(exam, true)).toList(),
                      SizedBox(height: 20),
                    ],

                    if (upcomingExams.isEmpty && completedExams.isEmpty) ...[
                      Center(
                        child: Column(
                          children: [
                            Icon(Icons.assignment_outlined, size: 64, color: Colors.grey[300]),
                            SizedBox(height: 16),
                            Text(
                              'Нет данных о сессии',
                              style: TextStyle(color: Colors.grey[600]),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildDetailedExamItem(Exam exam, bool isCompleted) {
    return Container(
      margin: EdgeInsets.only(bottom: 12),
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isCompleted ? Colors.green[100]! : Colors.orange[100]!,
          width: 2,
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Статус
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: isCompleted ? Colors.green : Colors.orange,
              borderRadius: BorderRadius.circular(8),
            ),
            alignment: Alignment.center,
            child: Icon(
              isCompleted ? Icons.check : Icons.access_time,
              color: Colors.white,
              size: 20,
            ),
          ),

          SizedBox(width: 16),

          // Информация
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Text(
                        exam.subject,
                        style: TextStyle(
                          fontWeight: FontWeight.w600,
                          fontSize: 16,
                        ),
                      ),
                    ),
                    if (isCompleted && exam.grade != null)
                      Container(
                        padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: _getGradeColor(exam.grade!),
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Text(
                          exam.grade!.toString(),
                          style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                  ],
                ),
                SizedBox(height: 8),
                Row(
                  children: [
                    Icon(Icons.person, size: 14, color: Colors.grey[500]),
                    SizedBox(width: 4),
                    Expanded(
                      child: Text(
                        exam.teacher,
                        style: TextStyle(
                          color: Colors.grey[600],
                          fontSize: 14,
                        ),
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 4),
                Row(
                  children: [
                    Icon(Icons.calendar_today, size: 14, color: Colors.grey[500]),
                    SizedBox(width: 4),
                    Text(
                      exam.date,
                      style: TextStyle(
                        color: Colors.grey[600],
                        fontSize: 14,
                      ),
                    ),
                    SizedBox(width: 16),
                    Icon(Icons.access_time, size: 14, color: Colors.grey[500]),
                    SizedBox(width: 4),
                    Text(
                      exam.time,
                      style: TextStyle(
                        color: Colors.grey[600],
                        fontSize: 14,
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 4),
                Row(
                  children: [
                    Icon(Icons.location_on, size: 14, color: Colors.grey[500]),
                    SizedBox(width: 4),
                    Text(
                      exam.classroom,
                      style: TextStyle(
                        color: Colors.grey[600],
                        fontSize: 14,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatsDetails(GradesProvider gradesProvider, EventsProvider eventsProvider) {
    final grades = gradesProvider.grades;
    final pastEvents = eventsProvider.pastEvents;

    // Лабораторные
    final labs = grades.where((g) => g.type.toLowerCase().contains('лабораторная')).toList();
    final passedLabs = labs.where((l) => l.value >= 3).length;
    final failedLabs = labs.where((l) => l.value < 3).toList();

    return DraggableScrollableSheet(
      initialChildSize: 0.85,
      minChildSize: 0.5,
      maxChildSize: 0.95,
      expand: false,
      builder: (context, scrollController) {
        return Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
          ),
          child: Column(
            children: [
              // Шапка
              Container(
                padding: EdgeInsets.all(20),
                decoration: BoxDecoration(
                  border: Border(bottom: BorderSide(color: Colors.grey[200]!)),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Статистика работ',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    Container(
                      padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(
                        color: Colors.black,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        '${passedLabs}/${labs.length} сдано',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              // Контент
              Expanded(
                child: ListView(
                  controller: scrollController,
                  padding: EdgeInsets.all(16),
                  children: [
                    // Лабораторные
                    Container(
                      margin: EdgeInsets.only(bottom: 20),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Лабораторные работы',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          SizedBox(height: 12),

                          if (labs.isNotEmpty) ...[
                            // Прогресс бар
                            Container(
                              padding: EdgeInsets.all(16),
                              decoration: BoxDecoration(
                                color: Colors.grey[50],
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Column(
                                children: [
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    children: [
                                      Text('Прогресс'),
                                      Text('$passedLabs/${labs.length}'),
                                    ],
                                  ),
                                  SizedBox(height: 8),
                                  LinearProgressIndicator(
                                    value: labs.isNotEmpty ? passedLabs / labs.length : 0,
                                    backgroundColor: Colors.grey[300],
                                    color: passedLabs == labs.length ? Colors.green : Colors.blue,
                                    minHeight: 8,
                                    borderRadius: BorderRadius.circular(4),
                                  ),
                                ],
                              ),
                            ),
                            SizedBox(height: 16),

                            // Список лабораторных
                            ...labs.map((lab) => _buildLabItem(lab)).toList(),
                          ] else ...[ Center(
                            child: Container(
                              padding: EdgeInsets.all(32),
                              decoration: BoxDecoration(
                                color: Colors.grey[50],
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Column(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Icon(Icons.science_outlined, size: 48, color: Colors.grey[300]),
                                  SizedBox(height: 12),
                                  Text(
                                    'Нет данных о лабораторных',
                                    style: TextStyle(color: Colors.grey[600]),
                                  ),
                                ],
                              ),
                            )),
                          ],
                        ],
                      ),
                    ),

                    // Несданные лабораторные
                    if (failedLabs.isNotEmpty) ...[
                      Container(
                        margin: EdgeInsets.only(bottom: 20),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Требуют пересдачи',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                                color: Colors.red,
                              ),
                            ),
                            SizedBox(height: 12),
                            ...failedLabs.map((lab) => _buildFailedLabItem(lab)).toList(),
                          ],
                        ),
                      ),
                    ],

                    // Бонусные баллы
                    if (pastEvents.isNotEmpty) ...[
                      Container(
                        margin: EdgeInsets.only(bottom: 20),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Бонусные баллы',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            SizedBox(height: 12),
                            Container(
                              padding: EdgeInsets.all(16),
                              decoration: BoxDecoration(
                                color: Colors.amber[50],
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Column(
                                children: [
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    children: [
                                      Text(
                                        'Всего накоплено',
                                        style: TextStyle(
                                          fontWeight: FontWeight.w600,
                                        ),
                                      ),
                                      Text(
                                        '${pastEvents.fold(0, (sum, event) => sum + event.points)} баллов',
                                        style: TextStyle(
                                          fontWeight: FontWeight.bold,
                                          color: Colors.amber[800],
                                        ),
                                      ),
                                    ],
                                  ),
                                  SizedBox(height: 8),
                                  ...pastEvents.take(3).map((event) => _buildEventItem(event)).toList(),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildLabItem(Grade lab) {
    return Container(
      margin: EdgeInsets.only(bottom: 8),
      padding: EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.grey[200]!),
      ),
      child: Row(
        children: [
          Container(
            width: 32,
            height: 32,
            decoration: BoxDecoration(
              color: lab.value >= 3 ? Colors.green[100] : Colors.red[100],
              borderRadius: BorderRadius.circular(6),
            ),
            alignment: Alignment.center,
            child: Icon(
              lab.value >= 3 ? Icons.check : Icons.close,
              color: lab.value >= 3 ? Colors.green : Colors.red,
              size: 16,
            ),
          ),
          SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  lab.subject,
                  style: TextStyle(
                    fontWeight: FontWeight.w500,
                  ),
                ),
                Text(
                  'Лабораторная работа • ${lab.teacher}',
                  style: TextStyle(
                    color: Colors.grey[600],
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
          Container(
            padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: lab.value >= 3 ? Colors.green : Colors.red,
              borderRadius: BorderRadius.circular(4),
            ),
            child: Text(
              lab.value >= 3 ? 'Сдано' : 'Не сдано',
              style: TextStyle(
                color: Colors.white,
                fontSize: 12,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFailedLabItem(Grade lab) {
    return Container(
      margin: EdgeInsets.only(bottom: 8),
      padding: EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.red[50],
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.red[100]!),
      ),
      child: Row(
        children: [
          Icon(Icons.warning, color: Colors.red, size: 20),
          SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  lab.subject,
                  style: TextStyle(
                    fontWeight: FontWeight.w500,
                    color: Colors.red[800],
                  ),
                ),
                Text(
                  'Лабораторная работа • ${lab.teacher}',
                  style: TextStyle(
                    color: Colors.red[600],
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
          Text(
            'Оценка: ${lab.value}',
            style: TextStyle(
              color: Colors.red,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEventItem(Event event) {
    return Container(
      margin: EdgeInsets.only(bottom: 8),
      padding: EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(6),
      ),
      child: Row(
        children: [
          Container(
            width: 24,
            height: 24,
            decoration: BoxDecoration(
              color: Colors.amber[100],
              borderRadius: BorderRadius.circular(4),
            ),
            alignment: Alignment.center,
            child: Icon(Icons.star, color: Colors.amber, size: 12),
          ),
          SizedBox(width: 8),
          Expanded(
            child: Text(
              event.title,
              style: TextStyle(fontSize: 12),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
          SizedBox(width: 8),
          Text(
            '+${event.points}',
            style: TextStyle(
              color: Colors.amber[800],
              fontWeight: FontWeight.bold,
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildExamBadge(String text, int count, Color color) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 6,
            height: 6,
            decoration: BoxDecoration(
              color: color,
              shape: BoxShape.circle,
            ),
          ),
          SizedBox(width: 6),
          Text(
            '$text: $count',
            style: TextStyle(
              color: color,
              fontSize: 12,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  // Вспомогательные методы
  double _calculateAverage(List<Grade> grades) {
    if (grades.isEmpty) return 0.0;
    final validGrades = grades.where((g) => g.value > 0 && g.value <= 5);
    if (validGrades.isEmpty) return 0.0;
    final sum = validGrades.map((g) => g.value).reduce((a, b) => a + b);
    return sum / validGrades.length;
  }

  Color _getGradeColor(int grade) {
    if (grade >= 4) return Colors.green;
    if (grade == 3) return Colors.orange;
    return Colors.red;
  }
}