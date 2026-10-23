import 'package:flutter/material.dart';

import '../../../core/theme/app_colors.dart';

class WeeklyWorkshopCard extends StatelessWidget {
  const WeeklyWorkshopCard({super.key, required this.onTap});

  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      borderRadius: BorderRadius.circular(16),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: Ink(
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [AppColors.surfaceElevated, AppColors.surfaceCardEnd],
            ),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: AppColors.secondary.withValues(alpha: 0.35),
            ),
          ),
          child: Padding(
            padding: const EdgeInsets.fromLTRB(15, 13, 10, 13),
            child: Row(
              children: [
                const Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'WORKSHOP SEMANAL',
                        style: TextStyle(
                          color: AppColors.secondary,
                          fontSize: 9.5,
                          fontWeight: FontWeight.w700,
                          letterSpacing: 1.2,
                        ),
                      ),
                      SizedBox(height: 5),
                      Text(
                        'Reto: semáforo inteligente',
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          color: AppColors.textPrimary,
                          fontSize: 14.5,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      SizedBox(height: 4),
                      Text.rich(
                        TextSpan(
                          children: [
                            TextSpan(
                              text: 'Dificultad media',
                              style: TextStyle(
                                color: AppColors.textSecondary,
                                fontSize: 10.5,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                            TextSpan(
                              text: '  ·  4.8',
                              style: TextStyle(
                                color: AppColors.textSecondary,
                                fontSize: 10.5,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                            TextSpan(
                              text: ' ★',
                              style: TextStyle(
                                color: AppColors.gold,
                                fontSize: 11,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ],
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 6),
                const Icon(
                  Icons.chevron_right_rounded,
                  color: AppColors.textMuted,
                  size: 22,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
