import 'package:flutter/material.dart';

import '../../../core/theme/app_colors.dart';
import '../../../shared/widgets/diagram_preview.dart';
import '../../../shared/widgets/section_header.dart';
import '../models/profile_data.dart';

class DiagramGallery extends StatelessWidget {
  const DiagramGallery({super.key, required this.onViewAll});

  final VoidCallback onViewAll;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        SectionHeader(
          title: 'Mis diagramas',
          action: 'Ver todos',
          onAction: onViewAll,
        ),
        const SizedBox(height: 10),
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            for (
              var index = 0;
              index < ProfileMockData.diagrams.length;
              index++
            )
              Expanded(
                child: Padding(
                  padding: EdgeInsets.only(
                    left: index == 0 ? 0 : 5,
                    right: index == 0 ? 5 : 0,
                  ),
                  child: _DiagramCard(diagram: ProfileMockData.diagrams[index]),
                ),
              ),
          ],
        ),
      ],
    );
  }
}

class _DiagramCard extends StatelessWidget {
  const _DiagramCard({required this.diagram});

  final ProfileDiagram diagram;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(7),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: AppColors.border.withValues(alpha: 0.65)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          DiagramPreview(diagram: diagram.diagram, height: 150),
          const SizedBox(height: 8),
          Text(
            diagram.title,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            textAlign: TextAlign.center,
            style: const TextStyle(
              color: AppColors.textSecondary,
              fontSize: 10,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}
