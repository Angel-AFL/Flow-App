import 'package:flutter/material.dart';

import '../../../core/theme/app_colors.dart';
import '../../../shared/widgets/section_header.dart';
import '../models/profile_models.dart';
import 'profile_diagram_card.dart';

class DiagramGallery extends StatelessWidget {
  const DiagramGallery({
    super.key,
    required this.diagrams,
    required this.onViewAll,
  });

  final List<ProfileDiagram> diagrams;
  final VoidCallback onViewAll;

  @override
  Widget build(BuildContext context) {
    final preview = diagrams.take(2).toList();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        SectionHeader(
          title: 'Mis diagramas',
          action: 'Ver todos',
          onAction: onViewAll,
        ),
        const SizedBox(height: 10),
        if (preview.isEmpty)
          const _EmptyDiagrams()
        else
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              for (var index = 0; index < preview.length; index++)
                Expanded(
                  child: Padding(
                    padding: EdgeInsets.only(
                      left: index == 0 ? 0 : 5,
                      right: index == 0 ? 5 : 0,
                    ),
                    child: ProfileDiagramCard(diagram: preview[index]),
                  ),
                ),
            ],
          ),
      ],
    );
  }
}

class _EmptyDiagrams extends StatelessWidget {
  const _EmptyDiagrams();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 22),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: AppColors.border.withValues(alpha: 0.65)),
      ),
      child: const Column(
        children: [
          Icon(
            Icons.account_tree_outlined,
            size: 26,
            color: AppColors.textMuted,
          ),
          SizedBox(height: 8),
          Text(
            'Aún no has creado diagramas.',
            textAlign: TextAlign.center,
            style: TextStyle(
              color: AppColors.textSecondary,
              fontSize: 12,
              fontWeight: FontWeight.w600,
            ),
          ),
          SizedBox(height: 3),
          Text(
            'Cuando resuelvas uno, aparecerá aquí.',
            textAlign: TextAlign.center,
            style: TextStyle(
              color: AppColors.textMuted,
              fontSize: 10.5,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}
