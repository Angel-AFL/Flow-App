import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../../../core/theme/app_colors.dart';

class DailyGoalCard extends StatelessWidget {
  const DailyGoalCard({
    super.key,
    required this.completed,
    this.total = 3,
  });

  final int completed;
  final int total;

  @override
  Widget build(BuildContext context) {
    final done = completed.clamp(0, total);
    final isComplete = total > 0 && completed >= total;
    final progress = total > 0 ? done / total : 0.0;
    final subtitle = isComplete
        ? 'Meta diaria completada'
        : '$done de $total actividades completadas';

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: AppColors.gold.withValues(alpha: 0.28)),
      ),
      child: Row(
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: AppColors.gold.withValues(alpha: 0.12),
              shape: BoxShape.circle,
            ),
            child: Icon(
              isComplete
                  ? Icons.check_rounded
                  : Icons.emoji_events_rounded,
              color: AppColors.gold,
              size: 22,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Meta diaria',
                  style: TextStyle(
                    color: AppColors.textPrimary,
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  subtitle,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: AppColors.textMuted,
                    fontSize: 10.5,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 12),
          Semantics(
            label: 'Meta diaria: $done de $total actividades completadas',
            child: SizedBox(
              width: 50,
              height: 50,
              child: Stack(
                alignment: Alignment.center,
                children: [
                  CustomPaint(
                    size: const Size.square(50),
                    painter: _GoalRingPainter(progress),
                  ),
                  Text(
                    '$done/$total',
                    style: const TextStyle(
                      color: AppColors.textPrimary,
                      fontSize: 11,
                      fontWeight: FontWeight.w700,
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
}

class _GoalRingPainter extends CustomPainter {
  const _GoalRingPainter(this.progress);

  final double progress;

  @override
  void paint(Canvas canvas, Size size) {
    const strokeWidth = 4.5;
    final center = size.center(Offset.zero);
    final radius = (size.shortestSide - strokeWidth) / 2;
    final arcRect = Rect.fromCircle(center: center, radius: radius);

    final trackPaint = Paint()
      ..color = AppColors.gold.withValues(alpha: 0.16)
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth;

    final progressPaint = Paint()
      ..color = AppColors.gold
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
  bool shouldRepaint(_GoalRingPainter oldDelegate) {
    return oldDelegate.progress != progress;
  }
}
