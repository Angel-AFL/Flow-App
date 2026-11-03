import 'package:flutter/material.dart';

class DiagramSkin {
  const DiagramSkin({
    required this.code,
    required this.name,
    required this.background,
    required this.gridColor,
    required this.nodeFill,
    required this.nodeBorder,
    required this.textColor,
    required this.accent,
    this.nodeRadius = 6,
    this.borderWidth = 1.2,
    this.glow = false,
  });

  final String code;
  final String name;
  final Color background;
  final Color gridColor;
  final Color nodeFill;
  final Color nodeBorder;
  final Color textColor;
  final Color accent;
  final double nodeRadius;
  final double borderWidth;
  final bool glow;

  static const classic = DiagramSkin(
    code: 'skin_classic',
    name: 'Clásico',
    background: Color(0xFF0D1A2A),
    gridColor: Color(0xFF2B4A63),
    nodeFill: Color(0xFF14283C),
    nodeBorder: Color(0xFF38BDF8),
    textColor: Color(0xFFEDFBFF),
    accent: Color(0xFF38BDF8),
  );

  factory DiagramSkin.fromPayload({
    required String code,
    required String name,
    required Map<String, dynamic> payload,
  }) {
    if (code == classic.code) {
      return classic;
    }

    return DiagramSkin(
      code: code,
      name: name,
      background: _colorFrom(payload['background'], classic.background),
      gridColor: _colorFrom(payload['grid'], classic.gridColor),
      nodeFill: _colorFrom(payload['nodeFill'], classic.nodeFill),
      nodeBorder: _colorFrom(payload['nodeBorder'], classic.nodeBorder),
      textColor: _colorFrom(payload['text'], classic.textColor),
      accent: _colorFrom(payload['accent'], classic.accent),
      nodeRadius: _doubleFrom(payload['nodeRadius'], classic.nodeRadius),
      borderWidth: _doubleFrom(payload['borderWidth'], classic.borderWidth),
      glow: payload['glow'] == true,
    );
  }

  static Color _colorFrom(Object? value, Color fallback) {
    if (value is! String || value.trim().isEmpty) {
      return fallback;
    }

    final hex = value.trim().replaceFirst('#', '');
    final normalized = hex.length == 6 ? 'FF$hex' : hex;

    if (normalized.length != 8) {
      return fallback;
    }

    final parsed = int.tryParse(normalized, radix: 16);

    return parsed == null ? fallback : Color(parsed);
  }

  static double _doubleFrom(Object? value, double fallback) {
    if (value is num) {
      return value.toDouble();
    }

    if (value is String) {
      return double.tryParse(value) ?? fallback;
    }

    return fallback;
  }
}
