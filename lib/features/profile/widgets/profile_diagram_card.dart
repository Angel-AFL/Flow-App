import 'package:flutter/material.dart';

import '../../../core/theme/app_colors.dart';
import '../../../shared/widgets/diagram_preview.dart';
import '../models/profile_models.dart';

class ProfileDiagramCard extends StatelessWidget {
  const ProfileDiagramCard({
    super.key,
    required this.diagram,
    this.previewHeight = 150,
  });

  final ProfileDiagram diagram;
  final double previewHeight;

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
          DiagramPreview(diagram: diagram.diagram, height: previewHeight),
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
