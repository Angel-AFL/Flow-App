import 'package:flutter/material.dart';

class ProfileTitle {
  const ProfileTitle({
    required this.code,
    required this.label,
    required this.color,
    required this.icon,
  });

  final String code;
  final String label;
  final Color color;
  final IconData icon;

  static const novice = ProfileTitle(
    code: 'title_novice',
    label: 'Novato',
    color: Color(0xFFB6C8D9),
    icon: Icons.military_tech_rounded,
  );

  factory ProfileTitle.fromPayload({
    required String code,
    required String name,
    required Map<String, dynamic> payload,
  }) {
    final label = (payload['label'] as String?)?.trim();

    return ProfileTitle(
      code: code,
      label: label == null || label.isEmpty ? name : label,
      color: _colorFrom(payload['color'], novice.color),
      icon: _iconFor(payload['icon'] as String?),
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

  static IconData _iconFor(String? key) {
    return switch (key) {
      'military_tech' => Icons.military_tech_rounded,
      'explore' => Icons.explore_rounded,
      'architecture' => Icons.architecture_rounded,
      'loop' => Icons.loop_rounded,
      'auto_awesome' => Icons.auto_awesome_rounded,
      'code' => Icons.code_rounded,
      'groups' => Icons.groups_rounded,
      _ => Icons.military_tech_rounded,
    };
  }
}
