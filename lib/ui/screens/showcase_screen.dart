import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../core/constants.dart';
import '../../core/providers/portfolio_provider.dart';
import '../../core/providers/student_provider.dart';

/// Витрина (стиль T-Bank): баннеры, быстрые действия, карта партнёров, портфолио, привязка почты.
class ShowcaseScreen extends StatefulWidget {
  const ShowcaseScreen({super.key});

  @override
  State<ShowcaseScreen> createState() => _ShowcaseScreenState();
}

class _ShowcaseScreenState extends State<ShowcaseScreen> {
  final PageController _bannerController = PageController(viewportFraction: 0.88);
  final ScrollController _scroll = ScrollController();
  final GlobalKey _portfolioKey = GlobalKey();
  final GlobalKey _mapKey = GlobalKey();

  bool _localMapUnlock = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<PortfolioProvider>().loadPortfolio();
      _loadPrefs();
    });
  }

  Future<void> _loadPrefs() async {
    final p = await SharedPreferences.getInstance();
    if (!mounted) return;
    setState(() {
      _localMapUnlock = p.getBool(AppConstants.prefPartnerMapUnlocked) ?? false;
    });
  }

  Future<void> _setLocalMapUnlock(bool v) async {
    final p = await SharedPreferences.getInstance();
    await p.setBool(AppConstants.prefPartnerMapUnlocked, v);
    if (mounted) setState(() => _localMapUnlock = v);
  }

  bool _apiMapAccess(StudentProvider sp) {
    return sp.student?.additionalInfo['partnerMapAccess'] == true;
  }

  bool _showPartnerMap(StudentProvider sp) => _apiMapAccess(sp) || _localMapUnlock;

  Future<void> _openPortal() async {
    final uri = Uri.parse(AppConstants.portalRegisterUrl);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    }
  }

  void _scrollTo(GlobalKey key) {
    final ctx = key.currentContext;
    if (ctx != null) {
      Scrollable.ensureVisible(
        ctx,
        duration: const Duration(milliseconds: 400),
        curve: Curves.easeOutCubic,
      );
    }
  }

  @override
  void dispose() {
    _bannerController.dispose();
    _scroll.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final portfolio = context.watch<PortfolioProvider>();

    return Scaffold(
      backgroundColor: AppConstants.backgroundColor,
      body: RefreshIndicator(
        color: AppConstants.primaryColor,
        onRefresh: () async {
          await context.read<PortfolioProvider>().loadPortfolio();
          await context.read<StudentProvider>().loadStudentData();
        },
        child: CustomScrollView(
          controller: _scroll,
          physics: const AlwaysScrollableScrollPhysics(),
          slivers: [
          SliverToBoxAdapter(child: _buildHeader(context)),
          SliverToBoxAdapter(child: _buildQuickActions(context)),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: KeyedSubtree(
                key: _mapKey,
                child: _buildMapBlock(context),
              ),
            ),
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
              child: _linkEmailCard(context),
            ),
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 4),
              child: Text(
                'Портфолио',
                key: _portfolioKey,
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.w700,
                    ),
              ),
            ),
          ),
          if (portfolio.isLoading)
            const SliverToBoxAdapter(
              child: Padding(
                padding: EdgeInsets.all(32),
                child: Center(child: CircularProgressIndicator()),
              ),
            )
          else if (portfolio.error != null)
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Text(portfolio.error!),
              ),
            )
          else
            SliverList(
              delegate: SliverChildBuilderDelegate(
                (context, index) {
                  final item = portfolio.items[index];
                  return Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                    child: Card(
                      child: ListTile(
                        leading: CircleAvatar(
                          backgroundColor: AppConstants.primaryColor.withValues(alpha: 0.12),
                          child: Icon(Icons.school_outlined, color: AppConstants.primaryColor),
                        ),
                        title: Text(item.title),
                        subtitle: Text(
                          '${item.category} · ${DateFormat('dd.MM.yyyy').format(item.date)}',
                        ),
                        trailing: Text(
                          item.status,
                          style: TextStyle(
                            color: AppConstants.primaryColor,
                            fontWeight: FontWeight.w600,
                            fontSize: 12,
                          ),
                        ),
                      ),
                    ),
                  );
                },
                childCount: portfolio.items.length,
              ),
            ),
          const SliverToBoxAdapter(child: SizedBox(height: 88)),
        ],
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Container(
      width: double.infinity,
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Color(0xFF3EC9C0),
            Color(0xFF2AAB9F),
            Color(0xFF1F8A82),
          ],
        ),
      ),
      child: SafeArea(
        bottom: false,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Image.asset(
                    'assets/images/app_icon.png',
                    width: 40,
                    height: 40,
                    errorBuilder: (context, error, stackTrace) =>
                        const Icon(Icons.apps, color: Colors.white, size: 36),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      AppConstants.appName,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 20,
                        fontWeight: FontWeight.w800,
                        letterSpacing: -0.5,
                      ),
                    ),
                  ),
                  IconButton(
                    onPressed: () {},
                    icon: const Icon(Icons.search, color: Colors.white),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              TextField(
                readOnly: true,
                onTap: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Поиск появится после подключения каталога')),
                  );
                },
                decoration: InputDecoration(
                  hintText: 'Поиск',
                  prefixIcon: const Icon(Icons.search, color: Color(0xFF8A96A8)),
                  filled: true,
                  fillColor: Colors.white,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(14),
                    borderSide: BorderSide.none,
                  ),
                  contentPadding: const EdgeInsets.symmetric(vertical: 12),
                ),
              ),
              const SizedBox(height: 16),
              SizedBox(
                height: 148,
                child: PageView.builder(
                  controller: _bannerController,
                  itemCount: 3,
                  itemBuilder: (context, i) {
                    final banners = [
                      (
                        'Сервисы ТГПУ',
                        'Расписание, оценки и справки в одном приложении',
                        'Подробнее',
                      ),
                      (
                        'Партнёры вуза',
                        'Скидки и точки на карте — персонально для студента',
                        'К карте',
                      ),
                      (
                        'Портфолио',
                        'Учебный план и достижения в разделе ниже',
                        'Смотреть',
                      ),
                    ];
                    final b = banners[i];
                    return Padding(
                      padding: const EdgeInsets.only(right: 10),
                      child: Card(
                        color: Colors.white,
                        child: Padding(
                          padding: const EdgeInsets.all(16),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                b.$1,
                                style: const TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.w800,
                                ),
                              ),
                              const SizedBox(height: 8),
                              Expanded(
                                child: Text(
                                  b.$2,
                                  style: TextStyle(
                                    fontSize: 14,
                                    color: Colors.grey[700],
                                    height: 1.35,
                                  ),
                                ),
                              ),
                              const SizedBox(height: 8),
                              SizedBox(
                                width: double.infinity,
                                child: FilledButton(
                                  onPressed: () {
                                    if (i == 1) _scrollTo(_mapKey);
                                    if (i == 2) _scrollTo(_portfolioKey);
                                    if (i == 0) {
                                      ScaffoldMessenger.of(context).showSnackBar(
                                        const SnackBar(content: Text('Раздел в разработке')),
                                      );
                                    }
                                  },
                                  child: Text(b.$3),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildQuickActions(BuildContext context) {
    final actions = [
      (Icons.folder_special_outlined, 'Портфолио', () => _scrollTo(_portfolioKey)),
      (Icons.map_outlined, 'Карта', () => _scrollTo(_mapKey)),
      (Icons.description_outlined, 'Справки', () {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Заказ справок — после интеграции с 1С')),
        );
      }),
      (Icons.apps_outlined, 'Сервисы', () {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Каталог сервисов вуза — в roadmap')),
        );
      }),
    ];
    return Transform.translate(
      offset: const Offset(0, -18),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        child: Card(
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 8),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: actions.map((a) {
                return InkWell(
                  onTap: a.$3,
                  borderRadius: BorderRadius.circular(12),
                  child: SizedBox(
                    width: 76,
                    child: Column(
                      children: [
                        Container(
                          width: 48,
                          height: 48,
                          decoration: BoxDecoration(
                            color: AppConstants.primaryColor.withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(14),
                          ),
                          child: Icon(a.$1, color: AppConstants.primaryColor),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          a.$2,
                          textAlign: TextAlign.center,
                          style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w600),
                          maxLines: 2,
                        ),
                      ],
                    ),
                  ),
                );
              }).toList(),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildMapBlock(BuildContext context) {
    final sp = context.watch<StudentProvider>();
    final student = sp.student;
    final showMap = _showPartnerMap(sp);
    final email = student?.email ?? 'ваш профиль';

    if (!showMap) {
      return Card(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(Icons.map_outlined, color: AppConstants.primaryColor, size: 28),
                  const SizedBox(width: 10),
                  const Expanded(
                    child: Text(
                      'Карта партнёров ТГПУ',
                      style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Text(
                'Персональная карта с партнёрами и предложениями доступна после регистрации на портале университета и синхронизации с профилем.',
                style: TextStyle(color: Colors.grey[700], height: 1.4),
              ),
              const SizedBox(height: 16),
              FilledButton(
                onPressed: _openPortal,
                child: const Text('Зарегистрироваться на портале'),
              ),
              const SizedBox(height: 10),
              OutlinedButton(
                onPressed: () => _setLocalMapUnlock(true),
                child: const Text('Уже зарегистрирован — показать демо-карту'),
              ),
            ],
          ),
        ),
      );
    }

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Карта партнёров',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: AppConstants.accentYellow.withValues(alpha: 0.5),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Text(
                    'Демо',
                    style: TextStyle(fontSize: 11, fontWeight: FontWeight.w700),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 4),
            Text(
              'Привязка к профилю: $email',
              style: TextStyle(fontSize: 13, color: Colors.grey[600]),
            ),
            const SizedBox(height: 8),
            Text(
              'Точки генерируются локально до подключения API карт.',
              style: TextStyle(fontSize: 12, color: Colors.grey[500]),
            ),
            const SizedBox(height: 12),
            ClipRRect(
              borderRadius: BorderRadius.circular(16),
              child: SizedBox(
                height: 220,
                child: _PartnerMapMock(seed: email.hashCode),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _linkEmailCard(BuildContext context) {
    return Card(
      child: ExpansionTile(
        tilePadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
        childrenPadding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
        leading: Icon(Icons.link, color: AppConstants.primaryColor),
        title: const Text(
          'Другая почта в личном кабинете?',
          style: TextStyle(fontWeight: FontWeight.w700, fontSize: 15),
        ),
        subtitle: const Text(
          'Привяжите аккаунт, если студентский профиль заведён на другой email',
          style: TextStyle(fontSize: 12),
        ),
        children: [
          const Text(
            'После запуска API вы сможете подтвердить владение почтой кодом. Сейчас — демонстрация интерфейса.',
            style: TextStyle(fontSize: 13, height: 1.35),
          ),
          const SizedBox(height: 12),
          _LinkEmailForm(),
        ],
      ),
    );
  }
}

class _LinkEmailForm extends StatefulWidget {
  @override
  State<_LinkEmailForm> createState() => _LinkEmailFormState();
}

class _LinkEmailFormState extends State<_LinkEmailForm> {
  final _email = TextEditingController();

  @override
  void dispose() {
    _email.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        TextField(
          controller: _email,
          keyboardType: TextInputType.emailAddress,
          decoration: const InputDecoration(
            hintText: 'Email из личного кабинета',
            labelText: 'Email для привязки',
          ),
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: OutlinedButton(
                onPressed: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Код отправлен (демо). Реальная отправка — после API.'),
                    ),
                  );
                },
                child: const Text('Отправить код'),
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: FilledButton(
                onPressed: () {
                  if (_email.text.trim().isEmpty) return;
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Запрос на привязку ${_email.text.trim()} принят (демо)')),
                  );
                },
                child: const Text('Подтвердить'),
              ),
            ),
          ],
        ),
      ],
    );
  }
}

class _PartnerMapMock extends StatelessWidget {
  const _PartnerMapMock({required this.seed});

  final int seed;

  @override
  Widget build(BuildContext context) {
    final rnd = seed.abs();
    final partners = [
      ('Библиотека ТГПУ', const Color(0xFF5C6BC0)),
      ('Спорткомплекс', const Color(0xFF26A69A)),
      ('Столовая', const Color(0xFFFFA726)),
      ('ИПИТ', const Color(0xFFAB47BC)),
    ];

    return LayoutBuilder(
      builder: (context, constraints) {
        final w = constraints.maxWidth;
        final h = constraints.maxHeight;
        return Stack(
          fit: StackFit.expand,
          children: [
            DecoratedBox(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    const Color(0xFFE3F2FD),
                    const Color(0xFFBBDEFB).withValues(alpha: 0.6),
                  ],
                ),
              ),
            ),
            CustomPaint(painter: _GridPainter()),
            ...List.generate(partners.length, (i) {
              final left = 0.08 + ((rnd + i * 17) % 55) / 100.0;
              final top = 0.12 + ((rnd + i * 31) % 50) / 100.0;
              return Positioned(
                left: w * left,
                top: h * top,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.place, color: partners[i].$2, size: 32),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(6),
                        boxShadow: const [
                          BoxShadow(color: Color(0x22000000), blurRadius: 4),
                        ],
                      ),
                      child: Text(
                        partners[i].$1,
                        style: const TextStyle(fontSize: 10, fontWeight: FontWeight.w600),
                      ),
                    ),
                  ],
                ),
              );
            }),
          ],
        );
      },
    );
  }
}

class _GridPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final p = Paint()
      ..color = const Color(0x33000000)
      ..strokeWidth = 0.5;
    const step = 28.0;
    for (double x = 0; x < size.width; x += step) {
      canvas.drawLine(Offset(x, 0), Offset(x, size.height), p);
    }
    for (double y = 0; y < size.height; y += step) {
      canvas.drawLine(Offset(0, y), Offset(size.width, y), p);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
