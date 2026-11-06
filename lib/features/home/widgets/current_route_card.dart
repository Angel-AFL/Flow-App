import 'package:flutter/material.dart';

import '../../../core/theme/app_colors.dart';
import '../../learn/models/learning_models.dart';
import '../../learn/widgets/unit_progress_ring.dart';

class CurrentRouteCard extends StatelessWidget {
  const CurrentRouteCard({
    super.key,
    required this.unit,
    required this.lesson,
    required this.onContinue,
    required this.onOpenLearn,
    this.isBusy = false,
  });

  final LearningUnit? unit;
  final LearningLesson? lesson;
  final VoidCallback onContinue;
  final VoidCallback onOpenLearn;
  final bool isBusy;

  @override
  Widget build(BuildContext context) {
    final progress = unit?.progress ?? 0;
    final percentage = (progress.clamp(0.0, 1.0) * 100).round();
    final totalLessons = unit?.totalLessons ?? 0;
    final currentLesson = lesson;
    final hasLesson = currentLesson != null;
    final title = unit?.title ?? 'Tu ruta de aprendizaje';
    final kicker = unit == null
        ? 'TU RUTA ACTUAL'
        : 'TU RUTA ACTUAL · UNIDAD ${unit!.sortOrder}';
    final subtitle = hasLesson
        ? 'Lección ${currentLesson.number} de $totalLessons · '
              '${currentLesson.title}'
        : totalLessons == 0
        ? 'Aún no hay lecciones disponibles'
        : '¡Ruta completada! Repasa tus lecciones cuando quieras';
    final buttonLabel = hasLesson ? 'Continuar lección' : 'Ver ruta';

    return Container(
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [AppColors.surfaceElevated, AppColors.surfaceCardEnd],
        ),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: AppColors.border.withValues(alpha: 0.55)),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(24),
        child: Stack(
          children: [
            Positioned(
              top: 6,
              right: -58,
              child: Container(
                width: 178,
                height: 178,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: RadialGradient(
                    colors: [
                      const Color(0xFF33536F).withValues(alpha: 0.55),
                      Colors.transparent,
                    ],
                  ),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    kicker,
                    style: const TextStyle(
                      color: AppColors.textMuted,
                      fontSize: 10.5,
                      fontWeight: FontWeight.w700,
                      letterSpacing: 1.4,
                    ),
                  ),
                  const SizedBox(height: 10),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: Text(
                          title,
                          style: const TextStyle(
                            color: AppColors.textPrimary,
                            fontSize: 21,
                            fontWeight: FontWeight.w800,
                            height: 1.18,
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Semantics(
                        label:
                            'Progreso de la unidad: $percentage por ciento',
                        child: UnitProgressRing(
                          progress: progress,
                          size: 50,
                          strokeWidth: 4.5,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(
                    subtitle,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      color: AppColors.textSecondary,
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                      height: 1.35,
                    ),
                  ),
                  const SizedBox(height: 14),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(999),
                    child: Container(
                      height: 8,
                      color: AppColors.background.withValues(alpha: 0.75),
                      child: FractionallySizedBox(
                        alignment: Alignment.centerLeft,
                        widthFactor: progress.clamp(0.0, 1.0),
                        child: Container(
                          decoration: const BoxDecoration(
                            gradient: LinearGradient(
                              colors: [AppColors.primary, Color(0xFF7BE22A)],
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 18),
                  SizedBox(
                    width: double.infinity,
                    child: FilledButton(
                      onPressed: isBusy
                          ? null
                          : hasLesson
                          ? onContinue
                          : onOpenLearn,
                      style: FilledButton.styleFrom(
                        backgroundColor: AppColors.primary,
                        foregroundColor: AppColors.onPrimary,
                        disabledBackgroundColor: AppColors.surfaceElevated,
                        disabledForegroundColor: AppColors.textMuted,
                        elevation: 0,
                        minimumSize: const Size.fromHeight(54),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                        textStyle: const TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          if (isBusy)
                            const SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(
                                strokeWidth: 2.2,
                                color: AppColors.textMuted,
                              ),
                            )
                          else
                            Icon(
                              hasLesson
                                  ? Icons.play_arrow_rounded
                                  : Icons.route_rounded,
                              size: 22,
                            ),
                          const SizedBox(width: 8),
                          Flexible(
                            child: Text(
                              buttonLabel,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
