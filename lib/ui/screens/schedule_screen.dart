import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../core/constants.dart';
import '../../core/providers/schedule_provider.dart';
import '../../core/providers/student_provider.dart';
import '../../data/models/schedule.dart';
import '../widgets/schedule_detail_sheet.dart';
import '../widgets/sheet_handle.dart';

/// Слоты как на портале (пары).
const List<(TimeOfDay, TimeOfDay)> kScheduleSlots = [
  (TimeOfDay(hour: 8, minute: 40), TimeOfDay(hour: 10, minute: 15)),
  (TimeOfDay(hour: 10, minute: 25), TimeOfDay(hour: 12, minute: 0)),
  (TimeOfDay(hour: 12, minute: 40), TimeOfDay(hour: 14, minute: 15)),
  (TimeOfDay(hour: 14, minute: 25), TimeOfDay(hour: 16, minute: 0)),
  (TimeOfDay(hour: 16, minute: 10), TimeOfDay(hour: 17, minute: 45)),
  (TimeOfDay(hour: 17, minute: 55), TimeOfDay(hour: 19, minute: 30)),
  (TimeOfDay(hour: 19, minute: 40), TimeOfDay(hour: 21, minute: 15)),
];

class ScheduleScreen extends StatefulWidget {
  const ScheduleScreen({super.key});

  @override
  State<ScheduleScreen> createState() => _ScheduleScreenState();
}

class _ScheduleScreenState extends State<ScheduleScreen> {
  DateTime _focusDay = DateTime.now();
  bool _weekMode = true;
  bool _showInfoBanner = true;
  String? _typeFilter;

  DateTime get _monday => _startOfWeek(_focusDay);
  DateTime get _sunday => _monday.add(const Duration(days: 6));

  static DateTime _startOfWeek(DateTime d) {
    final x = DateTime(d.year, d.month, d.day);
    return x.subtract(Duration(days: x.weekday - DateTime.monday));
  }

  String _fmtDate(DateTime d) => DateFormat('dd.MM.yyyy').format(d);

  Schedule? _slotMatch(DateTime day, TimeOfDay slotStart, List<Schedule> all) {
    for (final s in all) {
      if (s.startTime.year != day.year || s.startTime.month != day.month || s.startTime.day != day.day) {
        continue;
      }
      if (s.startTime.hour == slotStart.hour && s.startTime.minute == slotStart.minute) {
        return s;
      }
    }
    return null;
  }

  List<Schedule> _applyType(List<Schedule> list) {
    if (_typeFilter == null) return list;
    return list.where((s) => s.type.toLowerCase() == _typeFilter!.toLowerCase()).toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppConstants.surfaceWhite,
      appBar: AppBar(
        title: const Text('Расписание'),
        actions: [
          IconButton(
            icon: const Icon(PhosphorIconsRegular.faders),
            tooltip: 'Тип занятия',
            onPressed: () => _showTypeFilterSheet(context),
          ),
          IconButton(
            icon: const Icon(PhosphorIconsRegular.arrowsClockwise),
            tooltip: 'Обновить',
            onPressed: () => context.read<ScheduleProvider>().loadSchedule(),
          ),
        ],
      ),
      body: Consumer2<ScheduleProvider, StudentProvider>(
        builder: (context, scheduleProv, studentProv, _) {
          if (scheduleProv.isLoading && scheduleProv.schedule.isEmpty) {
            return const Center(child: CircularProgressIndicator(color: AppConstants.terracotta));
          }
          final all = _applyType(scheduleProv.schedule);
          final student = studentProv.student;
          final group = student?.group ?? '—';

          return RefreshIndicator(
            color: AppConstants.terracotta,
            onRefresh: () => scheduleProv.loadSchedule(),
            child: SingleChildScrollView(
              physics: const AlwaysScrollableScrollPhysics(),
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  if (_showInfoBanner) _buildInfoBanner(),
                  Text(
                    'Расписание',
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.w800,
                          color: AppConstants.blockBlack,
                        ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    student == null
                        ? 'Загрузка профиля…'
                        : 'Очная, ${student.faculty}, ${student.specialty}, группа ${student.group}',
                    style: TextStyle(fontSize: 13, height: 1.4, color: AppConstants.secondaryColor),
                  ),
                  const SizedBox(height: 12),
                  Align(
                    alignment: Alignment.centerLeft,
                    child: TextButton.icon(
                      onPressed: () async {
                        final u = Uri.parse(AppConstants.portalStudyUrl);
                        if (await canLaunchUrl(u)) {
                          await launchUrl(u, mode: LaunchMode.externalApplication);
                        }
                      },
                      icon: const Icon(PhosphorIconsRegular.arrowSquareOut, size: 18),
                      label: const Text('Ссылка на расписание (электронное обучение)'),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Данные приходят из 1С; при расхождениях ориентируйтесь на кабинет на сайте.',
                    style: TextStyle(fontSize: 12, color: AppConstants.secondaryColor),
                  ),
                  const SizedBox(height: 16),
                  SegmentedButton<bool>(
                    segments: const [
                      ButtonSegment(value: false, label: Text('День'), icon: Icon(PhosphorIconsRegular.calendar, size: 18)),
                      ButtonSegment(value: true, label: Text('Неделя'), icon: Icon(PhosphorIconsRegular.calendarDots, size: 18)),
                    ],
                    selected: {_weekMode},
                    onSelectionChanged: (s) => setState(() => _weekMode = s.first),
                    style: ButtonStyle(
                      foregroundColor: WidgetStateProperty.resolveWith((states) {
                        if (states.contains(WidgetState.selected)) {
                          return AppConstants.surfaceWhite;
                        }
                        return AppConstants.blockBlack;
                      }),
                      backgroundColor: WidgetStateProperty.resolveWith((states) {
                        if (states.contains(WidgetState.selected)) {
                          return AppConstants.terracotta;
                        }
                        return AppConstants.surfaceMuted;
                      }),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      IconButton(
                        onPressed: () => setState(() {
                          _focusDay = _focusDay.subtract(Duration(days: _weekMode ? 7 : 1));
                        }),
                        icon: const Icon(PhosphorIconsRegular.caretLeft),
                      ),
                      Expanded(
                        child: Column(
                          children: [
                            Text(
                              'с ${_fmtDate(_weekMode ? _monday : DateTime(_focusDay.year, _focusDay.month, _focusDay.day))} по ${_fmtDate(_weekMode ? _sunday : DateTime(_focusDay.year, _focusDay.month, _focusDay.day))}',
                              textAlign: TextAlign.center,
                              style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 15),
                            ),
                            TextButton(
                              onPressed: () async {
                                final picked = await showDatePicker(
                                  context: context,
                                  initialDate: _focusDay,
                                  firstDate: DateTime(2023),
                                  lastDate: DateTime(2028),
                                  locale: const Locale('ru', 'RU'),
                                );
                                if (picked != null) setState(() => _focusDay = picked);
                              },
                              child: const Text('Выбрать дату'),
                            ),
                          ],
                        ),
                      ),
                      IconButton(
                        onPressed: () => setState(() {
                          _focusDay = _focusDay.add(Duration(days: _weekMode ? 7 : 1));
                        }),
                        icon: const Icon(PhosphorIconsRegular.caretRight),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  if (_typeFilter != null)
                    Padding(
                      padding: const EdgeInsets.only(bottom: 8),
                      child: Text(
                        'Фильтр: $_typeFilter',
                        style: TextStyle(fontSize: 12, color: AppConstants.terracottaDark, fontWeight: FontWeight.w600),
                      ),
                    ),
                  if (_weekMode)
                    for (var i = 0; i < 7; i++)
                      _buildDaySection(context, _monday.add(Duration(days: i)), all, group)
                  else
                    _buildDaySection(
                      context,
                      DateTime(_focusDay.year, _focusDay.month, _focusDay.day),
                      all,
                      group,
                    ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildInfoBanner() {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Material(
        color: AppConstants.surfaceMuted,
        borderRadius: BorderRadius.circular(AppConstants.cardRadius),
        child: Padding(
          padding: const EdgeInsets.fromLTRB(14, 12, 8, 12),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Icon(PhosphorIconsRegular.info, color: AppConstants.terracotta, size: 22),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  'Для отображения данных укажите период и при необходимости тип занятия. Нажмите «Обновить» после синхронизации с 1С.',
                  style: TextStyle(fontSize: 13, height: 1.35, color: AppConstants.secondaryColor),
                ),
              ),
              IconButton(
                onPressed: () => setState(() => _showInfoBanner = false),
                icon: const Icon(PhosphorIconsRegular.x, size: 20),
                color: AppConstants.secondaryColor,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDaySection(BuildContext context, DateTime day, List<Schedule> all, String group) {
    final title = '${DateFormat('EEEE', 'ru_RU').format(day)} ${_fmtDate(day)}';
    return Padding(
      padding: const EdgeInsets.only(bottom: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Container(
            padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 12),
            decoration: const BoxDecoration(
              color: AppConstants.blockBlack,
              borderRadius: BorderRadius.vertical(top: Radius.circular(10)),
            ),
            child: Text(
              title[0].toUpperCase() + title.substring(1),
              style: const TextStyle(
                color: AppConstants.onBlock,
                fontWeight: FontWeight.w800,
                fontSize: 14,
              ),
            ),
          ),
          Table(
            border: TableBorder.all(color: AppConstants.borderSubtle),
            columnWidths: const {
              0: FlexColumnWidth(1.15),
              1: FlexColumnWidth(1.6),
              2: FlexColumnWidth(0.75),
              3: FlexColumnWidth(0.65),
              4: FlexColumnWidth(1.2),
            },
            children: [
              TableRow(
                decoration: const BoxDecoration(color: AppConstants.surfaceMuted),
                children: [
                  _cellHeader('Часы'),
                  _cellHeader('Дисциплина'),
                  _cellHeader('Аудит.'),
                  _cellHeader('Группа'),
                  _cellHeader('Преподаватель'),
                ],
              ),
              for (final slot in kScheduleSlots)
                _slotRow(context, day, slot, all, group),
            ],
          ),
        ],
      ),
    );
  }

  Widget _cellHeader(String t) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 6),
      child: Text(
        t,
        style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 11, color: AppConstants.blockBlack),
      ),
    );
  }

  TableRow _slotRow(
    BuildContext context,
    DateTime day,
    (TimeOfDay, TimeOfDay) slot,
    List<Schedule> all,
    String group,
  ) {
    final start = slot.$1;
    final end = slot.$2;
    final timeStr =
        '${start.hour.toString().padLeft(2, '0')}:${start.minute.toString().padLeft(2, '0')} - ${end.hour.toString().padLeft(2, '0')}:${end.minute.toString().padLeft(2, '0')}';
    final m = _slotMatch(day, start, all);
    final discipline = m == null ? '' : '${m.subject}\n${_typeTitle(m.type)}';
    final room = m?.classroom ?? '';
    final teacher = m?.teacher ?? '';

    return TableRow(
      children: [
        _cellBody(timeStr),
        _cellBodyTap(
          context,
          discipline,
          m,
        ),
        _cellBody(room),
        _cellBody(group),
        _cellBody(teacher),
      ],
    );
  }

  String _typeTitle(String type) {
    final t = type.toLowerCase();
    if (t.contains('лек')) return 'Лекционные занятия';
    if (t.contains('лаб')) return 'Лабораторные занятия';
    if (t.contains('прак')) return 'Практические занятия';
    return type;
  }

  Widget _cellBody(String text) {
    return Padding(
      padding: const EdgeInsets.all(8),
      child: Text(
        text,
        style: const TextStyle(fontSize: 12, height: 1.3, color: AppConstants.blockBlack),
      ),
    );
  }

  Widget _cellBodyTap(BuildContext context, String text, Schedule? m) {
    final child = Padding(
      padding: const EdgeInsets.all(8),
      child: Text(
        text,
        style: const TextStyle(fontSize: 12, height: 1.3, color: AppConstants.blockBlack),
      ),
    );
    if (m == null) return child;
    return GestureDetector(
      onTap: () => showScheduleDetailSheet(context, m),
      child: child,
    );
  }

  void _showTypeFilterSheet(BuildContext context) {
    showModalBottomSheet<void>(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (ctx) {
        void pick(String? type) {
          setState(() => _typeFilter = type);
          Navigator.pop(ctx);
        }

        return Container(
          decoration: const BoxDecoration(
            color: AppConstants.surfaceWhite,
            borderRadius: BorderRadius.vertical(top: Radius.circular(AppConstants.sheetTopRadius)),
          ),
          child: SafeArea(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(8, 8, 8, 16),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const SheetGrabHandle(),
                  const Padding(
                    padding: EdgeInsets.fromLTRB(12, 8, 12, 4),
                    child: Text(
                      'Тип занятия',
                      style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800),
                    ),
                  ),
                  ListTile(
                    title: const Text('Все типы'),
                    trailing: _typeFilter == null
                        ? const Icon(PhosphorIconsRegular.check, color: AppConstants.terracotta)
                        : null,
                    onTap: () => pick(null),
                  ),
                  ListTile(
                    title: const Text('Лекция'),
                    trailing: _typeFilter?.toLowerCase() == 'лекция'
                        ? const Icon(PhosphorIconsRegular.check, color: AppConstants.terracotta)
                        : null,
                    onTap: () => pick('лекция'),
                  ),
                  ListTile(
                    title: const Text('Практика'),
                    trailing: _typeFilter?.toLowerCase() == 'практика'
                        ? const Icon(PhosphorIconsRegular.check, color: AppConstants.terracotta)
                        : null,
                    onTap: () => pick('практика'),
                  ),
                  ListTile(
                    title: const Text('Лабораторная'),
                    trailing: _typeFilter?.toLowerCase() == 'лабораторная'
                        ? const Icon(PhosphorIconsRegular.check, color: AppConstants.terracotta)
                        : null,
                    onTap: () => pick('лабораторная'),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}
