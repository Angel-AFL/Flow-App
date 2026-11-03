import 'package:flutter/material.dart';

import '../../core/theme/app_colors.dart';
import '../../shared/models/diagram_skin.dart';
import '../../shared/widgets/flow_background.dart';
import 'models/profile_models.dart';
import 'widgets/profile_diagram_card.dart';

class MyDiagramsScreen extends StatelessWidget {
  const MyDiagramsScreen({
    super.key,
    required this.diagrams,
    this.skin = DiagramSkin.classic,
  });

  final List<ProfileDiagram> diagrams;
  final DiagramSkin skin;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: Stack(
        fit: StackFit.expand,
        children: [
          const FlowBackground(),
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(20, 8, 20, 24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Row(
                    children: [
                      IconButton(
                        onPressed: () => Navigator.of(context).maybePop(),
                        tooltip: 'Volver',
                        icon: const Icon(
                          Icons.arrow_back_rounded,
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
                      const Expanded(
                        child: Text(
                          'Mis diagramas',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            color: AppColors.textPrimary,
                            fontSize: 20,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                      ),
                      const SizedBox(width: 42),
                    ],
                  ),
                  const SizedBox(height: 20),
                  Expanded(
                    child: diagrams.isEmpty
                        ? const _EmptyState()
                        : GridView.builder(
                            padding: const EdgeInsets.only(bottom: 12),
                            itemCount: diagrams.length,
                            gridDelegate:
                                const SliverGridDelegateWithFixedCrossAxisCount(
                                  crossAxisCount: 2,
                                  mainAxisSpacing: 12,
                                  crossAxisSpacing: 12,
                                  mainAxisExtent: 200,
                                ),
                            itemBuilder: (context, index) {
                              return ProfileDiagramCard(
                                diagram: diagrams[index],
                                previewHeight: 142,
                                skin: skin,
                              );
                            },
                          ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _EmptyState extends StatelessWidget {
  const _EmptyState();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Container(
        constraints: const BoxConstraints(maxWidth: 360),
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(color: AppColors.border.withValues(alpha: 0.65)),
        ),
        child: const Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.account_tree_outlined,
              size: 34,
              color: AppColors.textMuted,
            ),
            SizedBox(height: 12),
            Text(
              'Aún no has creado diagramas.',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: AppColors.textPrimary,
                fontSize: 15,
                fontWeight: FontWeight.w700,
              ),
            ),
            SizedBox(height: 6),
            Text(
              'Cuando resuelvas uno en la ruta de aprendizaje, aparecerá aquí.',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: AppColors.textSecondary,
                fontSize: 12,
                height: 1.45,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
