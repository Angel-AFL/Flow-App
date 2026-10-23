import 'package:flutter/material.dart';

import '../../../core/theme/app_colors.dart';
import '../../../shared/widgets/flow_wordmark.dart';
import '../models/profile_data.dart';

class ProfileHeader extends StatelessWidget {
  const ProfileHeader({super.key, required this.onThemeTap});

  final VoidCallback onThemeTap;

  @override
  Widget build(BuildContext context) {
    final progress = ProfileMockData.xp / ProfileMockData.nextLevelXp;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Row(
          children: [
            const FlowWordmark(logoSize: 24, textSize: 19),
            const Spacer(),
            IconButton(
              onPressed: onThemeTap,
              tooltip: 'Cambiar tema',
              icon: const Icon(
                Icons.wb_sunny_outlined,
                size: 19,
                color: AppColors.textSecondary,
              ),
              style: IconButton.styleFrom(
                backgroundColor: AppColors.surface,
                minimumSize: const Size(42, 42),
                shape: const CircleBorder(
                  side: BorderSide(color: AppColors.border),
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 10),
        Center(
          child: Semantics(
            label: 'Avatar de ${ProfileMockData.name}',
            image: true,
            child: SizedBox(
              width: 92,
              height: 92,
              child: Stack(
                clipBehavior: Clip.none,
                alignment: Alignment.center,
                children: [
                  Container(
                    width: 84,
                    height: 84,
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      gradient: const LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: [Color(0xFF67C7F5), AppColors.secondary],
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: AppColors.secondary.withValues(alpha: 0.28),
                          blurRadius: 18,
                          offset: const Offset(0, 6),
                        ),
                      ],
                    ),
                    child: const Text(
                      ProfileMockData.initials,
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 27,
                        fontWeight: FontWeight.w800,
                        letterSpacing: 1.2,
                      ),
                    ),
                  ),
                  Positioned(
                    right: 3,
                    bottom: 3,
                    child: Container(
                      width: 21,
                      height: 21,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: AppColors.primary,
                        border: Border.all(
                          color: AppColors.background,
                          width: 3,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
        const SizedBox(height: 12),
        const Text(
          ProfileMockData.name,
          textAlign: TextAlign.center,
          style: TextStyle(
            color: AppColors.textPrimary,
            fontSize: 23,
            fontWeight: FontWeight.w900,
            height: 1.15,
            letterSpacing: -0.3,
          ),
        ),
        const SizedBox(height: 4),
        Text.rich(
          TextSpan(
            children: [
              const TextSpan(
                text: ProfileMockData.handle,
                style: TextStyle(color: AppColors.textSecondary),
              ),
              const TextSpan(
                text: '  ·  ',
                style: TextStyle(color: AppColors.textMuted),
              ),
              const TextSpan(
                text: ProfileMockData.role,
                style: TextStyle(color: AppColors.textSecondary),
              ),
            ],
          ),
          textAlign: TextAlign.center,
          style: const TextStyle(fontSize: 11.5, fontWeight: FontWeight.w500),
        ),
        const SizedBox(height: 18),
        Row(
          children: [
            const Text(
              'Nivel ${ProfileMockData.level}',
              style: TextStyle(
                color: AppColors.textSecondary,
                fontSize: 10.5,
                fontWeight: FontWeight.w600,
              ),
            ),
            const Spacer(),
            Text(
              '${_formatXp(ProfileMockData.xp)} / '
              '${_formatXp(ProfileMockData.nextLevelXp)} XP',
              style: const TextStyle(
                color: AppColors.textMuted,
                fontSize: 10.5,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
        const SizedBox(height: 7),
        Semantics(
          label:
              'Progreso al nivel ${ProfileMockData.level + 1}: '
              '${ProfileMockData.xp} de ${ProfileMockData.nextLevelXp} XP',
          child: ClipRRect(
            borderRadius: BorderRadius.circular(999),
            child: SizedBox(
              height: 7,
              child: ColoredBox(
                color: AppColors.primary.withValues(alpha: 0.16),
                child: FractionallySizedBox(
                  alignment: Alignment.centerLeft,
                  widthFactor: progress,
                  child: const DecoratedBox(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [AppColors.primary, Color(0xFF8FE838)],
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }

  static String _formatXp(int value) {
    final digits = value.toString();
    final buffer = StringBuffer();

    for (var index = 0; index < digits.length; index++) {
      if (index > 0 && (digits.length - index) % 3 == 0) {
        buffer.write(',');
      }
      buffer.write(digits[index]);
    }

    return buffer.toString();
  }
}
