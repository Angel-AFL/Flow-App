import 'dart:typed_data';

import 'package:flutter/material.dart';

import '../../../shared/models/diagram_skin.dart';
import '../../../shared/models/diagram_spec.dart';
import '../../../shared/models/profile_title.dart';

class UserProfile {
  const UserProfile({
    required this.id,
    required this.displayName,
    required this.username,
    required this.role,
    required this.xp,
    required this.level,
    required this.nextLevelXp,
    required this.streakDays,
    required this.lessonsCompleted,
    this.lastActivityDate,
    this.avatarUrl,
    this.coins = 240,
    this.equippedSkin = DiagramSkin.classic,
    this.equippedTitle = ProfileTitle.novice,
  });

  final String id;
  final String displayName;
  final String username;
  final String role;
  final String? avatarUrl;
  final int xp;
  final int level;
  final int nextLevelXp;
  final int streakDays;
  final int lessonsCompleted;
  final DateTime? lastActivityDate;
  final int coins;
  final DiagramSkin equippedSkin;
  final ProfileTitle equippedTitle;

  static const int xpPerLevel = 500;

  double get levelProgress {
    if (nextLevelXp <= 0) {
      return 0;
    }

    final levelStart = (level - 1) * xpPerLevel;
    final span = nextLevelXp - levelStart;

    if (span <= 0) {
      return 0;
    }

    return ((xp - levelStart) / span).clamp(0.0, 1.0);
  }

  int get effectiveStreakDays {
    final last = lastActivityDate;

    if (last == null) {
      return 0;
    }

    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final lastDay = DateTime(last.year, last.month, last.day);
    final difference = today.difference(lastDay).inDays;

    if (difference < 0 || difference > 1) {
      return 0;
    }

    return streakDays;
  }

  String get initials {
    final words = displayName
        .trim()
        .split(RegExp(r'\s+'))
        .where((word) => word.isNotEmpty)
        .toList();

    if (words.length >= 2) {
      return '${words.first[0]}${words[1][0]}'.toUpperCase();
    }

    if (words.length == 1) {
      final word = words.first;
      return (word.length >= 2 ? word.substring(0, 2) : word).toUpperCase();
    }

    final fallback = username.replaceAll('@', '').trim();
    return (fallback.length >= 2 ? fallback.substring(0, 2) : fallback)
        .toUpperCase();
  }

  UserProfile copyWith({
    String? displayName,
    String? username,
    String? role,
    String? avatarUrl,
    int? xp,
    int? level,
    int? nextLevelXp,
    int? streakDays,
    int? lessonsCompleted,
    DateTime? lastActivityDate,
    int? coins,
    DiagramSkin? equippedSkin,
    ProfileTitle? equippedTitle,
  }) {
    return UserProfile(
      id: id,
      displayName: displayName ?? this.displayName,
      username: username ?? this.username,
      role: role ?? this.role,
      avatarUrl: avatarUrl ?? this.avatarUrl,
      xp: xp ?? this.xp,
      level: level ?? this.level,
      nextLevelXp: nextLevelXp ?? this.nextLevelXp,
      streakDays: streakDays ?? this.streakDays,
      lessonsCompleted: lessonsCompleted ?? this.lessonsCompleted,
      lastActivityDate: lastActivityDate ?? this.lastActivityDate,
      coins: coins ?? this.coins,
      equippedSkin: equippedSkin ?? this.equippedSkin,
      equippedTitle: equippedTitle ?? this.equippedTitle,
    );
  }
}

class ProfileAchievement {
  const ProfileAchievement({
    required this.code,
    required this.label,
    required this.icon,
    this.description,
    this.unlocked = false,
  });

  final String code;
  final String label;
  final String? description;
  final IconData icon;
  final bool unlocked;
}

class ProfileDiagram {
  const ProfileDiagram({
    required this.id,
    required this.title,
    required this.diagram,
  });

  final String id;
  final String title;
  final DiagramSpec diagram;
}

class ProfileSnapshot {
  const ProfileSnapshot({
    required this.profile,
    required this.achievements,
    required this.activityWeeks,
    required this.diagrams,
  });

  final UserProfile profile;
  final List<ProfileAchievement> achievements;

  /// [week][weekday], cinco semanas de lunes a domingo.
  final List<List<int>> activityWeeks;
  final List<ProfileDiagram> diagrams;

  int get unlockedAchievements =>
      achievements.where((achievement) => achievement.unlocked).length;

  int get totalAchievements => achievements.length;

  bool get hasActivity =>
      activityWeeks.any((week) => week.any((level) => level > 0));

  ProfileSnapshot copyWith({UserProfile? profile}) {
    return ProfileSnapshot(
      profile: profile ?? this.profile,
      achievements: achievements,
      activityWeeks: activityWeeks,
      diagrams: diagrams,
    );
  }
}

class ProfileEdit {
  const ProfileEdit({required this.displayName, required this.username});

  final String displayName;
  final String username;
}

class PickedProfileImage {
  const PickedProfileImage({
    required this.bytes,
    required this.extension,
    this.mimeType,
  });

  final Uint8List bytes;
  final String extension;
  final String? mimeType;
}

class AvatarUploadResult {
  const AvatarUploadResult({required this.url, required this.path});

  final String url;
  final String path;
}
