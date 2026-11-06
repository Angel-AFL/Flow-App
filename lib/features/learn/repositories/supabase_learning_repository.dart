import 'package:supabase_flutter/supabase_flutter.dart';

import '../models/diagram_lesson.dart';
import '../models/learning_models.dart';
import 'learning_repository.dart';

class SupabaseLearningRepository implements LearningRepository {
  SupabaseLearningRepository(this._client);

  final SupabaseClient _client;

  @override
  Future<LearningSnapshot> loadLearningPath(String userId) async {
    try {
      final results = await Future.wait<dynamic>([
        _client
            .from('units')
            .select('id, title, description, sort_order')
            .eq('is_active', true)
            .order('sort_order'),
        _client
            .from('lessons')
            .select(
              'id, unit_id, number, title, concept, instructions, '
              'content, sort_order, is_active',
            )
            .eq('is_active', true)
            .order('sort_order'),
        _client.from('lesson_rewards').select('lesson_id, coins, xp'),
        _client
            .from('lesson_completions')
            .select('lesson_id')
            .eq('user_id', userId),
      ]);

      final unitRows = (results[0] as List).cast<Map<String, dynamic>>();
      final lessonRows = (results[1] as List).cast<Map<String, dynamic>>();
      final rewardRows = (results[2] as List).cast<Map<String, dynamic>>();
      final completionRows = (results[3] as List).cast<Map<String, dynamic>>();

      final rewards = <String, Map<String, dynamic>>{
        for (final row in rewardRows) row['lesson_id'] as String: row,
      };

      final completedIds = completionRows
          .map((row) => row['lesson_id'] as String)
          .toSet();

      final lessonsByUnit = <String, List<LearningLesson>>{};

      for (final row in lessonRows) {
        final id = row['id'] as String;
        final unitId = row['unit_id'] as String;
        final content = _contentMap(row['content']);
        final exercise = _exerciseFrom(content['exercise']);
        final blocks = _blocksFrom(content);

        if (exercise == LessonExerciseKind.order && blocks.isEmpty) {
          continue;
        }

        final options = _optionsFrom(content['options']);

        if (exercise != LessonExerciseKind.order && options.isEmpty) {
          continue;
        }

        final reward = rewards[id];

        lessonsByUnit
            .putIfAbsent(unitId, () => [])
            .add(
              LearningLesson(
                id: id,
                unitId: unitId,
                number: (row['number'] as num?)?.toInt() ?? 0,
                title: row['title'] as String? ?? 'Lección',
                concept: row['concept'] as String? ?? '',
                instructions: row['instructions'] as String? ?? '',
                xpReward: (reward?['xp'] as num?)?.toInt() ?? 50,
                coinReward: (reward?['coins'] as num?)?.toInt() ?? 0,
                blocks: blocks,
                sortOrder: (row['sort_order'] as num?)?.toInt() ?? 0,
                completed: completedIds.contains(id),
                exercise: exercise,
                question: content['question'] as String? ?? '',
                options: options,
                correctOptionId: content['correct'] as String?,
                explanation: content['explanation'] as String? ?? '',
                snippet: content['snippet'] as String?,
              ),
            );
      }

      for (final lessons in lessonsByUnit.values) {
        lessons.sort(
          (first, second) => first.sortOrder.compareTo(second.sortOrder),
        );
      }

      final units = unitRows
          .map(
            (row) => LearningUnit(
              id: row['id'] as String,
              title: row['title'] as String? ?? 'Unidad',
              description: row['description'] as String?,
              sortOrder: (row['sort_order'] as num?)?.toInt() ?? 0,
              lessons: lessonsByUnit[row['id'] as String] ?? const [],
            ),
          )
          .toList();

      return LearningSnapshot(units: units);
    } on PostgrestException catch (error) {
      throw _failureFor(
        error,
        fallback: 'No pudimos cargar las lecciones. Inténtalo de nuevo.',
      );
    } on LearningFailure {
      rethrow;
    } on AuthException {
      throw const LearningFailure('Tu sesión expiró. Vuelve a iniciar sesión.');
    } catch (_) {
      throw const LearningFailure(
        'No pudimos conectar con el servidor. Revisa tu conexión.',
      );
    }
  }

  @override
  Future<LessonCompletionResult> completeLesson({
    required String lessonId,
    required DateTime localDate,
  }) async {
    try {
      final data = await _client.rpc(
        'complete_lesson',
        params: {'p_lesson_id': lessonId, 'p_local_date': _dateKey(localDate)},
      );

      return LessonCompletionResult.fromRow(_firstRow(data));
    } on PostgrestException catch (error) {
      throw _failureFor(
        error,
        fallback: 'No pudimos guardar el progreso. Inténtalo de nuevo.',
      );
    } on LearningFailure {
      rethrow;
    } on AuthException {
      throw const LearningFailure('Tu sesión expiró. Vuelve a iniciar sesión.');
    } catch (_) {
      throw const LearningFailure(
        'No pudimos conectar con el servidor. Revisa tu conexión.',
      );
    }
  }

  static Map<String, dynamic> _contentMap(dynamic value) {
    if (value is! Map) {
      return const {};
    }

    return value.cast<String, dynamic>();
  }

  static LessonExerciseKind _exerciseFrom(dynamic value) {
    return switch (value) {
      'choice' => LessonExerciseKind.choice,
      'trace' => LessonExerciseKind.trace,
      _ => LessonExerciseKind.order,
    };
  }

  static List<LessonOption> _optionsFrom(dynamic value) {
    if (value is! List) {
      return const [];
    }

    final options = <LessonOption>[];

    for (final raw in value) {
      if (raw is! Map) {
        continue;
      }

      final id = raw['id'];
      final label = raw['label'];

      if (id is! String || label is! String) {
        continue;
      }

      options.add(LessonOption(id: id, label: label));
    }

    return options;
  }

  static List<DiagramBlock> _blocksFrom(Map<String, dynamic> content) {
    final rawBlocks = content['blocks'];

    if (rawBlocks is! List) {
      return const [];
    }

    final blocks = <DiagramBlock>[];

    for (final raw in rawBlocks) {
      if (raw is! Map) {
        continue;
      }

      final id = raw['id'];
      final label = raw['label'];

      if (id is! String || label is! String) {
        continue;
      }

      blocks.add(
        DiagramBlock(
          id: id,
          kind: _kindFrom(raw['kind']),
          label: label,
          yesLabel: raw['yesLabel'] as String?,
          noLabel: raw['noLabel'] as String?,
        ),
      );
    }

    return blocks;
  }

  static DiagramBlockKind _kindFrom(dynamic value) {
    return switch (value) {
      'start' => DiagramBlockKind.start,
      'decision' => DiagramBlockKind.decision,
      'end' => DiagramBlockKind.end,
      _ => DiagramBlockKind.process,
    };
  }

  static String _dateKey(DateTime date) {
    final year = date.year.toString().padLeft(4, '0');
    final month = date.month.toString().padLeft(2, '0');
    final day = date.day.toString().padLeft(2, '0');
    return '$year-$month-$day';
  }

  static Map<String, dynamic> _firstRow(dynamic data) {
    if (data is List) {
      if (data.isEmpty) {
        throw const LearningFailure('El servidor no devolvió una respuesta.');
      }

      return (data.first as Map).cast<String, dynamic>();
    }

    if (data is Map) {
      return data.cast<String, dynamic>();
    }

    throw const LearningFailure('El servidor no devolvió una respuesta.');
  }

  static LearningFailure _failureFor(
    PostgrestException error, {
    required String fallback,
  }) {
    final message = error.message;

    if (message.contains('lesson_locked')) {
      return const LearningFailure(
        'Completa la lección anterior para desbloquear esta.',
      );
    }

    if (message.contains('unit_locked')) {
      return const LearningFailure(
        'Completa la unidad anterior para desbloquear esta lección.',
      );
    }

    if (message.contains('lesson_not_found')) {
      return const LearningFailure('Esta lección ya no está disponible.');
    }

    if (message.contains('not_authenticated')) {
      return const LearningFailure(
        'Tu sesión expiró. Vuelve a iniciar sesión.',
      );
    }

    if (message.contains('profile_not_found')) {
      return const LearningFailure(
        'No encontramos tu perfil. Vuelve a iniciar sesión.',
      );
    }

    return LearningFailure(fallback);
  }
}
