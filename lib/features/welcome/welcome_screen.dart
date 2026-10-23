import 'package:flutter/material.dart';

import '../../core/navigation/app_shell.dart';
import '../../core/theme/app_colors.dart';
import '../../shared/widgets/flow_background.dart';
import '../../shared/widgets/flow_wordmark.dart';
import 'widgets/welcome_diagram.dart';

class WelcomeScreen extends StatelessWidget {
  const WelcomeScreen({super.key});

  void _enterApp(BuildContext context) {
    Navigator.of(context).pushReplacement(
      MaterialPageRoute<void>(builder: (_) => const AppShell()),
    );
  }

  void _showThemeFeedback(BuildContext context) {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          content: const Text(
            'El tema claro estará disponible próximamente.',
            style: TextStyle(
              color: AppColors.textPrimary,
              fontSize: 12.5,
              fontWeight: FontWeight.w500,
            ),
          ),
          backgroundColor: AppColors.surfaceElevated,
          behavior: SnackBarBehavior.floating,
          margin: const EdgeInsets.fromLTRB(20, 0, 20, 14),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          duration: const Duration(seconds: 2),
        ),
      );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: Stack(
        fit: StackFit.expand,
        children: [
          const FlowBackground(),
          SafeArea(
            child: LayoutBuilder(
              builder: (context, constraints) {
                return SingleChildScrollView(
                  padding: const EdgeInsets.fromLTRB(24, 16, 24, 24),
                  child: Center(
                    child: ConstrainedBox(
                      constraints: BoxConstraints(
                        maxWidth: 480,
                        minHeight: constraints.maxHeight - 40,
                      ),
                      child: IntrinsicHeight(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            _WelcomeHeader(
                              onThemeTap: () => _showThemeFeedback(context),
                            ),
                            const SizedBox(height: 8),
                            const WelcomeDiagram(),
                            const SizedBox(height: 8),
                            FittedBox(
                              fit: BoxFit.scaleDown,
                              alignment: Alignment.centerLeft,
                              child: Text.rich(
                                TextSpan(
                                  children: [
                                    const TextSpan(
                                      text: 'Aprende a pensar\n',
                                      style: TextStyle(
                                        color: AppColors.textPrimary,
                                      ),
                                    ),
                                    TextSpan(
                                      text: 'paso a paso.',
                                      style: TextStyle(
                                        color: AppColors.primary,
                                      ),
                                    ),
                                  ],
                                ),
                                style: const TextStyle(
                                  fontSize: 36,
                                  fontWeight: FontWeight.w900,
                                  height: 1.06,
                                  letterSpacing: -0.8,
                                ),
                              ),
                            ),
                            const SizedBox(height: 16),
                            const Text(
                              'Domina la lógica de programación creando '
                              'diagramas que cobran vida.',
                              style: TextStyle(
                                color: AppColors.textSecondary,
                                fontSize: 13.5,
                                fontWeight: FontWeight.w400,
                                height: 1.45,
                              ),
                            ),
                            const Spacer(),
                            const SizedBox(height: 32),
                            SizedBox(
                              height: 54,
                              child: FilledButton(
                                onPressed: () => _enterApp(context),
                                style: FilledButton.styleFrom(
                                  backgroundColor: AppColors.primary,
                                  foregroundColor: AppColors.onPrimary,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(14),
                                  ),
                                  textStyle: const TextStyle(
                                    fontSize: 15,
                                    fontWeight: FontWeight.w800,
                                  ),
                                ),
                                child: const Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Text('Comenzar'),
                                    SizedBox(width: 4),
                                    Icon(Icons.chevron_right_rounded, size: 20),
                                  ],
                                ),
                              ),
                            ),
                            const SizedBox(height: 10),
                            SizedBox(
                              height: 52,
                              child: OutlinedButton(
                                onPressed: () => _enterApp(context),
                                style: OutlinedButton.styleFrom(
                                  foregroundColor: AppColors.textPrimary,
                                  side: const BorderSide(
                                    color: AppColors.border,
                                  ),
                                  backgroundColor: AppColors.backgroundDeep
                                      .withValues(alpha: 0.55),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(14),
                                  ),
                                  textStyle: const TextStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                                child: const Text('Ya tengo una cuenta'),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

class _WelcomeHeader extends StatelessWidget {
  const _WelcomeHeader({required this.onThemeTap});

  final VoidCallback onThemeTap;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        const FlowWordmark(),
        const Spacer(),
        IconButton(
          onPressed: onThemeTap,
          tooltip: 'Cambiar tema',
          icon: const Icon(
            Icons.wb_sunny_outlined,
            size: 19,
            color: AppColors.textSecondary,
          ),
          style: IconButton.styleFrom(
            backgroundColor: AppColors.surface,
            minimumSize: const Size(42, 42),
            shape: const CircleBorder(
              side: BorderSide(color: AppColors.border),
            ),
          ),
        ),
      ],
    );
  }
}
