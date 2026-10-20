import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../../../core/theme/app_colors.dart';

enum _StepKind { completedLesson, currentLesson, lockedUnit }

class _PathStep {
  const _PathStep({
    required this.kind,
    required this.kicker,
    required this.title,
    this.subtitle,
  });

  final _StepKind kind;
  final String kicker;
  final String title;
  final String? subtitle;
}

const List<_PathStep> _steps = [
  _PathStep(
    kind: _StepKind.completedLesson,
    kicker: 'LECCIÓN 1',
    title: '¿Qué es un diagrama?',
  ),
  _PathStep(
    kind: _StepKind.completedLesson,
    kicker: 'LECCIÓN 2',
    title: 'Conoce los símbolos',
  ),
  _PathStep(
    kind: _StepKind.currentLesson,
    kicker: 'LECCIÓN 3',
    title: 'Tu primer diagrama',
    subtitle: '+50 XP · 5 min',
  ),
  _PathStep(
    kind: _StepKind.lockedUnit,
    kicker: 'UNIDAD 2',
    title: 'Condicionales — If / Else',
    subtitle: 'Completa la unidad anterior',
  ),
  _PathStep(
    kind: _StepKind.lockedUnit,
    kicker: 'UNIDAD 3',
    title: 'Ciclos — While / For',
    subtitle: 'Completa la unidad anterior',
  ),
  _PathStep(
    kind: _StepKind.lockedUnit,
    kicker: 'UNIDAD 4',
    title: 'Funciones',
    subtitle: 'Completa la unidad anterior',
  ),
  _PathStep(
    kind: _StepKind.lockedUnit,
    kicker: 'UNIDAD 5',
    title: 'Recursividad',
    subtitle: 'Completa la unidad anterior',
  ),
];

class LearningPath extends StatelessWidget {
  const LearningPath({super.key});

  static const _rowHeight = 100.0;
  static const _nodeSize = 54.0;
  static const _nodeTop = 16.0;
  static const _nodeLeft = 8.0;
  static const _indent = 52.0;
  static const _labelGap = 14.0;

  @override
  Widget build(BuildContext context) {
    final centers = List<Offset>.generate(_steps.length, (index) {
      final left = _nodeLeft + (index.isOdd ? _indent : 0);
      return Offset(
        left + _nodeSize / 2,
        index * _rowHeight + _nodeTop + _nodeSize / 2,
      );
    });

    return SizedBox(
      height: _steps.length * _rowHeight,
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          Positioned.fill(
            child: IgnorePointer(
              child: CustomPaint(painter: _PathConnectorPainter(centers)),
            ),
          ),
          for (var index = 0; index < _steps.length; index++)
            _PathRow(index: index, step: _steps[index]),
        ],
      ),
    );
  }
}

class _PathRow extends StatelessWidget {
  const _PathRow({required this.index, required this.step});

  final int index;
  final _PathStep step;

  @override
  Widget build(BuildContext context) {
    final left =
        LearningPath._nodeLeft + (index.isOdd ? LearningPath._indent : 0);

    return Positioned(
      top: index * LearningPath._rowHeight,
      left: 0,
      right: 0,
      height: LearningPath._nodeTop * 2 + LearningPath._nodeSize,
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          Positioned(
            left: left,
            top: LearningPath._nodeTop,
            child: _PathNode(
              kind: step.kind,
              label: '${step.kicker} ${step.title}',
            ),
          ),
          Positioned(
            left: left + LearningPath._nodeSize + LearningPath._labelGap,
            top: 0,
            bottom: 0,
            right: 0,
            child: Align(
              alignment: Alignment.centerLeft,
              child: _PathLabel(step: step),
            ),
          ),
        ],
      ),
    );
  }
}

class _PathNode extends StatelessWidget {
  const _PathNode({required this.kind, required this.label});

  final _StepKind kind;
  final String label;

  static const _size = LearningPath._nodeSize;

  @override
  Widget build(BuildContext context) {
    final isLocked = kind == _StepKind.lockedUnit;
    final status = switch (kind) {
      _StepKind.completedLesson => 'completada',
      _StepKind.currentLesson => 'actual',
      _StepKind.lockedUnit => 'bloqueada',
    };

    return Semantics(
      label: '$label, $status',
      child: Container(
        width: _size,
        height: _size,
        decoration: _decorationFor(kind),
        child: Icon(
          switch (kind) {
            _StepKind.completedLesson => Icons.check_rounded,
            _StepKind.currentLesson => Icons.play_arrow_rounded,
            _StepKind.lockedUnit => Icons.lock_rounded,
          },
          color: isLocked ? AppColors.textMuted : Colors.white,
          size: switch (kind) {
            _StepKind.completedLesson => 28,
            _StepKind.currentLesson => 30,
            _StepKind.lockedUnit => 20,
          },
        ),
      ),
    );
  }

  BoxDecoration _decorationFor(_StepKind kind) {
    switch (kind) {
      case _StepKind.completedLesson:
        return BoxDecoration(
          color: AppColors.primary,
          borderRadius: BorderRadius.circular(17),
          boxShadow: const [
            BoxShadow(color: Color(0xFF3E8E00), offset: Offset(0, 4)),
            BoxShadow(
              color: Color(0x33000000),
              offset: Offset(0, 6),
              blurRadius: 10,
            ),
          ],
        );
      case _StepKind.currentLesson:
        return BoxDecoration(
          gradient: const LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [Color(0xFF5AC8FA), AppColors.secondary],
          ),
          borderRadius: BorderRadius.circular(17),
          boxShadow: [
            BoxShadow(
              color: AppColors.secondary.withValues(alpha: 0.45),
              offset: const Offset(0, 4),
              blurRadius: 14,
            ),
          ],
        );
      case _StepKind.lockedUnit:
        return BoxDecoration(
          color: AppColors.surfaceElevated,
          borderRadius: BorderRadius.circular(17),
          border: Border.all(color: AppColors.border),
        );
    }
  }
}

class _PathLabel extends StatelessWidget {
  const _PathLabel({required this.step});

  final _PathStep step;

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          step.kicker,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: const TextStyle(
            color: AppColors.textMuted,
            fontSize: 9.5,
            fontWeight: FontWeight.w700,
            letterSpacing: 1,
            height: 1.2,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          step.title,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: const TextStyle(
            color: AppColors.textPrimary,
            fontSize: 14,
            fontWeight: FontWeight.w700,
            height: 1.2,
          ),
        ),
        if (step.subtitle != null) ...[
          const SizedBox(height: 4),
          Text(
            step.subtitle!,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              color: AppColors.secondary,
              fontSize: 10.5,
              fontWeight: FontWeight.w600,
              height: 1.2,
            ),
          ),
        ],
      ],
    );
  }
}

class _PathConnectorPainter extends CustomPainter {
  const _PathConnectorPainter(this.centers);

  final List<Offset> centers;

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = AppColors.border.withValues(alpha: 0.9)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.6
      ..strokeCap = StrokeCap.round;

    for (var index = 0; index < centers.length - 1; index++) {
      final start =
          centers[index] + const Offset(0, LearningPath._nodeSize / 2);
      final end =
          centers[index + 1] - const Offset(0, LearningPath._nodeSize / 2);
      final path = Path()
        ..moveTo(start.dx, start.dy)
        ..cubicTo(
          start.dx,
          start.dy + (end.dy - start.dy) * 0.5,
          end.dx,
          end.dy - (end.dy - start.dy) * 0.5,
          end.dx,
          end.dy,
        );
      canvas.drawPath(_dashed(path), paint);
    }
  }

  Path _dashed(Path source, {double dash = 5, double gap = 5}) {
    final result = Path();
    for (final metric in source.computeMetrics()) {
      var distance = 0.0;
      while (distance < metric.length) {
        final next = math.min(distance + dash, metric.length);
        result.addPath(metric.extractPath(distance, next), Offset.zero);
        distance = next + gap;
      }
    }
    return result;
  }

  @override
  bool shouldRepaint(_PathConnectorPainter oldDelegate) {
    return oldDelegate.centers != centers;
  }
}
