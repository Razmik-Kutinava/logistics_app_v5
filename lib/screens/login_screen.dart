import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:logistics_app/providers/auth_provider.dart';
import 'package:logistics_app/utils/app_theme.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _phoneController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _isPasswordVisible = false;
  bool _isLoading = false;

  @override
  void dispose() {
    _phoneController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  String? _validatePhone(String? value) {
    if (value == null || value.isEmpty) {
      return 'Введите номер телефона';
    }
    // Проверка армянского номера телефона
    final phoneRegex = RegExp(r'^\+374[0-9]{8}$');
    if (!phoneRegex.hasMatch(value)) {
      return 'Неверный формат номера.\nВведите в формате +374XXXXXXXX';
    }
    return null;
  }

  String? _validatePassword(String? value) {
    if (value == null || value.isEmpty) {
      return 'Введите пароль';
    }
    if (value.length != 6) {
      return 'Пароль должен содержать 6 цифр';
    }
    if (!RegExp(r'^[0-9]+$').hasMatch(value)) {
      return 'Пароль должен содержать только цифры';
    }
    return null;
  }

  Future<void> _login() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      final success = await authProvider.login(
        _phoneController.text,
        _passwordController.text,
      );

      if (!mounted) return;

      if (success) {
        context.go('/home');
      } else {
        _showErrorSnackBar('Неверный номер телефона или пароль');
      }
    } catch (e) {
      if (mounted) {
        _showErrorSnackBar('Ошибка подключения. Попробуйте позже.');
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  void _showErrorSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          message,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w500,
          ),
        ),
        backgroundColor: AppTheme.errorRed,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        margin: const EdgeInsets.all(16),
      ),
    );
  }

  void _formatPhoneNumber(String value) {
    // Автоматическое добавление +374 если начинают вводить цифры
    if (value.isNotEmpty &&
        !value.startsWith('+374') &&
        RegExp(r'^[0-9]').hasMatch(value)) {
      _phoneController.text = '+374$value';
      _phoneController.selection = TextSelection.fromPosition(
        TextPosition(offset: _phoneController.text.length),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.backgroundWhite,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: AppTheme.screenPadding,
          child: Column(
            children: [
              const SizedBox(height: 40),

              // Логотип и заголовок
              _buildHeader(),

              const SizedBox(height: 48),

              // Форма входа
              _buildLoginForm(),

              const SizedBox(height: 32),

              // Кнопка "Забыли пароль?"
              _buildForgotPasswordButton(),

              const SizedBox(height: 40),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Column(
      children: [
        // Логотип
        Container(
          width: 100,
          height: 100,
          decoration: BoxDecoration(
            color: AppTheme.primaryDarkBlue,
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(
                color: AppTheme.primaryDarkBlue.withOpacity(0.3),
                blurRadius: 15,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(20),
            child: Image.asset(
              'assets/icons/logo.png',
              fit: BoxFit.contain,
              errorBuilder: (context, error, stackTrace) {
                return Icon(
                  Icons.local_shipping,
                  size: 60,
                  color: AppTheme.textLight,
                );
              },
            ),
          ),
        ),

        const SizedBox(height: 24),

        // Заголовок
        Text(
          'CIO Logistics',
          style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                color: AppTheme.primaryDarkBlue,
                fontWeight: FontWeight.bold,
              ),
        ),

        const SizedBox(height: 8),

        Text(
          'Вход для водителей',
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                color: AppTheme.textDark.withOpacity(0.7),
              ),
        ),
      ],
    );
  }

  Widget _buildLoginForm() {
    return Form(
      key: _formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Поле номера телефона
          TextFormField(
            controller: _phoneController,
            keyboardType: TextInputType.phone,
            validator: _validatePhone,
            onChanged: _formatPhoneNumber,
            style: Theme.of(context).textTheme.bodyLarge,
            inputFormatters: [
              FilteringTextInputFormatter.allow(RegExp(r'[+0-9]')),
              LengthLimitingTextInputFormatter(12), // +374XXXXXXXX
            ],
            decoration: InputDecoration(
              labelText: 'Номер телефона',
              hintText: '+374XXXXXXXX',
              prefixIcon: Icon(
                Icons.phone,
                size: AppTheme.getIconSize(context, 24),
                color: AppTheme.primaryDarkBlue,
              ),
              counterText: '',
            ),
          ),

          const SizedBox(height: 24),

          // Поле пароля
          TextFormField(
            controller: _passwordController,
            validator: _validatePassword,
            obscureText: !_isPasswordVisible,
            keyboardType: TextInputType.number,
            style: Theme.of(context).textTheme.bodyLarge,
            inputFormatters: [
              FilteringTextInputFormatter.digitsOnly,
              LengthLimitingTextInputFormatter(6),
            ],
            decoration: InputDecoration(
              labelText: 'Пароль (6 цифр)',
              hintText: '••••••',
              prefixIcon: Icon(
                Icons.lock,
                size: AppTheme.getIconSize(context, 24),
                color: AppTheme.primaryDarkBlue,
              ),
              suffixIcon: IconButton(
                icon: Icon(
                  _isPasswordVisible ? Icons.visibility_off : Icons.visibility,
                  size: AppTheme.getIconSize(context, 24),
                  color: AppTheme.primaryDarkBlue,
                ),
                onPressed: () {
                  setState(() {
                    _isPasswordVisible = !_isPasswordVisible;
                  });
                },
              ),
              counterText: '',
            ),
          ),

          const SizedBox(height: 32),

          // Кнопка входа
          SizedBox(
            height: AppTheme.getButtonHeight(context),
            child: ElevatedButton(
              onPressed: _isLoading ? null : _login,
              child: _isLoading
                  ? SizedBox(
                      width: 24,
                      height: 24,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        valueColor: AlwaysStoppedAnimation<Color>(
                          AppTheme.textLight,
                        ),
                      ),
                    )
                  : Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.login,
                          size: AppTheme.getIconSize(context, 24),
                        ),
                        const SizedBox(width: 12),
                        Text(
                          'Войти',
                          style:
                              Theme.of(context).textTheme.titleMedium?.copyWith(
                                    color: AppTheme.textLight,
                                    fontWeight: FontWeight.bold,
                                  ),
                        ),
                      ],
                    ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildForgotPasswordButton() {
    return TextButton(
      onPressed: () {
        // TODO: Реализовать восстановление пароля
        _showErrorSnackBar(
            'Обратитесь к администратору для восстановления пароля');
      },
      child: Text(
        'Забыли пароль?',
        style: Theme.of(context).textTheme.bodyLarge?.copyWith(
              color: AppTheme.primaryDarkBlue,
              decoration: TextDecoration.underline,
            ),
      ),
    );
  }
}
