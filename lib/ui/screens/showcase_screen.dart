import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';
import 'package:provider/provider.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../core/constants.dart';
import '../../core/providers/main_nav_provider.dart';
import '../../core/providers/partner_services_provider.dart';
import '../../core/providers/student_provider.dart';
import '../../data/models/partner_service_item.dart';
import 'partner_qr_scan_screen.dart';

/// Витрина: сервисы, партнёрские услуги (QR), портфолио.
class ShowcaseScreen extends StatefulWidget {
  const ShowcaseScreen({super.key});

  @override
  State<ShowcaseScreen> createState() => _ShowcaseScreenState();
}

class _ShowcaseScreenState extends State<ShowcaseScreen> {
  final PageController _bannerController = PageController(viewportFraction: 0.86);
  final ScrollController _scroll = ScrollController();
  final GlobalKey _partnerKey = GlobalKey();

  Future<void> _openUrl(String url) async {
    final uri = Uri.parse(url);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    }
  }

  void _scrollTo(GlobalKey key) {
    final ctx = key.currentContext;
    if (ctx != null) {
      Scrollable.ensureVisible(
        ctx,
        duration: const Duration(milliseconds: 450),
        curve: Curves.easeOutCubic,
        alignment: 0.15,
      );
    }
  }

  void _goTab(int index) => context.read<MainNavProvider>().setTab(index);

  void _openScanner(BuildContext context) {
    if (defaultTargetPlatform == TargetPlatform.android ||
        defaultTargetPlatform == TargetPlatform.iOS) {
      Navigator.of(context).push<void>(
        MaterialPageRoute<void>(builder: (_) => const PartnerQrScanScreen()),
      );
    } else {
      _showManualQrDialog(context);
    }
  }

  void _showManualQrDialog(BuildContext context) {
    final controller = TextEditingController();
    showDialog<void>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: const Text('Код из QR'),
          content: TextField(
            controller: controller,
            decoration: const InputDecoration(
              hintText: 'Вставьте строку из QR (как на телефоне)',
            ),
            maxLines: 3,
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogContext),
              child: const Text('Отмена'),
            ),
            FilledButton(
              onPressed: () async {
                final text = controller.text.trim();
                if (text.isEmpty) return;
                Navigator.pop(dialogContext);
                try {
                  await context.read<PartnerServicesProvider>().registerScan(text);
                } catch (e) {
                  if (context.mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('$e')));
                  }
                }
              },
              child: const Text('Отправить на платформу'),
            ),
          ],
        );
      },
    );
  }

  void _openSearch() {
    showSearch<void>(
      context: context,
      delegate: _ShowcaseSearchDelegate(
        onSchedule: () => _goTab(1),
        onHome: () => _goTab(0),
        onOpenPortfolio: () => context.read<MainNavProvider>().goToProfilePortfolioTab(),
        onScrollPartner: () => _scrollTo(_partnerKey),
        onServices: () => _openServicesSheet(context),
        onCertificates: () => _openCertificatesSheet(context),
      ),
    );
  }

  void _openServicesSheet(BuildContext ctx) {
    showModalBottomSheet<void>(
      context: ctx,
      backgroundColor: AppConstants.surfaceWhite,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (c) {
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(8, 8, 8, 16),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const Padding(
                  padding: EdgeInsets.all(12),
                  child: Text(
                    'Сервисы',
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.w800),
                  ),
                ),
                ListTile(
                  leading: Icon(PhosphorIconsRegular.globe, color: AppConstants.terracotta),
                  title: const Text('Сайт ТГПУ'),
                  subtitle: Text(AppConstants.portalRegisterUrl, style: TextStyle(fontSize: 12, color: Colors.grey[600])),
                  onTap: () {
                    Navigator.pop(c);
                    _openUrl(AppConstants.portalRegisterUrl);
                  },
                ),
                ListTile(
                  leading: Icon(PhosphorIconsRegular.graduationCap, color: AppConstants.terracotta),
                  title: const Text('Электронное обучение'),
                  subtitle: Text(AppConstants.portalStudyUrl, style: TextStyle(fontSize: 12, color: Colors.grey[600])),
                  onTap: () {
                    Navigator.pop(c);
                    _openUrl(AppConstants.portalStudyUrl);
                  },
                ),
                ListTile(
                  leading: Icon(PhosphorIconsRegular.calendarBlank, color: AppConstants.terracotta),
                  title: const Text('Расписание в приложении'),
                  onTap: () {
                    Navigator.pop(c);
                    _goTab(1);
                  },
                ),
                ListTile(
                  leading: Icon(PhosphorIconsRegular.house, color: AppConstants.terracotta),
                  title: const Text('Главная'),
                  onTap: () {
                    Navigator.pop(c);
                    _goTab(0);
                  },
                ),
                ListTile(
                  leading: Icon(PhosphorIconsRegular.user, color: AppConstants.terracotta),
                  title: const Text('Профиль'),
                  onTap: () {
                    Navigator.pop(c);
                    _goTab(3);
                  },
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  void _openCertificatesSheet(BuildContext ctx) {
    showModalBottomSheet<void>(
      context: ctx,
      backgroundColor: AppConstants.surfaceWhite,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (c) {
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(8, 8, 8, 24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const Padding(
                  padding: EdgeInsets.all(12),
                  child: Text(
                    'Справки и документы',
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.w800),
                  ),
                ),
                ListTile(
                  leading: Icon(PhosphorIconsRegular.fileText, color: AppConstants.terracotta),
                  title: const Text('Справка об обучении'),
                  subtitle: const Text('Заказ через интеграцию с 1С / деканатом'),
                  onTap: () {
                    Navigator.pop(c);
                    _openUrl(AppConstants.portalRegisterUrl);
                  },
                ),
                ListTile(
                  leading: Icon(PhosphorIconsRegular.scroll, color: AppConstants.terracotta),
                  title: const Text('Транскрипт / академическая справка'),
                  onTap: () {
                    Navigator.pop(c);
                    _openUrl(AppConstants.portalStudyUrl);
                  },
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  @override
  void dispose() {
    _bannerController.dispose();
    _scroll.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final partners = context.watch<PartnerServicesProvider>();

    return Scaffold(
      backgroundColor: AppConstants.surfaceWhite,
      body: RefreshIndicator(
        color: AppConstants.terracotta,
        onRefresh: () async {
          await context.read<StudentProvider>().loadStudentData();
          if (!context.mounted) return;
          await context.read<PartnerServicesProvider>().loadServices();
        },
        child: CustomScrollView(
          controller: _scroll,
          physics: const AlwaysScrollableScrollPhysics(),
          slivers: [
            SliverToBoxAdapter(child: _buildHeader(context)),
            SliverToBoxAdapter(child: _buildQuickActions(context)),
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(20, 28, 20, 12),
                child: KeyedSubtree(
                  key: _partnerKey,
                  child: _buildPartnerServicesBlock(context, partners),
                ),
              ),
            ),
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(20, 12, 20, 20),
                child: _linkEmailCard(context),
              ),
            ),
            const SliverToBoxAdapter(child: SizedBox(height: 100)),
          ],
        ),
      ),
    );
  }

  Widget _buildPartnerServicesBlock(BuildContext context, PartnerServicesProvider partners) {
    final student = context.watch<StudentProvider>().student;
    final payload = student == null
        ? 'TSPUT|pending'
        : 'TSPUT|STUDENT|${student.id}|${student.group}|${student.fullName}';

    return Container(
      decoration: BoxDecoration(
        color: AppConstants.surfaceWhite,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppConstants.borderSubtle),
      ),
      padding: const EdgeInsets.all(22),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(PhosphorIconsRegular.identificationCard, color: AppConstants.terracotta, size: 28),
              const SizedBox(width: 12),
              const Expanded(
                child: Text(
                  'Карта лояльности',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Text(
            'Покажите этот экран сотруднику партнёра для сканирования. Код привязан к вашему профилю (данные 1С).',
            style: TextStyle(color: AppConstants.secondaryColor, height: 1.45, fontSize: 14),
          ),
          const SizedBox(height: 20),
          Center(
            child: Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppConstants.surfaceWhite,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: AppConstants.borderSubtle, width: 2),
              ),
              child: QrImageView(
                data: payload,
                version: QrVersions.auto,
                size: 200,
                eyeStyle: const QrEyeStyle(eyeShape: QrEyeShape.square, color: AppConstants.blockBlack),
                dataModuleStyle: const QrDataModuleStyle(dataModuleShape: QrDataModuleShape.square, color: AppConstants.blockBlack),
                backgroundColor: AppConstants.surfaceWhite,
              ),
            ),
          ),
          if (student != null) ...[
            const SizedBox(height: 12),
            Text(
              '${student.fullName} · ${student.group}',
              textAlign: TextAlign.center,
              style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 14),
            ),
          ],
          const SizedBox(height: 16),
          Text(
            'Активированные услуги',
            style: TextStyle(fontWeight: FontWeight.w800, fontSize: 15, color: AppConstants.blockBlack),
          ),
          const SizedBox(height: 8),
          if (partners.isLoading)
            const Center(child: Padding(padding: EdgeInsets.all(16), child: CircularProgressIndicator(color: AppConstants.terracotta)))
          else if (partners.error != null)
            Text(partners.error!, style: TextStyle(color: Colors.red[800], fontSize: 13))
          else if (partners.items.isEmpty)
            Text(
              'Список пуст. Если на точке нужно отсканировать код акции — используйте кнопку ниже.',
              style: TextStyle(color: AppConstants.secondaryColor, fontSize: 13),
            )
          else
            Column(children: partners.items.map((e) => _partnerTile(e)).toList()),
          const SizedBox(height: 12),
          SizedBox(
            width: double.infinity,
            child: OutlinedButton.icon(
              onPressed: () => _openScanner(context),
              icon: const Icon(PhosphorIconsRegular.camera),
              label: const Text('Сканировать код на точке (акция)'),
            ),
          ),
          if (defaultTargetPlatform != TargetPlatform.android && defaultTargetPlatform != TargetPlatform.iOS)
            Padding(
              padding: const EdgeInsets.only(top: 8),
              child: Text(
                'На ПК доступен ввод строки из QR вручную.',
                style: TextStyle(fontSize: 12, color: AppConstants.secondaryColor),
              ),
            ),
        ],
      ),
    );
  }

  Widget _partnerTile(PartnerServiceItem e) {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppConstants.surfaceMuted,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: const Color(0xFFE8E8E6)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(e.title, style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 15)),
          const SizedBox(height: 4),
          Text(e.partnerName, style: TextStyle(color: Colors.grey[700], fontSize: 13)),
          if (e.description.isNotEmpty) ...[
            const SizedBox(height: 6),
            Text(e.description, style: TextStyle(color: Colors.grey[600], fontSize: 12)),
          ],
          if (e.validUntil != null)
            Text(
              'До ${DateFormat('dd.MM.yyyy').format(e.validUntil!)}',
              style: const TextStyle(fontSize: 11, color: AppConstants.terracottaDark, fontWeight: FontWeight.w600),
            ),
        ],
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return SafeArea(
      bottom: false,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(20, 16, 12, 32),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Image.asset(
                  'assets/images/app_icon.png',
                  width: 44,
                  height: 44,
                  errorBuilder: (context, error, stackTrace) =>
                      Icon(PhosphorIconsRegular.graduationCap, size: 40, color: AppConstants.terracotta),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    AppConstants.appName,
                    style: const TextStyle(
                      color: AppConstants.blockBlack,
                      fontSize: 22,
                      fontWeight: FontWeight.w800,
                      letterSpacing: -0.5,
                    ),
                  ),
                ),
                IconButton(
                  onPressed: _openSearch,
                  icon: Icon(PhosphorIconsRegular.magnifyingGlass, color: AppConstants.terracotta, size: 26),
                ),
              ],
            ),
            const SizedBox(height: 24),
            TextField(
              readOnly: true,
              onTap: _openSearch,
              decoration: InputDecoration(
                hintText: 'Поиск по разделам и сервисам',
                hintStyle: TextStyle(color: Colors.grey[500], fontSize: 15),
                prefixIcon: Icon(PhosphorIconsRegular.magnifyingGlass, color: Colors.grey[500]),
                filled: true,
                fillColor: AppConstants.surfaceMuted,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(16),
                  borderSide: BorderSide.none,
                ),
                contentPadding: const EdgeInsets.symmetric(vertical: 16, horizontal: 8),
              ),
            ),
            const SizedBox(height: 28),
            SizedBox(
              height: 168,
              child: PageView.builder(
                controller: _bannerController,
                itemCount: 3,
                itemBuilder: (context, i) {
                  final banners = [
                    (
                      'Сервисы ТГПУ',
                      'Расписание, обучение и разделы приложения.',
                      'Открыть',
                      () => _openServicesSheet(context),
                    ),
                    (
                      'Карта лояльности',
                      'Покажите QR сотруднику партнёра.',
                      'К карте',
                      () => _scrollTo(_partnerKey),
                    ),
                    (
                      'Портфолио',
                      'Разделы учебного плана — в профиле, как на сайте.',
                      'Открыть',
                      () => context.read<MainNavProvider>().goToProfilePortfolioTab(),
                    ),
                  ];
                  final b = banners[i];
                  return Padding(
                    padding: const EdgeInsets.only(right: 12),
                    child: Container(
                      decoration: BoxDecoration(
                        color: AppConstants.blockBlack,
                        borderRadius: BorderRadius.circular(20),
                      ),
                      padding: const EdgeInsets.all(22),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            b.$1,
                            style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.w800,
                              color: AppConstants.onBlock,
                            ),
                          ),
                          const SizedBox(height: 12),
                          Expanded(
                            child: Text(
                              b.$2,
                              style: const TextStyle(
                                fontSize: 14,
                                color: AppConstants.onBlockSecondary,
                                height: 1.45,
                              ),
                            ),
                          ),
                          const SizedBox(height: 12),
                          SizedBox(
                            width: double.infinity,
                            child: FilledButton(
                              style: FilledButton.styleFrom(
                                backgroundColor: AppConstants.terracotta,
                                foregroundColor: AppConstants.surfaceWhite,
                              ),
                              onPressed: b.$4,
                              child: Text(b.$3),
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildQuickActions(BuildContext context) {
    final actions = <(IconData, String, VoidCallback)>[
      (PhosphorIconsRegular.student, 'Портфолио', () => context.read<MainNavProvider>().goToProfilePortfolioTab()),
      (PhosphorIconsRegular.identificationCard, 'Карта', () => _scrollTo(_partnerKey)),
      (PhosphorIconsRegular.fileText, 'Справки', () => _openCertificatesSheet(context)),
      (PhosphorIconsRegular.squaresFour, 'Сервисы', () => _openServicesSheet(context)),
    ];
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 0, 20, 8),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 22, horizontal: 10),
        decoration: BoxDecoration(
          color: AppConstants.surfaceWhite,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: const Color(0xFFE8E8E6)),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: actions.map((a) {
            return Expanded(
              child: InkWell(
                onTap: a.$3,
                borderRadius: BorderRadius.circular(14),
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 6),
                  child: Column(
                    children: [
                      Container(
                        width: 52,
                        height: 52,
                        decoration: BoxDecoration(
                          color: AppConstants.terracottaMuted,
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: Icon(a.$1, color: AppConstants.terracottaDark, size: 26),
                      ),
                      const SizedBox(height: 10),
                      Text(
                        a.$2,
                        textAlign: TextAlign.center,
                        style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w700),
                        maxLines: 2,
                      ),
                    ],
                  ),
                ),
              ),
            );
          }).toList(),
        ),
      ),
    );
  }

  Widget _linkEmailCard(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppConstants.surfaceWhite,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0xFFE8E8E6)),
      ),
      child: Theme(
        data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
        child: ExpansionTile(
          tilePadding: const EdgeInsets.symmetric(horizontal: 18, vertical: 8),
          childrenPadding: const EdgeInsets.fromLTRB(18, 0, 18, 20),
          leading: Icon(PhosphorIconsRegular.linkSimple, color: AppConstants.terracotta),
          title: const Text(
            'Другая почта в личном кабинете?',
            style: TextStyle(fontWeight: FontWeight.w700, fontSize: 15),
          ),
          subtitle: const Text(
            'Привяжите аккаунт, если профиль на другой email',
            style: TextStyle(fontSize: 12),
          ),
          children: const [
            _LinkEmailForm(),
          ],
        ),
      ),
    );
  }
}

class _LinkEmailForm extends StatefulWidget {
  const _LinkEmailForm();

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
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(
          'Подтверждение почты выполняется через API интеграции с порталом вуза.',
          style: TextStyle(fontSize: 13, height: 1.4, color: Colors.grey[700]),
        ),
        const SizedBox(height: 14),
        TextField(
          controller: _email,
          keyboardType: TextInputType.emailAddress,
          decoration: const InputDecoration(
            hintText: 'Email из личного кабинета',
            labelText: 'Email для привязки',
          ),
        ),
        const SizedBox(height: 14),
        Row(
          children: [
            Expanded(
              child: OutlinedButton(
                onPressed: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Запрос кода — после подключения endpoint привязки на бэкенде.')),
                  );
                },
                child: const Text('Отправить код'),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: FilledButton(
                onPressed: () {
                  if (_email.text.trim().isEmpty) return;
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Привязка ${_email.text.trim()} — ожидает API.')),
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

class _ShowcaseSearchDelegate extends SearchDelegate<void> {
  _ShowcaseSearchDelegate({
    required this.onSchedule,
    required this.onHome,
    required this.onOpenPortfolio,
    required this.onScrollPartner,
    required this.onServices,
    required this.onCertificates,
  });

  final VoidCallback onSchedule;
  final VoidCallback onHome;
  final VoidCallback onOpenPortfolio;
  final VoidCallback onScrollPartner;
  final VoidCallback onServices;
  final VoidCallback onCertificates;

  @override
  List<Widget>? buildActions(BuildContext context) {
    if (query.isEmpty) return null;
    return [
      IconButton(
        onPressed: () => query = '',
        icon: Icon(PhosphorIconsRegular.x, color: AppConstants.blockBlack),
      ),
    ];
  }

  @override
  Widget? buildLeading(BuildContext context) {
    return IconButton(
      onPressed: () => close(context, null),
      icon: Icon(PhosphorIconsRegular.caretLeft, color: AppConstants.blockBlack),
    );
  }

  @override
  Widget buildResults(BuildContext context) => _buildList(context);

  @override
  Widget buildSuggestions(BuildContext context) => _buildList(context);

  Widget _buildList(BuildContext context) {
    final q = query.trim().toLowerCase();
    final items = <_SearchHit>[
      _SearchHit('Расписание', 'Открыть вкладку с занятиями', PhosphorIconsRegular.calendarBlank, onSchedule),
      _SearchHit('Главная', 'Сводка, оценки, расписание дня', PhosphorIconsRegular.house, onHome),
      _SearchHit('Портфолио', 'Вкладка в профиле', PhosphorIconsRegular.student, onOpenPortfolio),
      _SearchHit('Карта лояльности', 'QR для показа партнёру', PhosphorIconsRegular.identificationCard, onScrollPartner),
      _SearchHit('Сервисы', 'Сайт, LMS, разделы', PhosphorIconsRegular.squaresFour, onServices),
      _SearchHit('Справки', 'Документы и портал', PhosphorIconsRegular.fileText, onCertificates),
    ];

    final filtered = q.isEmpty
        ? items
        : items
            .where((e) => e.title.toLowerCase().contains(q) || e.subtitle.toLowerCase().contains(q))
            .toList();

    return ListView(
      padding: const EdgeInsets.symmetric(vertical: 8),
      children: [
        for (final hit in filtered)
          ListTile(
            leading: Icon(hit.icon, color: AppConstants.terracotta),
            title: Text(hit.title),
            subtitle: Text(hit.subtitle, style: TextStyle(fontSize: 12, color: Colors.grey[600])),
            onTap: () {
              close(context, null);
              hit.onTap();
            },
          ),
      ],
    );
  }
}

class _SearchHit {
  _SearchHit(this.title, this.subtitle, this.icon, this.onTap);
  final String title;
  final String subtitle;
  final IconData icon;
  final VoidCallback onTap;
}
