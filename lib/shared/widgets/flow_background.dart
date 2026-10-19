import 'package:flutter/material.dart';

import '../../core/theme/app_colors.dart';

class FlowBackground extends StatelessWidget {
  const FlowBackground({super.key});

  @override
  Widget build(BuildContext context) {
    return IgnorePointer(
      child: Stack(
        fit: StackFit.expand,
        children: [
          Positioned(
            top: -130,
            left: -110,
            child: _Glow(
              size: 340,
              color: AppColors.secondary.withValues(alpha: 0.16),
            ),
          ),
          Positioned(
            top: 190,
            right: -160,
            child: _Glow(
              size: 360,
              color: AppColors.primary.withValues(alpha: 0.10),
            ),
          ),
          Positioned(
            bottom: -170,
            left: -120,
            child: _Glow(
              size: 320,
              color: AppColors.secondary.withValues(alpha: 0.07),
            ),
          ),
        ],
      ),
    );
  }
}

class _Glow extends StatelessWidget {
  const _Glow({required this.size, required this.color});

  final double size;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: RadialGradient(colors: [color, color.withValues(alpha: 0)]),
      ),
    );
  }
}
