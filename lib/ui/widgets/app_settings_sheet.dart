import 'package:flutter/material.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../core/constants.dart';
import '../../core/providers/auth_provider.dart';
import '../../core/providers/student_provider.dart';
import '../auth/login_screen.dart';
import 'sheet_handle.dart';

Future<void> showAppSettingsSheet(BuildContext context) async {
  await showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder: (ctx) {
      return DraggableScrollableSheet(
        initialChildSize: 0.72,
        minChildSize: 0.45,
        maxChildSize: 0.92,
        expand: false,
        builder: (_, scrollController) {
          return Container(
            decoration: const BoxDecoration(
              color: AppConstants.surfaceWhite,
              borderRadius: BorderRadius.vertical(top: Radius.circular(AppConstants.sheetTopRadius)),
            ),
            child: ListView(
              controller: scrollController,
              padding: const EdgeInsets.fromLTRB(8, 8, 8, 24),
              children: [
                const SheetGrabHandle(),
                const Padding(
                  padding: EdgeInsets.fromLTRB(16, 20, 16, 8),
                  child: Text(
                    'Настройки',
                    style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.w800,
                      color: AppConstants.blockBlack,
                    ),
                  ),
                ),
                FutureBuilder<PackageInfo>(
                  future: PackageInfo.fromPlatform(),
                  builder: (context, snapshot) {
                    final v = snapshot.data;
                    return ListTile(
                      leading: Icon(PhosphorIconsRegular.info, color: AppConstants.terracotta),
                      title: const Text('О приложении'),
                      subtitle: Text(
                        v == null ? 'Загрузка…' : 'Версия ${v.version} (${v.buildNumber})',
                        style: TextStyle(color: Colors.grey[600], fontSize: 13),
                      ),
                    );
                  },
                ),
                ListTile(
                  leading: Icon(PhosphorIconsRegular.arrowsClockwise, color: AppConstants.terracotta),
                  title: const Text('Проверить обновления'),
                  subtitle: const Text(
                    'Сравнение с каталогом магазина появится после публикации',
                    style: TextStyle(fontSize: 12),
                  ),
                  onTap: () async {
                    final info = await PackageInfo.fromPlatform();
                    if (!ctx.mounted) return;
                    Navigator.pop(ctx);
                    if (!context.mounted) return;
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(
                          'Установлена версия ${info.version}+${info.buildNumber}. Обновлений из магазина пока не проверяем (демо).',
                        ),
                      ),
                    );
                  },
                ),
                const Divider(height: 1),
                ListTile(
                  leading: Icon(PhosphorIconsRegular.globe, color: AppConstants.terracotta),
                  title: const Text('Сайт ТГПУ'),
                  subtitle: Text(AppConstants.portalRegisterUrl, style: TextStyle(fontSize: 12, color: Colors.grey[600])),
                  onTap: () async {
                    final uri = Uri.parse(AppConstants.portalRegisterUrl);
                    if (await canLaunchUrl(uri)) {
                      await launchUrl(uri, mode: LaunchMode.externalApplication);
                    }
                  },
                ),
                ListTile(
                  leading: Icon(PhosphorIconsRegular.graduationCap, color: AppConstants.terracotta),
                  title: const Text('Электронное обучение'),
                  subtitle: Text(AppConstants.portalStudyUrl, style: TextStyle(fontSize: 12, color: Colors.grey[600])),
                  onTap: () async {
                    final uri = Uri.parse(AppConstants.portalStudyUrl);
                    if (await canLaunchUrl(uri)) {
                      await launchUrl(uri, mode: LaunchMode.externalApplication);
                    }
                  },
                ),
                const Divider(height: 1),
                ListTile(
                  leading: Icon(PhosphorIconsRegular.signOut, color: const Color(0xFFB91C1C)),
                  title: const Text('Выйти из аккаунта', style: TextStyle(color: Color(0xFFB91C1C), fontWeight: FontWeight.w600)),
                  onTap: () {
                    Navigator.pop(ctx);
                    _showLogoutConfirmation(context);
                  },
                ),
                const SizedBox(height: 8),
                Center(
                  child: TextButton(
                    onPressed: () => Navigator.pop(ctx),
                    child: const Text('Закрыть'),
                  ),
                ),
              ],
            ),
          );
        },
      );
    },
  );
}

void _showLogoutConfirmation(BuildContext context) {
  showDialog<void>(
    context: context,
    builder: (BuildContext dialogContext) {
      return AlertDialog(
        title: const Text('Выход'),
        content: const Text('Выйти из аккаунта?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(),
            child: Text('Отмена', style: TextStyle(color: Colors.grey[700])),
          ),
          TextButton(
            onPressed: () => _logout(context, dialogContext),
            child: const Text('Выйти', style: TextStyle(color: Color(0xFFB91C1C))),
          ),
        ],
      );
    },
  );
}

Future<void> _logout(BuildContext context, BuildContext dialogContext) async {
  Navigator.of(dialogContext).pop();

  final auth = context.read<AuthProvider>();
  final student = context.read<StudentProvider>();
  await auth.logout();
  student.clearStudentData();

  if (!context.mounted) return;
  final nav = Navigator.of(context);
  nav.pushAndRemoveUntil(
    MaterialPageRoute<void>(builder: (ctx) => LoginScreen()),
    (route) => false,
  );
}
