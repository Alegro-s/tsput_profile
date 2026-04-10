import 'package:flutter/material.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';
import 'package:provider/provider.dart';
import '../../core/constants.dart';
import '../../core/integration_runtime.dart';
import '../../core/providers/auth_provider.dart';
import '../../core/providers/student_provider.dart';

class LoginScreen extends StatefulWidget {
  final VoidCallback? onLoginSuccess;

  const LoginScreen({super.key, this.onLoginSuccess});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _loginController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _rememberMe = true;
  bool _obscurePassword = true;

  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    _loginController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = context.watch<AuthProvider>();

    return Scaffold(
      backgroundColor: AppConstants.backgroundColor,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            children: [
              const SizedBox(height: 48),
              Image.asset(
                'assets/images/app_icon.png',
                width: 88,
                height: 88,
                errorBuilder: (context, error, stackTrace) => Icon(
                  PhosphorIconsRegular.graduationCap,
                  size: 72,
                  color: AppConstants.terracotta,
                ),
              ),
              const SizedBox(height: 20),
              Text(
                AppConstants.appName,
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.w800,
                      letterSpacing: -0.5,
                    ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 8),
              Text(
                'Вход по данным электронного обучения (Moodle)',
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: AppConstants.secondaryColor,
                    ),
                textAlign: TextAlign.center,
              ),

              const SizedBox(height: 16),
              Material(
                color: AppConstants.surfaceMuted,
                borderRadius: BorderRadius.circular(AppConstants.cardRadius),
                child: InkWell(
                  onTap: () => _showServerUrlDialog(context),
                  borderRadius: BorderRadius.circular(AppConstants.cardRadius),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                    child: Row(
                      children: [
                        Icon(PhosphorIconsRegular.globe, color: AppConstants.terracotta, size: 22),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                'Адрес сервера API',
                                style: TextStyle(fontWeight: FontWeight.w700, fontSize: 13),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                AppConstants.integrationBaseUrl,
                                style: TextStyle(
                                  fontSize: 12,
                                  color: AppConstants.secondaryColor,
                                ),
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ],
                          ),
                        ),
                        Icon(PhosphorIconsRegular.caretRight, color: AppConstants.secondaryColor, size: 18),
                      ],
                    ),
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(top: 6),
                child: Text(
                  'Если «нет подключения» — нажмите сюда и введите http://72.56.244.26:8080 (ваш VPS, порт API).',
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 11, height: 1.35, color: AppConstants.secondaryColor),
                ),
              ),

              const SizedBox(height: 24),
              // Форма входа
              Form(
                key: _formKey,
                child: Column(
                  children: [
                    // Поле логина
                    _buildTextField(
                      context,
                      controller: _loginController,
                      label: 'Логин',
                      hintText: 'ID в Moodle, почта или ФИО',
                      prefixIcon: PhosphorIconsRegular.user,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Введите логин';
                        }
                        return null;
                      },
                    ),

                    const SizedBox(height: 16),

                    // Поле пароля
                    _buildTextField(
                      context,
                      controller: _passwordController,
                      label: 'Пароль',
                      hintText: 'Пароль от Moodle',
                      prefixIcon: PhosphorIconsRegular.lock,
                      obscureText: _obscurePassword,
                      suffixIcon: IconButton(
                        icon: Icon(
                          _obscurePassword ? PhosphorIconsRegular.eye : PhosphorIconsRegular.eyeSlash,
                          color: Colors.grey,
                        ),
                        onPressed: () {
                          setState(() {
                            _obscurePassword = !_obscurePassword;
                          });
                        },
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Введите пароль';
                        }
                        return null;
                      },
                    ),

                    const SizedBox(height: 16),

                    // Запомнить меня
                    Row(
                      children: [
                        Checkbox(
                          value: _rememberMe,
                          onChanged: (value) {
                            setState(() {
                              _rememberMe = value ?? false;
                            });
                          },
                          activeColor: AppConstants.primaryColor,
                        ),
                        Text(
                          'Запомнить меня',
                          style: Theme.of(context).textTheme.bodyMedium,
                        ),
                        const Spacer(),
                      ],
                    ),

                    const SizedBox(height: 24),

                    // Кнопка входа
                    SizedBox(
                      width: double.infinity,
                      height: AppConstants.buttonHeight,
                      child: FilledButton(
                        onPressed: authProvider.isLoading ? null : () => _login(context),
                        child: authProvider.isLoading
                            ? const SizedBox(
                                width: 22,
                                height: 22,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  color: AppConstants.surfaceWhite,
                                ),
                              )
                            : const Text('Войти'),
                      ),
                    ),

                    // Сообщение об ошибке
                    if (authProvider.error != null)
                      Padding(
                        padding: const EdgeInsets.only(top: 16),
                        child: Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: Colors.red.withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(AppConstants.cardRadius),
                            border: Border.all(color: Colors.red.withValues(alpha: 0.3)),
                          ),
                          child: Row(
                            children: [
                              Icon(PhosphorIconsRegular.warningCircle, color: Colors.red, size: 20),
                              const SizedBox(width: 8),
                              Expanded(
                                child: Text(
                                  authProvider.error!,
                                  style: const TextStyle(color: Colors.red),
                                ),
                              ),
                              IconButton(
                                icon: Icon(PhosphorIconsRegular.x, size: 16),
                                onPressed: () => authProvider.clearError(),
                                padding: EdgeInsets.zero,
                                constraints: const BoxConstraints(),
                              ),
                            ],
                          ),
                        ),
                      ),

                    const SizedBox(height: 32),
                    Text(
                      'v1.0.0 · ТГПУ профиль',
                      textAlign: TextAlign.center,
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: AppConstants.secondaryColor,
                          ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTextField(
      BuildContext context, {
        required TextEditingController controller,
        required String label,
        required String hintText,
        required IconData prefixIcon,
        bool obscureText = false,
        Widget? suffixIcon,
        String? Function(String?)? validator,
      }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
            fontWeight: FontWeight.w600,
            color: Colors.grey[800],
          ),
        ),
        const SizedBox(height: 4),
        TextFormField(
          controller: controller,
          obscureText: obscureText,
          validator: validator,
          decoration: InputDecoration(
            hintText: hintText,
            prefixIcon: Icon(prefixIcon, color: Colors.grey),
            suffixIcon: suffixIcon,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(AppConstants.cardRadius),
              borderSide: const BorderSide(color: Colors.grey),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(AppConstants.cardRadius),
              borderSide: BorderSide(color: AppConstants.primaryColor, width: 2),
            ),
            filled: true,
            fillColor: AppConstants.surfaceWhite,
          ),
        ),
      ],
    );
  }

  Future<void> _showServerUrlDialog(BuildContext context) async {
    final controller = TextEditingController(text: AppConstants.integrationBaseUrl);
    final saved = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Адрес сервера'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Text(
              'Без этого телефон не достучится до VPS. Пример:',
              style: TextStyle(fontSize: 13),
            ),
            const SizedBox(height: 6),
            SelectableText(
              'http://72.56.244.26:8080',
              style: TextStyle(fontWeight: FontWeight.w600, color: AppConstants.terracottaDark),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: controller,
              decoration: const InputDecoration(
                labelText: 'URL',
                hintText: 'http://IP:8080',
                border: OutlineInputBorder(),
              ),
              keyboardType: TextInputType.url,
              autocorrect: false,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Отмена'),
          ),
          TextButton(
            onPressed: () async {
              await IntegrationRuntime.saveServerUrlOverride('');
              if (ctx.mounted) Navigator.pop(ctx, true);
            },
            child: const Text('Сброс'),
          ),
          FilledButton(
            onPressed: () async {
              final u = controller.text.trim();
              if (!u.startsWith('http://') && !u.startsWith('https://')) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Адрес должен начинаться с http:// или https://')),
                );
                return;
              }
              await IntegrationRuntime.saveServerUrlOverride(u);
              if (ctx.mounted) Navigator.pop(ctx, true);
            },
            child: const Text('Сохранить'),
          ),
        ],
      ),
    );
    controller.dispose();
    if (saved == true && mounted) {
      setState(() {});
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Сервер: ${AppConstants.integrationBaseUrl}')),
      );
    }
  }

  Future<void> _login(BuildContext context) async {
    if (!_formKey.currentState!.validate()) return;

    FocusScope.of(context).unfocus();

    final authProvider = context.read<AuthProvider>();
    final success = await authProvider.login(
      _loginController.text.trim(),
      _passwordController.text.trim(),
      rememberMe: _rememberMe,
    );

    if (success && mounted) {
      // Загружаем данные студента
      final studentProvider = context.read<StudentProvider>();
      await studentProvider.loadStudentData();

      widget.onLoginSuccess?.call();
    }
  }

}