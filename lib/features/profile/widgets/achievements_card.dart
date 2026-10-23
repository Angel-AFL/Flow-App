import 'package:flutter/material.dart';

import '../../../core/theme/app_colors.dart';
import '../../../shared/widgets/section_header.dart';
import '../models/profile_data.dart';

class AchievementsCard extends StatelessWidget {
  const AchievementsCard({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        SectionHeader(
          title: 'Logros',
          action:
              '${ProfileMockData.unlockedAchievements} de '
              '${ProfileMockData.totalAchievements}',
          onAction: _noop,
        ),
        const SizedBox(height: 12),
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            for (final achievement in ProfileMockData.achievements)
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 4),
                  child: _AchievementBadge(achievement: achievement),
                ),
              ),
          ],
        ),
      ],
    );
  }

  static void _noop() {}
}

class _AchievementBadge extends StatelessWidget {
  const _AchievementBadge({required this.achievement});

  final ProfileAchievement achievement;

  @override
  Widget build(BuildContext context) {
    final unlocked = achievement.unlocked;
    final color = unlocked ? AppColors.primary : AppColors.textMuted;

    return Semantics(
      label:
          '${achievement.label}, '
          '${unlocked ? 'desbloqueado' : 'bloqueado'}',
      child: Column(
        children: [
          Container(
            height: 54,
            width: double.infinity,
            decoration: BoxDecoration(
              color: unlocked
                  ? AppColors.primary.withValues(alpha: 0.10)
                  : AppColors.surfaceElevated.withValues(alpha: 0.7),
              borderRadius: BorderRadius.circular(13),
              border: Border.all(
                color: unlocked
                    ? AppColors.primary.withValues(alpha: 0.32)
                    : AppColors.border,
              ),
            ),
            child: Icon(achievement.icon, size: 23, color: color),
          ),
          const SizedBox(height: 7),
          SizedBox(
            height: 14,
            child: FittedBox(
              fit: BoxFit.scaleDown,
              child: Text(
                achievement.label,
                maxLines: 1,
                style: TextStyle(
                  color: unlocked
                      ? AppColors.textSecondary
                      : AppColors.textMuted,
                  fontSize: 9.5,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
