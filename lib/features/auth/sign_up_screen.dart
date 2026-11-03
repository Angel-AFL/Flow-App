import 'package:flutter/material.dart';

import '../../core/auth/auth_repository.dart';
import '../../core/theme/app_colors.dart';
import 'auth_validators.dart';
import 'login_screen.dart';
import 'widgets/auth_error_banner.dart';
import 'widgets/auth_field.dart';
import 'widgets/auth_scaffold.dart';
import 'widgets/auth_submit_button.dart';
import 'widgets/password_toggle.dart';

class SignUpScreen extends StatefulWidget {
  const SignUpScreen({super.key, required this.authRepository});

  final AuthRepository authRepository;

  @override
  State<SignUpScreen> createState() => _SignUpScreenState();
}

class _SignUpScreenState extends State<SignUpScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();

  bool _obscurePassword = true;
  bool _isSubmitting = false;
  String? _error;
  String? _confirmationEmail;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
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

    final email = _emailController.text.trim();

    try {
      final result = await widget.authRepository.signUp(
        email: email,
        password: _passwordController.text,
      );

      if (!mounted) {
        return;
      }

      if (result == SignUpResult.confirmationRequired) {
        setState(() => _confirmationEmail = email);
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
          () => _error = 'No pudimos crear la cuenta. Inténtalo de nuevo.',
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isSubmitting = false);
      }
    }
  }

  void _openLogin() {
    Navigator.of(context).pushReplacement(
      MaterialPageRoute<void>(
        builder: (_) => LoginScreen(authRepository: widget.authRepository),
      ),
    );
  }

  void _close() {
    Navigator.of(context).popUntil((route) => route.isFirst);
  }

  @override
  Widget build(BuildContext context) {
    final confirmationEmail = _confirmationEmail;

    if (confirmationEmail != null) {
      return _ConfirmationView(
        email: confirmationEmail,
        onLogin: _openLogin,
        onClose: _close,
      );
    }

    return AuthScaffold(
      title: 'Crea tu\ncuenta.',
      subtitle: 'Empieza tu ruta y guarda tu progreso en la nube.',
      footer: Center(
        child: TextButton(
          onPressed: _isSubmitting ? null : _openLogin,
          style: TextButton.styleFrom(
            foregroundColor: AppColors.secondary,
            disabledForegroundColor: AppColors.textMuted,
            textStyle: const TextStyle(
              fontSize: 12.5,
              fontWeight: FontWeight.w700,
            ),
          ),
          child: const Text('¿Ya tienes cuenta? Inicia sesión'),
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
                key: const Key('signup-email'),
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
                key: const Key('signup-password'),
                controller: _passwordController,
                label: 'Contraseña',
                hint: 'Mínimo 8 caracteres',
                icon: Icons.lock_outline_rounded,
                obscureText: _obscurePassword,
                textInputAction: TextInputAction.next,
                autofillHints: const [AutofillHints.newPassword],
                validator: AuthValidators.newPassword,
                enabled: !_isSubmitting,
                suffixIcon: PasswordToggle(
                  obscure: _obscurePassword,
                  onPressed: () =>
                      setState(() => _obscurePassword = !_obscurePassword),
                ),
              ),
              const SizedBox(height: 14),
              AuthField(
                key: const Key('signup-confirm-password'),
                controller: _confirmPasswordController,
                label: 'Confirmar contraseña',
                hint: 'Repite tu contraseña',
                icon: Icons.lock_reset_rounded,
                obscureText: _obscurePassword,
                textInputAction: TextInputAction.done,
                validator: (value) => AuthValidators.confirmPassword(
                  value,
                  _passwordController.text,
                ),
                enabled: !_isSubmitting,
                onFieldSubmitted: (_) => _submit(),
              ),
              const SizedBox(height: 22),
              AuthSubmitButton(
                label: 'Crear cuenta',
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

class _ConfirmationView extends StatelessWidget {
  const _ConfirmationView({
    required this.email,
    required this.onLogin,
    required this.onClose,
  });

  final String email;
  final VoidCallback onLogin;
  final VoidCallback onClose;

  @override
  Widget build(BuildContext context) {
    return AuthScaffold(
      title: 'Revisa tu\ncorreo.',
      subtitle: 'Enviamos un enlace de confirmación a:',
      onBack: onClose,
      footer: Center(
        child: TextButton(
          onPressed: onClose,
          style: TextButton.styleFrom(
            foregroundColor: AppColors.textMuted,
            textStyle: const TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
            ),
          ),
          child: const Text('Volver al inicio'),
        ),
      ),
      children: [
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: AppColors.border),
          ),
          child: Row(
            children: [
              const Icon(
                Icons.mark_email_read_outlined,
                size: 22,
                color: AppColors.secondary,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  email,
                  style: const TextStyle(
                    color: AppColors.textPrimary,
                    fontSize: 13.5,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),
        const Text(
          'Abre el enlace del correo para activar tu cuenta. Después vuelve '
          'aquí e inicia sesión con tu correo y contraseña.',
          style: TextStyle(
            color: AppColors.textSecondary,
            fontSize: 13,
            height: 1.45,
          ),
        ),
        const SizedBox(height: 24),
        AuthSubmitButton(
          label: 'Ir a iniciar sesión',
          isLoading: false,
          onPressed: onLogin,
        ),
      ],
    );
  }
}
