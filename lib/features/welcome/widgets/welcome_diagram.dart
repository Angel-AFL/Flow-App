import 'package:flutter/material.dart';

import '../../../core/theme/app_colors.dart';

class WelcomeDiagram extends StatelessWidget {
  const WelcomeDiagram({super.key});

  @override
  Widget build(BuildContext context) {
    return Semantics(
      image: true,
      label: 'Diagrama de flujo: inicia, piensa y continúa hacia una decisión.',
      child: SizedBox(
        height: 240,
        child: Stack(
          alignment: Alignment.center,
          children: [
            const Positioned(
              left: 54,
              top: 84,
              child: _GlowDot(color: AppColors.secondary, size: 9),
            ),
            const Positioned(
              right: 58,
              top: 154,
              child: _GlowDot(color: AppColors.primary, size: 8),
            ),
            Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const _PillNode(label: 'Inicio', color: AppColors.primary),
                const _Connector(color: AppColors.primary),
                const _ProcessNode(label: 'Piensa', color: AppColors.secondary),
                const _Connector(color: AppColors.secondary),
                _DecisionNode(color: AppColors.gold),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _PillNode extends StatelessWidget {
  const _PillNode({required this.label, required this.color});

  final String label;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 96,
      height: 34,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: color.withValues(alpha: 0.75), width: 1.4),
      ),
      child: Text(
        label,
        style: const TextStyle(
          color: AppColors.textPrimary,
          fontSize: 11,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }
}

class _ProcessNode extends StatelessWidget {
  const _ProcessNode({required this.label, required this.color});

  final String label;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 132,
      height: 36,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.10),
        borderRadius: BorderRadius.circular(7),
        border: Border.all(color: color.withValues(alpha: 0.75), width: 1.4),
      ),
      child: Text(
        label,
        style: const TextStyle(
          color: AppColors.textPrimary,
          fontSize: 11,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }
}

class _DecisionNode extends StatelessWidget {
  const _DecisionNode({required this.color});

  final Color color;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 68,
      height: 68,
      child: Transform.rotate(
        angle: 0.785398,
        child: Container(
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.06),
            borderRadius: BorderRadius.circular(8),
            border: Border.all(
              color: color.withValues(alpha: 0.75),
              width: 1.4,
            ),
          ),
        ),
      ),
    );
  }
}

class _Connector extends StatelessWidget {
  const _Connector({required this.color});

  final Color color;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 16,
      height: 38,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 1.4,
            height: 20,
            color: color.withValues(alpha: 0.55),
          ),
          Icon(
            Icons.arrow_drop_down_rounded,
            color: color.withValues(alpha: 0.8),
            size: 16,
          ),
        ],
      ),
    );
  }
}

class _GlowDot extends StatelessWidget {
  const _GlowDot({required this.color, required this.size});

  final Color color;
  final double size;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: color,
        boxShadow: [
          BoxShadow(
            color: color.withValues(alpha: 0.55),
            blurRadius: 14,
            spreadRadius: 3,
          ),
        ],
      ),
    );
  }
}
