import 'package:flutter/material.dart';

import '../../core/theme/app_colors.dart';
import '../../shared/widgets/section_header.dart';
import '../../shared/widgets/stat_card.dart';
import 'widgets/current_route_card.dart';
import 'widgets/daily_goal_card.dart';
import 'widgets/home_header.dart';
import 'widgets/mission_card.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      bottom: false,
      child: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(20, 12, 20, 24),
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 480),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const HomeHeader(),
                const SizedBox(height: 22),
                const CurrentRouteCard(),
                const SizedBox(height: 26),
                SectionHeader(
                  title: 'Tu progreso',
                  action: 'Esta semana',
                  onAction: _noop,
                ),
                const SizedBox(height: 10),
                const Row(
                  children: [
                    Expanded(
                      child: StatCard(
                        value: '1,250',
                        label: 'XP total',
                        color: AppColors.primary,
                      ),
                    ),
                    SizedBox(width: 10),
                    Expanded(
                      child: StatCard(
                        value: '8',
                        label: 'Lecciones',
                        color: AppColors.secondary,
                      ),
                    ),
                    SizedBox(width: 10),
                    Expanded(
                      child: StatCard(
                        value: '7 días',
                        label: 'Racha',
                        color: AppColors.gold,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 26),
                SectionHeader(
                  title: 'Misión recomendada',
                  action: 'Ver ruta',
                  onAction: _noop,
                ),
                const SizedBox(height: 10),
                const MissionCard(),
                const SizedBox(height: 14),
                const DailyGoalCard(),
              ],
            ),
          ),
        ),
      ),
    );
  }

  static void _noop() {}
}
