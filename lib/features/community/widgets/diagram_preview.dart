import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../../../core/theme/app_colors.dart';
import '../models/community_post.dart';

class DiagramPreview extends StatelessWidget {
  const DiagramPreview({super.key, required this.diagram});

  final DiagramSpec diagram;

  @override
  Widget build(BuildContext context) {
    final isLinear = diagram.type == DiagramPreviewType.linear;

    return Semantics(
      image: true,
      label: isLinear
          ? 'Diagrama de flujo lineal: ${diagram.startLabel}, '
                '${diagram.processLabel}, ${diagram.endLabel}'
          : 'Diagrama de flujo con decisión: ${diagram.decisionLabel}',
      child: Container(
        height: isLinear ? 152 : 188,
        decoration: BoxDecoration(
          color: const Color(0xFF0D1A2A),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: AppColors.secondary.withValues(alpha: 0.18),
          ),
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(12),
          child: Stack(
            fit: StackFit.expand,
            children: [
              const CustomPaint(painter: _DotGridPainter()),
              Center(
                child: isLinear
                    ? _LinearFlow(diagram: diagram)
                    : _DecisionFlow(diagram: diagram),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _LinearFlow extends StatelessWidget {
  const _LinearFlow({required this.diagram});

  final DiagramSpec diagram;

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        _PillNode(label: diagram.startLabel),
        const _Connector(height: 14),
        _ProcessNode(label: diagram.processLabel),
        const _Connector(height: 14),
        _PillNode(label: diagram.endLabel),
      ],
    );
  }
}

class _DecisionFlow extends StatelessWidget {
  const _DecisionFlow({required this.diagram});

  final DiagramSpec diagram;

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        _PillNode(label: diagram.startLabel),
        const _Connector(height: 12),
        _DiamondNode(label: diagram.decisionLabel),
        const SizedBox(height: 6),
        SizedBox(
          width: 128,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _BranchLabel(label: diagram.yesLabel),
              _BranchLabel(label: diagram.noLabel),
            ],
          ),
        ),
        const _Connector(height: 7),
        _PillNode(label: diagram.endLabel),
      ],
    );
  }
}

class _PillNode extends StatelessWidget {
  const _PillNode({required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 5),
      decoration: BoxDecoration(
        color: const Color(0xFF14283C),
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: AppColors.secondary.withValues(alpha: 0.7)),
      ),
      child: Text(
        label,
        style: const TextStyle(
          color: AppColors.textPrimary,
          fontSize: 9.5,
          fontWeight: FontWeight.w600,
          height: 1.2,
        ),
      ),
    );
  }
}

class _ProcessNode extends StatelessWidget {
  const _ProcessNode({required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 132,
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: const Color(0xFF14283C),
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: AppColors.secondary.withValues(alpha: 0.7)),
      ),
      child: FittedBox(
        fit: BoxFit.scaleDown,
        child: Text(
          label,
          maxLines: 1,
          style: const TextStyle(
            color: AppColors.textPrimary,
            fontSize: 9.5,
            fontWeight: FontWeight.w600,
            height: 1.2,
          ),
        ),
      ),
    );
  }
}

class _DiamondNode extends StatelessWidget {
  const _DiamondNode({required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 66,
      height: 66,
      child: Stack(
        alignment: Alignment.center,
        children: [
          Transform.rotate(
            angle: math.pi / 4,
            child: Container(
              width: 42,
              height: 42,
              decoration: BoxDecoration(
                color: const Color(0xFF14283C),
                borderRadius: BorderRadius.circular(4),
                border: Border.all(
                  color: AppColors.secondary.withValues(alpha: 0.7),
                ),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 4),
            child: FittedBox(
              fit: BoxFit.scaleDown,
              child: Text(
                label,
                maxLines: 1,
                style: const TextStyle(
                  color: AppColors.textPrimary,
                  fontSize: 9,
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

class _BranchLabel extends StatelessWidget {
  const _BranchLabel({required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    return Text(
      label,
      style: const TextStyle(
        color: AppColors.textMuted,
        fontSize: 8.5,
        fontWeight: FontWeight.w500,
      ),
    );
  }
}

class _Connector extends StatelessWidget {
  const _Connector({required this.height});

  final double height;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 1.2,
      height: height,
      color: AppColors.secondary.withValues(alpha: 0.5),
    );
  }
}

class _DotGridPainter extends CustomPainter {
  const _DotGridPainter();

  static const _spacing = 13.0;
  static const _dotRadius = 0.9;

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = const Color(0xFF2B4A63).withValues(alpha: 0.6);

    for (double x = _spacing / 2; x < size.width; x += _spacing) {
      for (double y = _spacing / 2; y < size.height; y += _spacing) {
        canvas.drawCircle(Offset(x, y), _dotRadius, paint);
      }
    }
  }

  @override
  bool shouldRepaint(_DotGridPainter oldDelegate) => false;
}
