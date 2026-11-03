import 'package:flutter/material.dart';

import '../../../core/theme/app_colors.dart';
import '../../../shared/widgets/section_header.dart';

class ActivityHeatmap extends StatelessWidget {
  const ActivityHeatmap({
    super.key,
    required this.weeks,
    this.hasActivity = true,
  });

  /// [week][weekday], cinco semanas de lunes a domingo.
  final List<List<int>> weeks;
  final bool hasActivity;

  static const _dayLabels = ['L', 'M', 'X', 'J', 'V', 'S', 'D'];

  int _levelAt(int week, int day) {
    if (week >= weeks.length || day >= weeks[week].length) {
      return 0;
    }

    return weeks[week][day];
  }

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
              child: Column(
                children: [
                  for (var day = 0; day < 7; day++)
                    Padding(
                      padding: EdgeInsets.only(top: day == 0 ? 0 : 5),
                      child: Row(
                        children: [
                          SizedBox(
                            width: 16,
                            child: Text(
                              _dayLabels[day],
                              textAlign: TextAlign.center,
                              style: const TextStyle(
                                color: AppColors.textMuted,
                                fontSize: 9,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                          const SizedBox(width: 7),
                          for (var week = 0; week < 5; week++) ...[
                            if (week > 0) const SizedBox(width: 5),
                            Expanded(
                              child: AspectRatio(
                                aspectRatio: 1,
                                child: _ActivityCell(
                                  level: _levelAt(week, day),
                                ),
                              ),
                            ),
                          ],
                        ],
                      ),
                    ),
                  if (!hasActivity) ...[
                    const SizedBox(height: 10),
                    const Text(
                      'Aún no hay actividad registrada.',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: AppColors.textMuted,
                        fontSize: 10.5,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                  const SizedBox(height: 10),
                  const Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      Text(
                        'Menos',
                        style: TextStyle(
                          color: AppColors.textMuted,
                          fontSize: 9,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      SizedBox(width: 6),
                      _LegendCell(level: 0),
                      SizedBox(width: 4),
                      _LegendCell(level: 1),
                      SizedBox(width: 4),
                      _LegendCell(level: 2),
                      SizedBox(width: 4),
                      _LegendCell(level: 3),
                      SizedBox(width: 6),
                      Text(
                        'Más',
                        style: TextStyle(
                          color: AppColors.textMuted,
                          fontSize: 9,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
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

class _LegendCell extends StatelessWidget {
  const _LegendCell({required this.level});

  final int level;

  @override
  Widget build(BuildContext context) {
    return SizedBox(width: 11, height: 11, child: _ActivityCell(level: level));
  }
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
        borderRadius: BorderRadius.circular(4),
      ),
    );
  }
}
