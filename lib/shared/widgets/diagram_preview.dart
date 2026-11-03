import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../models/diagram_skin.dart';
import '../models/diagram_spec.dart';

class DiagramPreview extends StatelessWidget {
  const DiagramPreview({
    super.key,
    required this.diagram,
    this.height,
    this.skin = DiagramSkin.classic,
  });

  final DiagramSpec diagram;
  final double? height;
  final DiagramSkin skin;

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
        height: height ?? (isLinear ? 152 : 188),
        decoration: BoxDecoration(
          color: skin.background,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: skin.nodeBorder.withValues(alpha: 0.18)),
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(12),
          child: Stack(
            fit: StackFit.expand,
            children: [
              CustomPaint(painter: _DotGridPainter(color: skin.gridColor)),
              Center(
                child: FittedBox(
                  fit: BoxFit.scaleDown,
                  child: isLinear
                      ? _LinearFlow(diagram: diagram, skin: skin)
                      : _DecisionFlow(diagram: diagram, skin: skin),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _LinearFlow extends StatelessWidget {
  const _LinearFlow({required this.diagram, required this.skin});

  final DiagramSpec diagram;
  final DiagramSkin skin;

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        _PillNode(label: diagram.startLabel, skin: skin),
        _Connector(height: 14, skin: skin),
        _ProcessNode(label: diagram.processLabel, skin: skin),
        _Connector(height: 14, skin: skin),
        _PillNode(label: diagram.endLabel, skin: skin),
      ],
    );
  }
}

class _DecisionFlow extends StatelessWidget {
  const _DecisionFlow({required this.diagram, required this.skin});

  final DiagramSpec diagram;
  final DiagramSkin skin;

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        _PillNode(label: diagram.startLabel, skin: skin),
        _Connector(height: 12, skin: skin),
        _DiamondNode(label: diagram.decisionLabel, skin: skin),
        const SizedBox(height: 6),
        SizedBox(
          width: 128,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _BranchLabel(label: diagram.yesLabel, skin: skin),
              _BranchLabel(label: diagram.noLabel, skin: skin),
            ],
          ),
        ),
        _Connector(height: 7, skin: skin),
        _PillNode(label: diagram.endLabel, skin: skin),
      ],
    );
  }
}

class _PillNode extends StatelessWidget {
  const _PillNode({required this.label, required this.skin});

  final String label;
  final DiagramSkin skin;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 5),
      decoration: BoxDecoration(
        color: skin.nodeFill,
        borderRadius: BorderRadius.circular(999),
        border: Border.all(
          color: skin.nodeBorder.withValues(alpha: 0.7),
          width: skin.borderWidth,
        ),
        boxShadow: _nodeShadows(skin),
      ),
      child: Text(
        label,
        style: TextStyle(
          color: skin.textColor,
          fontSize: 9.5,
          fontWeight: FontWeight.w600,
          height: 1.2,
        ),
      ),
    );
  }
}

class _ProcessNode extends StatelessWidget {
  const _ProcessNode({required this.label, required this.skin});

  final String label;
  final DiagramSkin skin;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 132,
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: skin.nodeFill,
        borderRadius: BorderRadius.circular(skin.nodeRadius),
        border: Border.all(
          color: skin.nodeBorder.withValues(alpha: 0.7),
          width: skin.borderWidth,
        ),
        boxShadow: _nodeShadows(skin),
      ),
      child: FittedBox(
        fit: BoxFit.scaleDown,
        child: Text(
          label,
          maxLines: 1,
          style: TextStyle(
            color: skin.textColor,
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
  const _DiamondNode({required this.label, required this.skin});

  final String label;
  final DiagramSkin skin;

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
                color: skin.nodeFill,
                borderRadius: BorderRadius.circular(skin.nodeRadius * 0.7),
                border: Border.all(
                  color: skin.nodeBorder.withValues(alpha: 0.7),
                  width: skin.borderWidth,
                ),
                boxShadow: _nodeShadows(skin),
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
                style: TextStyle(
                  color: skin.textColor,
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
  const _BranchLabel({required this.label, required this.skin});

  final String label;
  final DiagramSkin skin;

  @override
  Widget build(BuildContext context) {
    return Text(
      label,
      style: TextStyle(
        color: skin.textColor.withValues(alpha: 0.68),
        fontSize: 8.5,
        fontWeight: FontWeight.w500,
      ),
    );
  }
}

class _Connector extends StatelessWidget {
  const _Connector({required this.height, required this.skin});

  final double height;
  final DiagramSkin skin;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 1.2,
      height: height,
      color: skin.nodeBorder.withValues(alpha: 0.5),
    );
  }
}

List<BoxShadow> _nodeShadows(DiagramSkin skin) {
  if (!skin.glow) {
    return const [];
  }

  return [
    BoxShadow(
      color: skin.nodeBorder.withValues(alpha: 0.38),
      blurRadius: 10,
      spreadRadius: 1,
    ),
  ];
}

class _DotGridPainter extends CustomPainter {
  const _DotGridPainter({required this.color});

  final Color color;

  static const _spacing = 13.0;
  static const _dotRadius = 0.9;

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..color = color.withValues(alpha: 0.6);

    for (double x = _spacing / 2; x < size.width; x += _spacing) {
      for (double y = _spacing / 2; y < size.height; y += _spacing) {
        canvas.drawCircle(Offset(x, y), _dotRadius, paint);
      }
    }
  }

  @override
  bool shouldRepaint(_DotGridPainter oldDelegate) => oldDelegate.color != color;
}
