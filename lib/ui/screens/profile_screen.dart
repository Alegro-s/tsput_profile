import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../core/constants.dart';
import '../../core/providers/main_nav_provider.dart';
import '../../core/providers/portfolio_provider.dart';
import '../../core/providers/student_provider.dart';
import '../../data/portfolio_pedagogy_sections.dart';
import '../widgets/profile_card.dart';
import '../widgets/sheet_handle.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final nav = context.watch<MainNavProvider>();
    if (nav.shouldOpenPortfolioTab) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (!mounted) return;
        _tabController.animateTo(1);
        context.read<MainNavProvider>().clearPortfolioTabRequest();
      });
    }

    final studentProvider = context.watch<StudentProvider>();
    final student = studentProvider.student;

    if (student == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('Профиль')),
        body: const Center(child: CircularProgressIndicator(color: AppConstants.terracotta)),
      );
    }

    return Scaffold(
      backgroundColor: AppConstants.surfaceWhite,
      appBar: AppBar(
        title: const Text('Личный кабинет'),
        bottom: TabBar(
          controller: _tabController,
          labelColor: AppConstants.terracotta,
          unselectedLabelColor: AppConstants.secondaryColor,
          indicatorColor: AppConstants.terracotta,
          indicatorWeight: 3,
          labelStyle: const TextStyle(fontWeight: FontWeight.w700, fontSize: 14),
          tabs: const [
            Tab(text: 'Данные студента'),
            Tab(text: 'Портфолио'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _StudentDataTab(
            onRefresh: () => studentProvider.loadStudentData(),
          ),
          const _PortfolioPedagogyTab(),
        ],
      ),
    );
  }
}

class _StudentDataTab extends StatelessWidget {
  const _StudentDataTab({required this.onRefresh});

  final VoidCallback onRefresh;

  @override
  Widget build(BuildContext context) {
    final student = context.watch<StudentProvider>().student!;
    final info = student.additionalInfo;

    final tiles = <(String, String)>[
      ('ФИО', student.fullName),
      ('Группа', student.group),
      ('Институт', student.faculty),
      ('Специальность', student.specialty),
      ('Курс', '${student.course}'),
      ('Email', student.email),
      ('Телефон', student.phone),
      ('Адрес', student.address),
      if (info['recordBook'] != null) ('Зачётная книжка', info['recordBook'].toString()),
      if (info['trainingLevel'] != null) ('Уровень подготовки', info['trainingLevel'].toString()),
      if (info['profile'] != null) ('Профиль', info['profile'].toString()),
      if (info['studentStatus'] != null) ('Статус', info['studentStatus'].toString()),
      if (info['birthDate'] != null) ('Дата рождения', info['birthDate'].toString()),
      (
        'Поступление',
        '${student.admissionDate.day.toString().padLeft(2, '0')}.${student.admissionDate.month.toString().padLeft(2, '0')}.${student.admissionDate.year}',
      ),
      (
        'Выпуск',
        '${student.graduationDate.day.toString().padLeft(2, '0')}.${student.graduationDate.month.toString().padLeft(2, '0')}.${student.graduationDate.year}',
      ),
      if (info['scholarship'] != null) ('Стипендия', '${info['scholarship']} ₽'),
      if (info['dormitory'] != null) ('Общежитие', info['dormitory'].toString()),
      if (info['averageGrade'] != null) ('Средний балл', info['averageGrade'].toString()),
    ];

    return RefreshIndicator(
      color: AppConstants.terracotta,
      onRefresh: () async => onRefresh(),
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 32),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            ProfileCard(
              onSettingsPressed: null,
              onRefreshPressed: onRefresh,
            ),
            const SizedBox(height: 20),
            Text(
              'Сведения подгружаются из 1С и отображаются как в веб-кабинете.',
              style: TextStyle(
                fontSize: 13,
                height: 1.4,
                color: AppConstants.secondaryColor,
              ),
            ),
            const SizedBox(height: 16),
            LayoutBuilder(
              builder: (context, c) {
                final gap = 12.0;
                final w = (c.maxWidth - gap) / 2;
                return Wrap(
                  spacing: gap,
                  runSpacing: gap,
                  children: [
                    for (final t in tiles)
                      SizedBox(
                        width: w,
                        child: _PedaFieldCard(label: t.$1, value: t.$2),
                      ),
                  ],
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}

class _PedaFieldCard extends StatelessWidget {
  const _PedaFieldCard({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppConstants.surfaceWhite,
        borderRadius: BorderRadius.circular(AppConstants.cardRadius),
        border: Border.all(color: AppConstants.borderSubtle),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w600,
              color: AppConstants.secondaryColor,
              letterSpacing: 0.2,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            value,
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: AppConstants.blockBlack,
              height: 1.25,
            ),
          ),
        ],
      ),
    );
  }
}

class _PortfolioPedagogyTab extends StatelessWidget {
  const _PortfolioPedagogyTab();

  void _openCategory(BuildContext context, String section, String item) {
    final portfolio = context.read<PortfolioProvider>();
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) {
        final bottom = MediaQuery.of(ctx).padding.bottom;
        final matches = portfolio.items
            .where(
              (p) =>
                  p.category.toLowerCase().contains(item.toLowerCase()) ||
                  p.title.toLowerCase().contains(item.toLowerCase()),
            )
            .toList();
        return Container(
          decoration: const BoxDecoration(
            color: AppConstants.surfaceWhite,
            borderRadius: BorderRadius.vertical(top: Radius.circular(AppConstants.sheetTopRadius)),
          ),
          padding: EdgeInsets.fromLTRB(20, 12, 20, 20 + bottom),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const SheetGrabHandle(),
              Text(
                item,
                style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w800, color: AppConstants.blockBlack),
              ),
              Text(
                section,
                style: TextStyle(fontSize: 13, color: AppConstants.secondaryColor),
              ),
              const SizedBox(height: 12),
              Text(
                'Заполнение и согласование документов выполняются в личном кабинете вуза (источник — 1С). После выдачи API раздел откроет форму или глубокую ссылку.',
                style: TextStyle(fontSize: 14, height: 1.45, color: AppConstants.secondaryColor),
              ),
              if (matches.isNotEmpty) ...[
                const SizedBox(height: 16),
                const Text(
                  'Уже есть записи с сервера:',
                  style: TextStyle(fontWeight: FontWeight.w700, fontSize: 14),
                ),
                const SizedBox(height: 8),
                ...matches.map(
                  (p) => ListTile(
                    contentPadding: EdgeInsets.zero,
                    title: Text(p.title, style: const TextStyle(fontWeight: FontWeight.w600)),
                    subtitle: Text('${p.category} · ${p.status}', style: TextStyle(fontSize: 12, color: AppConstants.secondaryColor)),
                  ),
                ),
              ],
              const SizedBox(height: 16),
              FilledButton(
                onPressed: () => Navigator.pop(ctx),
                child: const Text('Понятно'),
              ),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final student = context.watch<StudentProvider>().student;

    return RefreshIndicator(
      color: AppConstants.terracotta,
      onRefresh: () => context.read<PortfolioProvider>().loadPortfolio(),
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 32),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              'Моё портфолио',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.w800,
                    color: AppConstants.blockBlack,
                  ),
            ),
            const SizedBox(height: 6),
            Text(
              'Выберите раздел. Данные в приложении приходят из 1С; загрузка файлов — через кабинет на сайте до готовности API.',
              style: TextStyle(fontSize: 13, height: 1.4, color: AppConstants.secondaryColor),
            ),
            if (student != null) ...[
              const SizedBox(height: 12),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: AppConstants.surfaceMuted,
                  borderRadius: BorderRadius.circular(AppConstants.cardRadius),
                  border: Border.all(color: AppConstants.borderSubtle),
                ),
                child: Text(
                  'Учебный план: ${student.group}. ${student.faculty}, ${student.specialty}',
                  style: const TextStyle(fontSize: 13, height: 1.35, fontWeight: FontWeight.w500),
                ),
              ),
            ],
            const SizedBox(height: 20),
            for (final row in PortfolioPedagogySections.rows) ...[
              Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: Text(
                  row.$1,
                  style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w800,
                    color: AppConstants.blockBlack,
                  ),
                ),
              ),
              LayoutBuilder(
                builder: (context, c) {
                  const gap = 10.0;
                  final w = (c.maxWidth - gap) / 2;
                  return Wrap(
                    spacing: gap,
                    runSpacing: gap,
                    children: [
                      for (final item in row.$2)
                        SizedBox(
                          width: w,
                          child: Material(
                            color: AppConstants.surfaceWhite,
                            borderRadius: BorderRadius.circular(12),
                            child: InkWell(
                              onTap: () => _openCategory(context, row.$1, item),
                              borderRadius: BorderRadius.circular(12),
                              child: Container(
                                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(12),
                                  border: Border.all(color: AppConstants.borderSubtle),
                                ),
                                child: Text(
                                  item,
                                  style: const TextStyle(
                                    fontSize: 13,
                                    fontWeight: FontWeight.w600,
                                    height: 1.25,
                                    color: AppConstants.blockBlack,
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ),
                    ],
                  );
                },
              ),
              const SizedBox(height: 18),
            ],
          ],
        ),
      ),
    );
  }
}
