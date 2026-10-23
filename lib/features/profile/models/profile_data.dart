import 'package:flutter/material.dart';

import '../../../shared/models/diagram_spec.dart';

class ProfileAchievement {
  const ProfileAchievement({
    required this.label,
    required this.icon,
    this.unlocked = true,
  });

  final String label;
  final IconData icon;
  final bool unlocked;
}

class ProfileDiagram {
  const ProfileDiagram({required this.title, required this.diagram});

  final String title;
  final DiagramSpec diagram;
}

abstract final class ProfileMockData {
  static const name = 'Estudiante Flow';
  static const handle = '@flowstudent';
  static const role = 'Aprendiz';
  static const initials = 'EF';
  static const level = 8;
  static const xp = 1250;
  static const nextLevelXp = 1500;
  static const streak = 7;
  static const lessons = 8;
  static const unlockedAchievements = 3;
  static const totalAchievements = 12;

  static const achievements = <ProfileAchievement>[
    ProfileAchievement(label: 'Primer paso', icon: Icons.emoji_events_rounded),
    ProfileAchievement(label: 'Mente lógica', icon: Icons.psychology_rounded),
    ProfileAchievement(
      label: 'Constancia',
      icon: Icons.local_fire_department_rounded,
    ),
    ProfileAchievement(
      label: 'Código limpio',
      icon: Icons.lock_rounded,
      unlocked: false,
    ),
  ];

  static const activity = <List<int>>[
    [2, 1, 0, 3, 2],
    [0, 2, 1, 0, 3],
    [1, 0, 2, 1, 0],
    [3, 1, 0, 2, 1],
    [0, 2, 1, 0, 3],
  ];

  static const diagrams = <ProfileDiagram>[
    ProfileDiagram(
      title: 'Mi primer diagrama',
      diagram: DiagramSpec(type: DiagramPreviewType.linear),
    ),
    ProfileDiagram(
      title: '¿Es un número positivo?',
      diagram: DiagramSpec(
        type: DiagramPreviewType.decision,
        decisionLabel: 'Es > 0',
      ),
    ),
  ];
}
