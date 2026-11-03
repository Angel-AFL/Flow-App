import 'dart:async';
import 'dart:typed_data';

import 'package:flutter/material.dart';

import 'package:flow_app/features/profile/models/profile_models.dart';
import 'package:flow_app/features/profile/repositories/profile_repository.dart';
import 'package:flow_app/shared/models/diagram_spec.dart';

const demoActivityWeeks = <List<int>>[
  [1, 0, 2, 3, 0, 1, 2],
  [0, 2, 0, 1, 3, 0, 1],
  [2, 1, 3, 0, 1, 2, 0],
  [0, 3, 1, 2, 0, 3, 1],
  [1, 0, 2, 0, 2, 1, 3],
];

const demoAchievements = <ProfileAchievement>[
  ProfileAchievement(
    code: 'first_step',
    label: 'Primer paso',
    icon: Icons.emoji_events_rounded,
    unlocked: true,
  ),
  ProfileAchievement(
    code: 'logic_mind',
    label: 'Mente lógica',
    icon: Icons.psychology_rounded,
    unlocked: true,
  ),
  ProfileAchievement(
    code: 'consistency',
    label: 'Constancia',
    icon: Icons.local_fire_department_rounded,
    unlocked: true,
  ),
  ProfileAchievement(
    code: 'clean_code',
    label: 'Código limpio',
    icon: Icons.code_rounded,
  ),
  ProfileAchievement(
    code: 'loop_master',
    label: 'Rey de los ciclos',
    icon: Icons.loop_rounded,
  ),
  ProfileAchievement(
    code: 'branching',
    label: 'Bifurcación',
    icon: Icons.call_split_rounded,
  ),
  ProfileAchievement(
    code: 'function_fan',
    label: 'Funciones',
    icon: Icons.functions_rounded,
  ),
  ProfileAchievement(
    code: 'recursion',
    label: 'Recursión',
    icon: Icons.autorenew_rounded,
  ),
  ProfileAchievement(
    code: 'community',
    label: 'Comunidad',
    icon: Icons.groups_rounded,
  ),
  ProfileAchievement(
    code: 'remixer',
    label: 'Remixer',
    icon: Icons.content_copy_rounded,
  ),
  ProfileAchievement(
    code: 'streak_30',
    label: 'Mes perfecto',
    icon: Icons.calendar_month_rounded,
  ),
  ProfileAchievement(
    code: 'architect',
    label: 'Arquitecto',
    icon: Icons.architecture_rounded,
  ),
];

const demoDiagrams = <ProfileDiagram>[
  ProfileDiagram(
    id: 'diagram-1',
    title: 'Mi primer diagrama',
    diagram: DiagramSpec(type: DiagramPreviewType.linear),
  ),
  ProfileDiagram(
    id: 'diagram-2',
    title: '¿Es un número positivo?',
    diagram: DiagramSpec(
      type: DiagramPreviewType.decision,
      decisionLabel: 'Es > 0',
    ),
  ),
];

ProfileSnapshot demoProfileSnapshot({
  String displayName = 'Estudiante Flow',
  String username = 'flowstudent',
  List<ProfileDiagram> diagrams = demoDiagrams,
  List<List<int>> activityWeeks = demoActivityWeeks,
}) {
  return ProfileSnapshot(
    profile: UserProfile(
      id: 'user-1',
      displayName: displayName,
      username: username,
      role: 'Aprendiz',
      xp: 1250,
      level: 3,
      nextLevelXp: 1500,
      streakDays: 7,
      lessonsCompleted: 8,
      lastActivityDate: DateTime.now(),
    ),
    achievements: demoAchievements,
    activityWeeks: activityWeeks,
    diagrams: diagrams,
  );
}

class FakeProfileRepository implements ProfileRepository {
  FakeProfileRepository({
    ProfileSnapshot? snapshot,
    this.loadFailure,
    this.updateFailure,
    this.uploadFailure,
  }) : snapshot = snapshot ?? demoProfileSnapshot();

  ProfileSnapshot snapshot;
  ProfileFailure? loadFailure;
  ProfileFailure? updateFailure;
  ProfileFailure? uploadFailure;

  Completer<ProfileSnapshot>? pendingLoad;
  int loadCalls = 0;
  ProfileEdit? lastEdit;
  PickedProfileImage? lastAvatar;

  @override
  Future<ProfileSnapshot> loadProfile(String userId) {
    loadCalls++;

    final failure = loadFailure;
    if (failure != null) {
      return Future.error(failure);
    }

    final pending = pendingLoad;
    if (pending != null) {
      return pending.future;
    }

    return Future.value(snapshot);
  }

  @override
  Future<UserProfile> updateProfile({
    required String userId,
    required ProfileEdit edit,
  }) async {
    final failure = updateFailure;
    if (failure != null) {
      throw failure;
    }

    if (edit.username == 'taken') {
      throw const ProfileFailure('Ese nombre de usuario ya está en uso.');
    }

    lastEdit = edit;

    final updated = snapshot.profile.copyWith(
      displayName: edit.displayName,
      username: edit.username,
    );
    snapshot = snapshot.copyWith(profile: updated);

    return updated;
  }

  @override
  Future<AvatarUploadResult> uploadAvatar({
    required String userId,
    required PickedProfileImage image,
  }) async {
    final failure = uploadFailure;
    if (failure != null) {
      throw failure;
    }

    lastAvatar = image;

    const url = 'https://example.test/avatar.jpg';
    final updated = snapshot.profile.copyWith(avatarUrl: url);
    snapshot = snapshot.copyWith(profile: updated);

    return const AvatarUploadResult(url: url, path: 'user-1/avatar.jpg');
  }
}

PickedProfileImage demoPickedImage() {
  return PickedProfileImage(
    bytes: Uint8List.fromList([1, 2, 3, 4]),
    extension: 'png',
    mimeType: 'image/png',
  );
}
