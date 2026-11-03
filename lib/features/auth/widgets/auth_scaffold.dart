import 'package:flutter/material.dart';

import '../../../core/theme/app_colors.dart';
import '../../../shared/widgets/flow_background.dart';
import '../../../shared/widgets/flow_wordmark.dart';

class AuthScaffold extends StatelessWidget {
  const AuthScaffold({
    super.key,
    required this.title,
    required this.subtitle,
    required this.children,
    this.footer,
    this.onBack,
  });

  final String title;
  final String subtitle;
  final List<Widget> children;
  final Widget? footer;
  final VoidCallback? onBack;

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
                  padding: const EdgeInsets.fromLTRB(24, 8, 24, 28),
                  child: Center(
                    child: ConstrainedBox(
                      constraints: BoxConstraints(
                        maxWidth: 480,
                        minHeight: constraints.maxHeight - 36,
                      ),
                      child: IntrinsicHeight(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            Row(
                              children: [
                                _AuthBackButton(
                                  onPressed:
                                      onBack ??
                                      () => Navigator.of(context).maybePop(),
                                ),
                                const Spacer(),
                                const FlowWordmark(logoSize: 24, textSize: 19),
                              ],
                            ),
                            const SizedBox(height: 30),
                            FittedBox(
                              fit: BoxFit.scaleDown,
                              alignment: Alignment.centerLeft,
                              child: Text(
                                title,
                                style: const TextStyle(
                                  color: AppColors.textPrimary,
                                  fontSize: 32,
                                  fontWeight: FontWeight.w900,
                                  height: 1.06,
                                  letterSpacing: -0.7,
                                ),
                              ),
                            ),
                            const SizedBox(height: 10),
                            Text(
                              subtitle,
                              style: const TextStyle(
                                color: AppColors.textSecondary,
                                fontSize: 13.5,
                                fontWeight: FontWeight.w400,
                                height: 1.45,
                              ),
                            ),
                            const SizedBox(height: 26),
                            ...children,
                            const Spacer(),
                            if (footer != null) ...[
                              const SizedBox(height: 24),
                              footer!,
                            ],
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

class _AuthBackButton extends StatelessWidget {
  const _AuthBackButton({required this.onPressed});

  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return IconButton(
      onPressed: onPressed,
      tooltip: 'Volver',
      icon: const Icon(
        Icons.arrow_back_rounded,
        size: 19,
        color: AppColors.textSecondary,
      ),
      style: IconButton.styleFrom(
        backgroundColor: AppColors.surface,
        minimumSize: const Size(42, 42),
        shape: const CircleBorder(side: BorderSide(color: AppColors.border)),
      ),
    );
  }
}
