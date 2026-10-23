import 'package:flutter/material.dart';

import '../../../core/theme/app_colors.dart';
import '../../../shared/widgets/section_header.dart';
import '../models/profile_data.dart';

class ActivityHeatmap extends StatelessWidget {
  const ActivityHeatmap({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        SectionHeader(
          title: 'Actividad',
          action: 'Últimas 5 semanas',
          onAction: _noop,
        ),
        const SizedBox(height: 10),
        Semantics(
          label: 'Mapa de actividad de las últimas 5 semanas',
          child: ExcludeSemantics(
            child: Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: AppColors.surface,
                borderRadius: BorderRadius.circular(18),
                border: Border.all(
                  color: AppColors.border.withValues(alpha: 0.65),
                ),
              ),
              child: GridView.count(
                crossAxisCount: 5,
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                mainAxisSpacing: 7,
                crossAxisSpacing: 7,
                children: [
                  for (final week in ProfileMockData.activity)
                    for (final level in week) _ActivityCell(level: level),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }

  static void _noop() {}
}

class _ActivityCell extends StatelessWidget {
  const _ActivityCell({required this.level});

  final int level;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: switch (level) {
          0 => AppColors.surfaceElevated.withValues(alpha: 0.55),
          1 => AppColors.primary.withValues(alpha: 0.24),
          2 => AppColors.primary.withValues(alpha: 0.48),
          _ => AppColors.primary.withValues(alpha: 0.78),
        },
        borderRadius: BorderRadius.circular(5),
      ),
    );
  }
}
