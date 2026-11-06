import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../../../core/theme/app_colors.dart';

class UnitProgressRing extends StatelessWidget {
  const UnitProgressRing({
    super.key,
    required this.progress,
    this.size = 62,
    this.strokeWidth = 5,
    this.color = AppColors.primary,
  });

  final double progress;
  final double size;
  final double strokeWidth;
  final Color color;

  @override
  Widget build(BuildContext context) {
    final percentage = (progress.clamp(0.0, 1.0) * 100).round();

    return SizedBox(
      width: size,
      height: size,
      child: Stack(
        alignment: Alignment.center,
        children: [
          CustomPaint(
            size: Size.square(size),
            painter: _RingPainter(
              progress: progress,
              strokeWidth: strokeWidth,
              color: color,
            ),
          ),
          Text(
            '$percentage%',
            style: TextStyle(
              color: AppColors.textPrimary,
              fontSize: size >= 56 ? 12 : 10,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }
}

class _RingPainter extends CustomPainter {
  const _RingPainter({
    required this.progress,
    required this.strokeWidth,
    required this.color,
  });

  final double progress;
  final double strokeWidth;
  final Color color;

  @override
  void paint(Canvas canvas, Size size) {
    final center = size.center(Offset.zero);
    final radius = (size.shortestSide - strokeWidth) / 2;
    final arcRect = Rect.fromCircle(center: center, radius: radius);

    final trackPaint = Paint()
      ..color = color.withValues(alpha: 0.16)
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth;

    final progressPaint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.round;

    canvas.drawCircle(center, radius, trackPaint);
    canvas.drawArc(
      arcRect,
      -math.pi / 2,
      2 * math.pi * progress.clamp(0.0, 1.0),
      false,
      progressPaint,
    );
  }

  @override
  bool shouldRepaint(_RingPainter oldDelegate) {
    return oldDelegate.progress != progress ||
        oldDelegate.strokeWidth != strokeWidth ||
        oldDelegate.color != color;
  }
}
