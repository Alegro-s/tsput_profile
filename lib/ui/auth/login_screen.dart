import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/constants.dart';
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
    _loginController.text = AppConstants.demoLogin;
    _passwordController.text = AppConstants.demoPassword;
    _checkSavedCredentials();
  }

  Future<void> _checkSavedCredentials() async {
    await Future.delayed(const Duration(milliseconds: 500));
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
                  Icons.school_rounded,
                  size: 72,
                  color: AppConstants.primaryColor,
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
                'Вход в личный кабинет студента',
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: Colors.grey[600],
                    ),
                textAlign: TextAlign.center,
              ),

              const SizedBox(height: 36),
              // Форма входа
              Form(
                key: _formKey,
                child: Column(
                  children: [
                    // Поле логина
                    _buildTextField(
                      context,
                      controller: _loginController,
                      label: 'Логин (ID студента)',
                      hintText: 'Пример: ST001',
                      prefixIcon: Icons.person,
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
                      hintText: 'Введите ваш пароль',
                      prefixIcon: Icons.lock,
                      obscureText: _obscurePassword,
                      suffixIcon: IconButton(
                        icon: Icon(
                          _obscurePassword ? Icons.visibility : Icons.visibility_off,
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
                                  color: Colors.black87,
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
                            color: Colors.red.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(color: Colors.red.withOpacity(0.3)),
                          ),
                          child: Row(
                            children: [
                              const Icon(Icons.error_outline, color: Colors.red, size: 20),
                              const SizedBox(width: 8),
                              Expanded(
                                child: Text(
                                  authProvider.error!,
                                  style: const TextStyle(color: Colors.red),
                                ),
                              ),
                              IconButton(
                                icon: const Icon(Icons.close, size: 16),
                                onPressed: () => authProvider.clearError(),
                                padding: EdgeInsets.zero,
                                constraints: const BoxConstraints(),
                              ),
                            ],
                          ),
                        ),
                      ),

                    // Демо-доступ
                    const SizedBox(height: 180),
                    Text(
                      'Для тестирования используйте:',
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: Colors.grey[600],
                      ),
                    ),
                    const SizedBox(height: 8),
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: AppConstants.primaryColor.withValues(alpha: 0.08),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Column(
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(
                                'Логин: ${AppConstants.demoLogin}',
                                style: TextStyle(color: AppConstants.primaryColor),
                              ),
                            ],
                          ),
                          const SizedBox(height: 4),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(
                                'Пароль: ${AppConstants.demoPassword}',
                                style: TextStyle(color: AppConstants.primaryColor),
                              ),
                            ],
                          ),
                          if (AppConstants.offlineDemoEnabled) ...[
                            const SizedBox(height: 12),
                            Text(
                              'Без сети: при недоступности сервера те же учётные данные откроют демо (офлайн).',
                              textAlign: TextAlign.center,
                              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                    color: Colors.grey[700],
                                  ),
                            ),
                          ],
                        ],
                      ),
                    ),

                    const SizedBox(height: 8),
                    Text(
                      'API: ${AppConstants.integrationBaseUrl}',
                      textAlign: TextAlign.center,
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: Colors.grey[500],
                            fontSize: 11,
                          ),
                    ),

                    const SizedBox(height: 20),

                    // Информация о приложении
                    Text(
                      'v1.0.0 | ТГПУ профиль',
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: Colors.grey[500],
                      ),
                    ),
                    Text(
                      'Разработано Alegro',
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: Colors.grey[500],
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
            fillColor: Colors.white,
          ),
        ),
      ],
    );
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

  Future<void> _showBiometricPrompt(BuildContext context) async {
    await showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Быстрый вход'),
        content: const Text(
          'Хотите включить быстрый вход с помощью отпечатка пальца?\n\nВы сможете быстро входить в приложение без ввода пароля.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Не сейчас'),
          ),
          ElevatedButton(
            onPressed: () async {
              Navigator.pop(context);
              final authProvider = context.read<AuthProvider>();
              // Реализация биометрии будет добавлена позже
              if (mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Быстрый вход включен!'),
                    duration: Duration(seconds: 2),
                  ),
                );
              }
            },
            child: const Text('Включить'),
          ),
        ],
      ),
    );
  }
}