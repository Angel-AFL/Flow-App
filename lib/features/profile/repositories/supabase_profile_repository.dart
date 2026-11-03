import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../shared/models/diagram_skin.dart';
import '../../../shared/models/diagram_spec.dart';
import '../../../shared/models/profile_title.dart';
import '../models/profile_models.dart';
import '../utils/activity_weeks.dart';
import 'profile_repository.dart';

class SupabaseProfileRepository implements ProfileRepository {
  SupabaseProfileRepository(this._client);

  final SupabaseClient _client;

  static const _avatarBucket = 'avatars';

  @override
  Future<ProfileSnapshot> loadProfile(String userId) async {
    final activityStart = startOfActivityWindow(DateTime.now());

    try {
      final results = await Future.wait<dynamic>([
        _client.from('profiles').select().eq('id', userId).single(),
        _client
            .from('achievements')
            .select('code, title, description, icon, sort_order')
            .order('sort_order'),
        _client
            .from('user_achievements')
            .select('achievement_code')
            .eq('user_id', userId),
        _client
            .from('diagrams')
            .select()
            .eq('user_id', userId)
            .order('created_at', ascending: false),
        _client
            .from('daily_activity')
            .select('activity_date, activity_count')
            .eq('user_id', userId)
            .gte('activity_date', formatDateKey(activityStart)),
      ]);

      final profileRow = results[0] as Map<String, dynamic>;
      final achievementRows = (results[1] as List).cast<Map<String, dynamic>>();
      final unlockedRows = (results[2] as List).cast<Map<String, dynamic>>();
      final diagramRows = (results[3] as List).cast<Map<String, dynamic>>();
      final activityRows = (results[4] as List).cast<Map<String, dynamic>>();

      final unlockedCodes = unlockedRows
          .map((row) => row['achievement_code'] as String)
          .toSet();

      final countsByDate = <String, int>{
        for (final row in activityRows)
          row['activity_date'] as String: (row['activity_count'] as num? ?? 0)
              .toInt(),
      };

      final equipped = await _loadEquipped(profileRow);

      return ProfileSnapshot(
        profile: _mapProfile(
          profileRow,
          equippedSkin: equipped.$1,
          equippedTitle: equipped.$2,
        ),
        achievements: achievementRows
            .map(
              (row) => _mapAchievement(
                row,
                unlocked: unlockedCodes.contains(row['code'] as String),
              ),
            )
            .toList(),
        activityWeeks: buildActivityWeeks(
          countsByDate: countsByDate,
          startMonday: activityStart,
        ),
        diagrams: diagramRows.map(_mapDiagram).toList(),
      );
    } on PostgrestException catch (error) {
      throw _failureFor(
        error,
        fallback: 'No pudimos cargar tu perfil. Inténtalo de nuevo.',
      );
    } on AuthException {
      throw const ProfileFailure('Tu sesión expiró. Vuelve a iniciar sesión.');
    } catch (_) {
      throw const ProfileFailure(
        'No pudimos conectar con el servidor. Revisa tu conexión.',
      );
    }
  }

  @override
  Future<UserProfile> updateProfile({
    required String userId,
    required ProfileEdit edit,
  }) async {
    final displayName = edit.displayName.trim();
    final username = edit.username.trim().toLowerCase().replaceFirst(
      RegExp(r'^@+'),
      '',
    );

    try {
      final row = await _client
          .from('profiles')
          .update({'display_name': displayName, 'username': username})
          .eq('id', userId)
          .select()
          .single();

      final equipped = await _loadEquipped(row);

      return _mapProfile(
        row,
        equippedSkin: equipped.$1,
        equippedTitle: equipped.$2,
      );
    } on PostgrestException catch (error) {
      throw _failureFor(
        error,
        fallback: 'No pudimos guardar los cambios. Inténtalo de nuevo.',
      );
    } on AuthException {
      throw const ProfileFailure('Tu sesión expiró. Vuelve a iniciar sesión.');
    } catch (_) {
      throw const ProfileFailure(
        'No pudimos conectar con el servidor. Revisa tu conexión.',
      );
    }
  }

  @override
  Future<AvatarUploadResult> uploadAvatar({
    required String userId,
    required PickedProfileImage image,
  }) async {
    final extension = _safeExtension(image.extension);
    final path =
        '$userId/avatar-${DateTime.now().millisecondsSinceEpoch}.$extension';

    try {
      final currentRow = await _client
          .from('profiles')
          .select('avatar_path')
          .eq('id', userId)
          .single();
      final previousPath = currentRow['avatar_path'] as String?;

      await _client.storage
          .from(_avatarBucket)
          .uploadBinary(
            path,
            image.bytes,
            fileOptions: FileOptions(
              contentType: _contentTypeFor(image),
              upsert: false,
            ),
          );

      await _client
          .from('profiles')
          .update({'avatar_path': path})
          .eq('id', userId);

      if (previousPath != null && previousPath.isNotEmpty) {
        try {
          await _client.storage.from(_avatarBucket).remove([previousPath]);
        } catch (_) {
          // La foto nueva ya está guardada; limpiar la anterior es opcional.
        }
      }

      return AvatarUploadResult(
        url: _client.storage.from(_avatarBucket).getPublicUrl(path),
        path: path,
      );
    } on StorageException {
      throw const ProfileFailure(
        'No pudimos subir la foto. Inténtalo de nuevo.',
      );
    } on PostgrestException catch (error) {
      throw _failureFor(
        error,
        fallback: 'No pudimos guardar la foto. Inténtalo de nuevo.',
      );
    } on AuthException {
      throw const ProfileFailure('Tu sesión expiró. Vuelve a iniciar sesión.');
    } catch (_) {
      throw const ProfileFailure(
        'No pudimos conectar con el servidor. Revisa tu conexión.',
      );
    }
  }

  Future<(DiagramSkin, ProfileTitle)> _loadEquipped(
    Map<String, dynamic> row,
  ) async {
    final skinCode = (row['equipped_skin_code'] as String?)?.trim();
    final titleCode = (row['equipped_title_code'] as String?)?.trim();
    final codes = <String>{
      if (skinCode != null && skinCode.isNotEmpty) skinCode,
      if (titleCode != null && titleCode.isNotEmpty) titleCode,
    }.toList();

    if (codes.isEmpty) {
      return (DiagramSkin.classic, ProfileTitle.novice);
    }

    try {
      final rows =
          (await _client
                  .from('store_items')
                  .select('code, name, payload')
                  .inFilter('code', codes))
              .cast<Map<String, dynamic>>();

      return (_skinFromRows(skinCode, rows), _titleFromRows(titleCode, rows));
    } catch (_) {
      return (DiagramSkin.classic, ProfileTitle.novice);
    }
  }

  static DiagramSkin _skinFromRows(
    String? code,
    List<Map<String, dynamic>> rows,
  ) {
    if (code == null || code.isEmpty) {
      return DiagramSkin.classic;
    }

    for (final row in rows) {
      if (row['code'] == code) {
        return DiagramSkin.fromPayload(
          code: code,
          name: row['name'] as String? ?? 'Clásico',
          payload: (row['payload'] as Map?)?.cast<String, dynamic>() ?? {},
        );
      }
    }

    return DiagramSkin.classic;
  }

  static ProfileTitle _titleFromRows(
    String? code,
    List<Map<String, dynamic>> rows,
  ) {
    if (code == null || code.isEmpty) {
      return ProfileTitle.novice;
    }

    for (final row in rows) {
      if (row['code'] == code) {
        return ProfileTitle.fromPayload(
          code: code,
          name: row['name'] as String? ?? 'Novato',
          payload: (row['payload'] as Map?)?.cast<String, dynamic>() ?? {},
        );
      }
    }

    return ProfileTitle.novice;
  }

  UserProfile _mapProfile(
    Map<String, dynamic> row, {
    required DiagramSkin equippedSkin,
    required ProfileTitle equippedTitle,
  }) {
    final avatarPath = (row['avatar_path'] as String?)?.trim();
    final displayName =
        (row['display_name'] as String?)?.trim().isNotEmpty == true
        ? (row['display_name'] as String).trim()
        : 'Estudiante Flow';
    final username = (row['username'] as String?)?.trim().isNotEmpty == true
        ? (row['username'] as String).trim()
        : 'flowuser';

    return UserProfile(
      id: row['id'] as String,
      displayName: displayName,
      username: username.replaceFirst(RegExp(r'^@+'), ''),
      role: (row['role'] as String?)?.trim().isNotEmpty == true
          ? (row['role'] as String).trim()
          : 'Aprendiz',
      avatarUrl: avatarPath == null || avatarPath.isEmpty
          ? null
          : _client.storage.from(_avatarBucket).getPublicUrl(avatarPath),
      xp: (row['xp'] as num?)?.toInt() ?? 0,
      level: (row['level'] as num?)?.toInt() ?? 1,
      nextLevelXp: (row['next_level_xp'] as num?)?.toInt() ?? 500,
      streakDays: (row['streak_days'] as num?)?.toInt() ?? 0,
      lessonsCompleted: (row['lessons_completed'] as num?)?.toInt() ?? 0,
      coins: (row['coins'] as num?)?.toInt() ?? 240,
      equippedSkin: equippedSkin,
      equippedTitle: equippedTitle,
    );
  }

  static ProfileAchievement _mapAchievement(
    Map<String, dynamic> row, {
    required bool unlocked,
  }) {
    return ProfileAchievement(
      code: row['code'] as String,
      label: (row['title'] as String?)?.trim().isNotEmpty == true
          ? (row['title'] as String).trim()
          : 'Logro',
      description: row['description'] as String?,
      icon: _iconFor(row['icon'] as String?),
      unlocked: unlocked,
    );
  }

  static ProfileDiagram _mapDiagram(Map<String, dynamic> row) {
    return ProfileDiagram(
      id: row['id'] as String,
      title: (row['title'] as String?)?.trim().isNotEmpty == true
          ? (row['title'] as String).trim()
          : 'Diagrama',
      diagram: DiagramSpec(
        type: row['kind'] == 'decision'
            ? DiagramPreviewType.decision
            : DiagramPreviewType.linear,
        startLabel: row['start_label'] as String? ?? 'Inicio',
        processLabel: row['process_label'] as String? ?? 'Mostrar mensaje',
        decisionLabel: row['decision_label'] as String? ?? 'Es > 0',
        yesLabel: row['yes_label'] as String? ?? 'Sí',
        noLabel: row['no_label'] as String? ?? 'No',
        endLabel: row['end_label'] as String? ?? 'Fin',
      ),
    );
  }

  static IconData _iconFor(String? key) {
    return switch (key) {
      'trophy' => Icons.emoji_events_rounded,
      'psychology' => Icons.psychology_rounded,
      'fire' => Icons.local_fire_department_rounded,
      'code' => Icons.code_rounded,
      'loop' => Icons.loop_rounded,
      'call_split' => Icons.call_split_rounded,
      'functions' => Icons.functions_rounded,
      'autorenew' => Icons.autorenew_rounded,
      'groups' => Icons.groups_rounded,
      'content_copy' => Icons.content_copy_rounded,
      'calendar_month' => Icons.calendar_month_rounded,
      'architecture' => Icons.architecture_rounded,
      _ => Icons.emoji_events_rounded,
    };
  }

  static String _safeExtension(String extension) {
    final cleaned = extension
        .replaceAll('.', '')
        .replaceAll(RegExp(r'[^a-zA-Z0-9]'), '')
        .toLowerCase();

    if (cleaned.isEmpty) {
      return 'jpg';
    }

    return cleaned == 'jpeg' ? 'jpg' : cleaned;
  }

  static String _contentTypeFor(PickedProfileImage image) {
    final mimeType = image.mimeType;
    if (mimeType != null && mimeType.isNotEmpty) {
      return mimeType;
    }

    return switch (_safeExtension(image.extension)) {
      'png' => 'image/png',
      'webp' => 'image/webp',
      'gif' => 'image/gif',
      _ => 'image/jpeg',
    };
  }

  static ProfileFailure _failureFor(
    PostgrestException error, {
    required String fallback,
  }) {
    if (error.code == 'PGRST116') {
      return const ProfileFailure(
        'No encontramos tu perfil. Vuelve a iniciar sesión.',
      );
    }

    if (error.code == '23505') {
      return const ProfileFailure('Ese nombre de usuario ya está en uso.');
    }

    if (error.code == '23514') {
      return const ProfileFailure(
        'Revisa los datos: hay valores que no son válidos.',
      );
    }

    if (error.code == '42501') {
      return const ProfileFailure(
        'No tienes permisos para realizar esta acción.',
      );
    }

    return ProfileFailure(fallback);
  }
}
