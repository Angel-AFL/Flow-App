import 'package:flutter/material.dart';

import '../../core/auth/auth_repository.dart';
import '../../core/theme/app_colors.dart';
import 'auth_validators.dart';
import 'sign_up_screen.dart';
import 'widgets/auth_error_banner.dart';
import 'widgets/auth_field.dart';
import 'widgets/auth_scaffold.dart';
import 'widgets/auth_submit_button.dart';
import 'widgets/password_toggle.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key, required this.authRepository});

  final AuthRepository authRepository;

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  bool _obscurePassword = true;
  bool _isSubmitting = false;
  String? _error;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (_isSubmitting) {
      return;
    }

    FocusScope.of(context).unfocus();

    if (!(_formKey.currentState?.validate() ?? false)) {
      return;
    }

    setState(() {
      _isSubmitting = true;
      _error = null;
    });

    try {
      await widget.authRepository.signIn(
        email: _emailController.text.trim(),
        password: _passwordController.text,
      );

      if (!mounted) {
        return;
      }

      Navigator.of(context).popUntil((route) => route.isFirst);
    } on AuthFailure catch (failure) {
      if (mounted) {
        setState(() => _error = failure.message);
      }
    } catch (_) {
      if (mounted) {
        setState(
          () => _error = 'No pudimos iniciar sesión. Inténtalo de nuevo.',
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isSubmitting = false);
      }
    }
  }

  void _openSignUp() {
    Navigator.of(context).pushReplacement(
      MaterialPageRoute<void>(
        builder: (_) => SignUpScreen(authRepository: widget.authRepository),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return AuthScaffold(
      title: 'Bienvenido\nde nuevo.',
      subtitle: 'Inicia sesión para continuar tu ruta de aprendizaje.',
      footer: Center(
        child: TextButton(
          onPressed: _isSubmitting ? null : _openSignUp,
          style: TextButton.styleFrom(
            foregroundColor: AppColors.secondary,
            disabledForegroundColor: AppColors.textMuted,
            textStyle: const TextStyle(
              fontSize: 12.5,
              fontWeight: FontWeight.w700,
            ),
          ),
          child: const Text('¿No tienes cuenta? Crear cuenta'),
        ),
      ),
      children: [
        if (_error != null) ...[
          AuthErrorBanner(message: _error!),
          const SizedBox(height: 16),
        ],
        Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              AuthField(
                key: const Key('login-email'),
                controller: _emailController,
                label: 'Correo electrónico',
                hint: 'tu@correo.com',
                icon: Icons.alternate_email_rounded,
                keyboardType: TextInputType.emailAddress,
                textInputAction: TextInputAction.next,
                autofillHints: const [AutofillHints.email],
                validator: AuthValidators.email,
                enabled: !_isSubmitting,
              ),
              const SizedBox(height: 14),
              AuthField(
                key: const Key('login-password'),
                controller: _passwordController,
                label: 'Contraseña',
                hint: 'Tu contraseña',
                icon: Icons.lock_outline_rounded,
                obscureText: _obscurePassword,
                textInputAction: TextInputAction.done,
                autofillHints: const [AutofillHints.password],
                validator: AuthValidators.password,
                enabled: !_isSubmitting,
                onFieldSubmitted: (_) => _submit(),
                suffixIcon: PasswordToggle(
                  obscure: _obscurePassword,
                  onPressed: () =>
                      setState(() => _obscurePassword = !_obscurePassword),
                ),
              ),
              const SizedBox(height: 22),
              AuthSubmitButton(
                label: 'Entrar',
                isLoading: _isSubmitting,
                onPressed: _submit,
              ),
            ],
          ),
        ),
      ],
    );
  }
}
