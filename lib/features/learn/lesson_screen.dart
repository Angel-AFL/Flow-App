import 'package:flutter/material.dart';

import '../../core/theme/app_colors.dart';
import '../../shared/widgets/flow_background.dart';
import 'models/diagram_lesson.dart';
import 'widgets/lesson_diagram_builder.dart';

class LessonScreen extends StatefulWidget {
  const LessonScreen({super.key, required this.lesson});

  final DiagramLesson lesson;

  @override
  State<LessonScreen> createState() => _LessonScreenState();
}

class _LessonScreenState extends State<LessonScreen> {
  final ScrollController _scrollController = ScrollController();
  late final List<DiagramBlock> _trayOrder;
  late List<DiagramBlock> _availableBlocks;
  late List<DiagramBlock?> _placedBlocks;
  bool _approved = false;
  String? _error;

  @override
  void initState() {
    super.initState();
    _trayOrder = widget.lesson.trayBlocks;
    _availableBlocks = List.of(_trayOrder);
    _placedBlocks = List<DiagramBlock?>.filled(
      widget.lesson.blocks.length,
      null,
    );
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  bool get _isComplete => _placedBlocks.every((block) => block != null);

  void _placeBlock(DiagramBlock block) {
    if (_approved) {
      return;
    }

    final slot = _placedBlocks.indexWhere((placed) => placed == null);
    if (slot == -1) {
      return;
    }

    setState(() {
      _placedBlocks[slot] = block;
      _availableBlocks.removeWhere((available) => available.id == block.id);
      _error = null;
    });
  }

  void _removeBlock(int index) {
    if (_approved) {
      return;
    }

    final block = _placedBlocks[index];
    if (block == null) {
      return;
    }

    setState(() {
      _placedBlocks[index] = null;
      _availableBlocks.add(block);
      _availableBlocks.sort(
        (first, second) => _trayOrder
            .indexWhere((item) => item.id == first.id)
            .compareTo(_trayOrder.indexWhere((item) => item.id == second.id)),
      );
      _error = null;
    });
  }

  void _reset() {
    setState(() {
      _placedBlocks = List<DiagramBlock?>.filled(
        widget.lesson.blocks.length,
        null,
      );
      _availableBlocks = List.of(_trayOrder);
      _error = null;
    });
  }

  void _checkDiagram() {
    final isCorrect = widget.lesson.isCorrect(_placedBlocks);

    setState(() {
      if (isCorrect) {
        _approved = true;
        _error = null;
      } else {
        _error =
            'Casi. Revisa el orden: el flujo empieza en Inicio y termina en Fin.';
      }
    });

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted || !_scrollController.hasClients) {
        return;
      }

      _scrollController.animateTo(
        _scrollController.position.maxScrollExtent,
        duration: const Duration(milliseconds: 280),
        curve: Curves.easeOutCubic,
      );
    });
  }

  void _close() {
    Navigator.of(context).pop(_approved);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: Stack(
        fit: StackFit.expand,
        children: [
          const FlowBackground(),
          SafeArea(
            child: Column(
              children: [
                Padding(
                  padding: const EdgeInsets.fromLTRB(20, 12, 20, 0),
                  child: _LessonHeader(lesson: widget.lesson, onBack: _close),
                ),
                Expanded(
                  child: SingleChildScrollView(
                    controller: _scrollController,
                    padding: const EdgeInsets.fromLTRB(20, 18, 20, 28),
                    child: Center(
                      child: ConstrainedBox(
                        constraints: const BoxConstraints(maxWidth: 480),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            Text(
                              'CONSTRUYE EL FLUJO',
                              style: TextStyle(
                                color: AppColors.secondary.withValues(
                                  alpha: 0.9,
                                ),
                                fontSize: 9.5,
                                fontWeight: FontWeight.w700,
                                letterSpacing: 1.2,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              widget.lesson.title,
                              style: const TextStyle(
                                color: AppColors.textPrimary,
                                fontSize: 28,
                                fontWeight: FontWeight.w800,
                                height: 1.1,
                                letterSpacing: -0.4,
                              ),
                            ),
                            const SizedBox(height: 10),
                            Text(
                              widget.lesson.instructions,
                              style: const TextStyle(
                                color: AppColors.textSecondary,
                                fontSize: 13,
                                fontWeight: FontWeight.w400,
                                height: 1.45,
                              ),
                            ),
                            const SizedBox(height: 18),
                            LessonDiagramBuilder(
                              lesson: widget.lesson,
                              placedBlocks: _placedBlocks,
                              availableBlocks: _availableBlocks,
                              onPlace: _placeBlock,
                              onRemove: _removeBlock,
                              enabled: !_approved,
                            ),
                            if (_error != null) ...[
                              const SizedBox(height: 14),
                              _ErrorPanel(message: _error!),
                            ],
                            const SizedBox(height: 18),
                            if (_approved)
                              _SuccessPanel(
                                lesson: widget.lesson,
                                onContinue: () =>
                                    Navigator.of(context).pop(true),
                              )
                            else ...[
                              SizedBox(
                                height: 52,
                                child: FilledButton(
                                  onPressed: _isComplete ? _checkDiagram : null,
                                  style: FilledButton.styleFrom(
                                    backgroundColor: AppColors.primary,
                                    foregroundColor: AppColors.onPrimary,
                                    disabledBackgroundColor:
                                        AppColors.surfaceElevated,
                                    disabledForegroundColor:
                                        AppColors.textMuted,
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(14),
                                    ),
                                    textStyle: const TextStyle(
                                      fontSize: 14,
                                      fontWeight: FontWeight.w800,
                                    ),
                                  ),
                                  child: const Text('Aprobar diagrama'),
                                ),
                              ),
                              const SizedBox(height: 4),
                              TextButton.icon(
                                onPressed:
                                    _placedBlocks.any((block) => block != null)
                                    ? _reset
                                    : null,
                                icon: const Icon(
                                  Icons.refresh_rounded,
                                  size: 17,
                                ),
                                label: const Text('Reiniciar'),
                                style: TextButton.styleFrom(
                                  foregroundColor: AppColors.textSecondary,
                                  disabledForegroundColor: AppColors.textMuted,
                                  textStyle: const TextStyle(
                                    fontSize: 12.5,
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                              ),
                            ],
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _LessonHeader extends StatelessWidget {
  const _LessonHeader({required this.lesson, required this.onBack});

  final DiagramLesson lesson;
  final VoidCallback onBack;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        IconButton(
          onPressed: onBack,
          tooltip: 'Volver',
          icon: const Icon(
            Icons.arrow_back_rounded,
            size: 20,
            color: AppColors.textPrimary,
          ),
          style: IconButton.styleFrom(
            backgroundColor: AppColors.surface,
            minimumSize: const Size(42, 42),
            shape: const CircleBorder(
              side: BorderSide(color: AppColors.border),
            ),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'LECCIÓN ${lesson.number}',
                style: const TextStyle(
                  color: AppColors.textMuted,
                  fontSize: 9.5,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 1.1,
                ),
              ),
              const SizedBox(height: 3),
              Text(
                lesson.title,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  color: AppColors.textPrimary,
                  fontSize: 15,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(width: 10),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
          decoration: BoxDecoration(
            color: AppColors.gold.withValues(alpha: 0.12),
            borderRadius: BorderRadius.circular(999),
            border: Border.all(color: AppColors.gold.withValues(alpha: 0.45)),
          ),
          child: Text(
            '${lesson.xpReward} XP',
            style: const TextStyle(
              color: AppColors.gold,
              fontSize: 10.5,
              fontWeight: FontWeight.w700,
            ),
          ),
        ),
      ],
    );
  }
}

class _ErrorPanel extends StatelessWidget {
  const _ErrorPanel({required this.message});

  final String message;

  @override
  Widget build(BuildContext context) {
    final errorColor = Theme.of(context).colorScheme.error;

    return Container(
      padding: const EdgeInsets.fromLTRB(14, 12, 14, 12),
      decoration: BoxDecoration(
        color: errorColor.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: errorColor.withValues(alpha: 0.45)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(Icons.info_outline_rounded, size: 18, color: errorColor),
          const SizedBox(width: 9),
          Expanded(
            child: Text(
              message,
              style: TextStyle(
                color: errorColor,
                fontSize: 12,
                fontWeight: FontWeight.w600,
                height: 1.35,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _SuccessPanel extends StatelessWidget {
  const _SuccessPanel({required this.lesson, required this.onContinue});

  final DiagramLesson lesson;
  final VoidCallback onContinue;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(18, 20, 18, 18),
      decoration: BoxDecoration(
        color: AppColors.primary.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.primary.withValues(alpha: 0.55)),
      ),
      child: Column(
        children: [
          Container(
            width: 52,
            height: 52,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: AppColors.primary.withValues(alpha: 0.18),
              shape: BoxShape.circle,
              border: Border.all(
                color: AppColors.primary.withValues(alpha: 0.7),
              ),
            ),
            child: const Icon(
              Icons.check_rounded,
              color: AppColors.primary,
              size: 30,
            ),
          ),
          const SizedBox(height: 12),
          const Text(
            '¡Diagrama aprobado!',
            textAlign: TextAlign.center,
            style: TextStyle(
              color: AppColors.textPrimary,
              fontSize: 20,
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            'Completaste la lección ${lesson.number}.',
            textAlign: TextAlign.center,
            style: const TextStyle(
              color: AppColors.textSecondary,
              fontSize: 12.5,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 10),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            alignment: WrapAlignment.center,
            children: [
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  color: AppColors.gold.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(999),
                  border: Border.all(
                    color: AppColors.gold.withValues(alpha: 0.45),
                  ),
                ),
                child: Text(
                  '+${lesson.xpReward} XP',
                  style: const TextStyle(
                    color: AppColors.gold,
                    fontSize: 12,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
              if (lesson.coinReward > 0)
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: AppColors.secondary.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(999),
                    border: Border.all(
                      color: AppColors.secondary.withValues(alpha: 0.45),
                    ),
                  ),
                  child: Text(
                    '+${lesson.coinReward} monedas',
                    style: const TextStyle(
                      color: AppColors.secondary,
                      fontSize: 12,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 16),
          SizedBox(
            width: double.infinity,
            height: 50,
            child: FilledButton(
              onPressed: onContinue,
              style: FilledButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: AppColors.onPrimary,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
                textStyle: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w800,
                ),
              ),
              child: const Text('Volver a la ruta'),
            ),
          ),
        ],
      ),
    );
  }
}
