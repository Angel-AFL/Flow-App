import 'package:flutter/material.dart';

import '../../../core/theme/app_colors.dart';
import 'unit_progress_ring.dart';

class UnitSummaryCard extends StatelessWidget {
  const UnitSummaryCard({
    super.key,
    this.kicker = 'UNIDAD 1',
    this.title = 'Diagramas lineales',
    this.progress = 0.67,
    this.completedLessons = 2,
    this.totalLessons = 3,
  });

  final String kicker;
  final String title;
  final double progress;
  final int completedLessons;
  final int totalLessons;

  @override
  Widget build(BuildContext context) {
    final percentage = (progress * 100).round();
    final subtitle = totalLessons == 0
        ? 'Próximamente'
        : '$completedLessons de $totalLessons lecciones';

    return Container(
      padding: const EdgeInsets.fromLTRB(18, 16, 18, 16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.border.withValues(alpha: 0.7)),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  kicker,
                  style: const TextStyle(
                    color: AppColors.secondary,
                    fontSize: 9.5,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 1.2,
                  ),
                ),
                const SizedBox(height: 7),
                Text(
                  title,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: AppColors.textPrimary,
                    fontSize: 20,
                    fontWeight: FontWeight.w800,
                    height: 1.15,
                  ),
                ),
                const SizedBox(height: 5),
                Text(
                  subtitle,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: AppColors.textMuted,
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 14),
          Semantics(
            label: 'Progreso de $kicker: $percentage por ciento',
            child: UnitProgressRing(progress: progress),
          ),
        ],
      ),
    );
  }
}
