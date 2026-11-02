import 'package:flutter/material.dart';

import '../../../core/theme/app_colors.dart';
import '../models/diagram_lesson.dart';

class LessonDiagramBuilder extends StatelessWidget {
  const LessonDiagramBuilder({
    super.key,
    required this.lesson,
    required this.placedBlocks,
    required this.availableBlocks,
    required this.onPlace,
    required this.onRemove,
    this.enabled = true,
  });

  final DiagramLesson lesson;
  final List<DiagramBlock?> placedBlocks;
  final List<DiagramBlock> availableBlocks;
  final ValueChanged<DiagramBlock> onPlace;
  final ValueChanged<int> onRemove;
  final bool enabled;

  @override
  Widget build(BuildContext context) {
    final placedCount = placedBlocks.where((block) => block != null).length;

    return Container(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 18),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.border.withValues(alpha: 0.7)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              const Text(
                'TU DIAGRAMA',
                style: TextStyle(
                  color: AppColors.secondary,
                  fontSize: 9.5,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 1.1,
                ),
              ),
              const Spacer(),
              Text(
                '$placedCount de ${placedBlocks.length}',
                style: const TextStyle(
                  color: AppColors.textMuted,
                  fontSize: 10.5,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          for (var index = 0; index < placedBlocks.length; index++) ...[
            _DiagramSlot(
              index: index,
              block: placedBlocks[index],
              enabled: enabled,
              onRemove: onRemove,
            ),
            if (index < placedBlocks.length - 1) const _Connector(),
          ],
          const SizedBox(height: 18),
          Container(height: 1, color: AppColors.border),
          const SizedBox(height: 14),
          const Text(
            'BLOQUES DISPONIBLES',
            style: TextStyle(
              color: AppColors.textMuted,
              fontSize: 9.5,
              fontWeight: FontWeight.w700,
              letterSpacing: 1.1,
            ),
          ),
          const SizedBox(height: 10),
          if (availableBlocks.isEmpty)
            Text(
              enabled
                  ? 'Todos los bloques están en el diagrama.'
                  : 'Diagrama completado.',
              style: const TextStyle(
                color: AppColors.textMuted,
                fontSize: 12,
                fontWeight: FontWeight.w500,
              ),
            )
          else
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                for (final block in availableBlocks)
                  _BlockButton(
                    block: block,
                    enabled: enabled,
                    onTap: () => onPlace(block),
                  ),
              ],
            ),
          if (lesson.blocks.length != placedBlocks.length) ...[
            const SizedBox(height: 10),
            Text(
              'Esta lección necesita ${lesson.blocks.length} bloques.',
              style: const TextStyle(color: AppColors.textMuted, fontSize: 11),
            ),
          ],
        ],
      ),
    );
  }
}

class _DiagramSlot extends StatelessWidget {
  const _DiagramSlot({
    required this.index,
    required this.block,
    required this.enabled,
    required this.onRemove,
  });

  final int index;
  final DiagramBlock? block;
  final bool enabled;
  final ValueChanged<int> onRemove;

  @override
  Widget build(BuildContext context) {
    final placedBlock = block;
    final canRemove = placedBlock != null && enabled;
    final accent = placedBlock == null
        ? AppColors.border
        : _colorFor(placedBlock.kind);

    return Semantics(
      button: canRemove,
      label: placedBlock == null
          ? 'Espacio ${index + 1}, vacío'
          : 'Espacio ${index + 1}: ${placedBlock.label}. Toca para quitar.',
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: canRemove ? () => onRemove(index) : null,
          borderRadius: BorderRadius.circular(14),
          child: Ink(
            height: 64,
            decoration: BoxDecoration(
              color: const Color(0xFF0D1A2A),
              borderRadius: BorderRadius.circular(14),
              border: Border.all(
                color: placedBlock == null
                    ? AppColors.border
                    : accent.withValues(alpha: 0.7),
                width: placedBlock == null ? 1 : 1.4,
              ),
            ),
            child: Center(
              child: placedBlock == null
                  ? _EmptySlotLabel(index: index)
                  : _DiagramNode(block: placedBlock, showRemoveHint: enabled),
            ),
          ),
        ),
      ),
    );
  }
}

class _EmptySlotLabel extends StatelessWidget {
  const _EmptySlotLabel({required this.index});

  final int index;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 22,
          height: 22,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            border: Border.all(color: AppColors.border),
          ),
          child: Text(
            '${index + 1}',
            style: const TextStyle(
              color: AppColors.textMuted,
              fontSize: 10,
              fontWeight: FontWeight.w700,
            ),
          ),
        ),
        const SizedBox(width: 9),
        Text(
          'Espacio ${index + 1}',
          style: const TextStyle(
            color: AppColors.textMuted,
            fontSize: 12,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }
}

class _DiagramNode extends StatelessWidget {
  const _DiagramNode({required this.block, this.showRemoveHint = false});

  final DiagramBlock block;
  final bool showRemoveHint;

  @override
  Widget build(BuildContext context) {
    final color = _colorFor(block.kind);
    final isPill = block.kind != DiagramBlockKind.process;

    return Container(
      constraints: const BoxConstraints(maxWidth: 230),
      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 9),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(isPill ? 999 : 8),
        border: Border.all(color: color.withValues(alpha: 0.8), width: 1.4),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Flexible(
            child: Text(
              block.label,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                color: AppColors.textPrimary,
                fontSize: 12.5,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
          if (showRemoveHint) ...[
            const SizedBox(width: 7),
            Icon(Icons.close_rounded, size: 14, color: color),
          ],
        ],
      ),
    );
  }
}

class _BlockButton extends StatelessWidget {
  const _BlockButton({
    required this.block,
    required this.enabled,
    required this.onTap,
  });

  final DiagramBlock block;
  final bool enabled;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final color = _colorFor(block.kind);
    final isPill = block.kind != DiagramBlockKind.process;

    return Semantics(
      button: true,
      label: 'Colocar ${block.label}',
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: enabled ? onTap : null,
          borderRadius: BorderRadius.circular(isPill ? 999 : 10),
          child: Ink(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 11),
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(isPill ? 999 : 10),
              border: Border.all(color: color.withValues(alpha: 0.8)),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.add_rounded, size: 15, color: color),
                const SizedBox(width: 6),
                Text(
                  block.label,
                  style: const TextStyle(
                    color: AppColors.textPrimary,
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _Connector extends StatelessWidget {
  const _Connector();

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 34,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(width: 1.4, height: 13, color: AppColors.border),
          const Icon(
            Icons.keyboard_arrow_down_rounded,
            size: 19,
            color: AppColors.textMuted,
          ),
        ],
      ),
    );
  }
}

Color _colorFor(DiagramBlockKind kind) {
  return switch (kind) {
    DiagramBlockKind.start => AppColors.primary,
    DiagramBlockKind.process => AppColors.secondary,
    DiagramBlockKind.end => AppColors.gold,
  };
}
