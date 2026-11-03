import 'dart:async';

import 'package:flow_app/features/learn/models/diagram_lesson.dart';
import 'package:flow_app/features/learn/models/learning_models.dart';
import 'package:flow_app/features/learn/repositories/learning_repository.dart';

const _start = DiagramBlock(
  id: 'start',
  kind: DiagramBlockKind.start,
  label: 'Inicio',
);

const _end = DiagramBlock(id: 'end', kind: DiagramBlockKind.end, label: 'Fin');

LearningSnapshot demoLearningSnapshot() {
  return LearningSnapshot(
    units: [
      LearningUnit(
        id: 'unit-1',
        title: 'Diagramas lineales',
        description: 'Aprende qué es un diagrama de flujo.',
        sortOrder: 1,
        lessons: [
          _lesson(
            id: 'unit-1-lesson-1',
            number: 1,
            title: '¿Qué es un diagrama de flujo?',
            concept:
                'Un diagrama de flujo representa un proceso como una '
                'secuencia de pasos.',
            instructions: 'Ordena los bloques para representar un saludo.',
            blocks: const [
              _start,
              DiagramBlock(
                id: 'hello',
                kind: DiagramBlockKind.process,
                label: 'Mostrar Hola',
              ),
              _end,
            ],
            sortOrder: 1,
            completed: true,
          ),
          _lesson(
            id: 'unit-1-lesson-2',
            number: 2,
            title: 'Conoce los símbolos',
            concept:
                'Los óvalos representan el inicio y el fin. Los rectángulos '
                'representan procesos.',
            instructions: 'Arma el flujo para leer un nombre y mostrarlo.',
            blocks: const [
              _start,
              DiagramBlock(
                id: 'read_name',
                kind: DiagramBlockKind.process,
                label: 'Leer nombre',
              ),
              DiagramBlock(
                id: 'show_name',
                kind: DiagramBlockKind.process,
                label: 'Mostrar nombre',
              ),
              _end,
            ],
            sortOrder: 2,
            completed: true,
          ),
          _lesson(
            id: 'unit-1-lesson-3',
            number: 3,
            title: 'Tu primer diagrama',
            concept:
                'Todo diagrama necesita un inicio, al menos un paso y un fin.',
            instructions:
                'Toca los bloques para colocarlos en el diagrama. Todo flujo '
                'empieza en Inicio y termina en Fin.',
            blocks: const [
              _start,
              DiagramBlock(
                id: 'process',
                kind: DiagramBlockKind.process,
                label: 'Mostrar mensaje',
              ),
              _end,
            ],
            sortOrder: 3,
          ),
          _lesson(
            id: 'unit-1-lesson-4',
            number: 4,
            title: 'Una secuencia completa',
            concept:
                'Los pasos se ejecutan en orden. Cada paso recibe el resultado '
                'del anterior.',
            instructions: 'Ordena el proceso para calcular el doble.',
            blocks: const [
              _start,
              DiagramBlock(
                id: 'read_number',
                kind: DiagramBlockKind.process,
                label: 'Leer número',
              ),
              DiagramBlock(
                id: 'double',
                kind: DiagramBlockKind.process,
                label: 'Calcular doble',
              ),
              DiagramBlock(
                id: 'show_result',
                kind: DiagramBlockKind.process,
                label: 'Mostrar resultado',
              ),
              _end,
            ],
            sortOrder: 4,
          ),
        ],
      ),
      const LearningUnit(
        id: 'unit-2',
        title: 'Condicionales — If / Else',
        description: 'Toma decisiones dentro de un flujo.',
        sortOrder: 2,
        lessons: [],
      ),
      const LearningUnit(
        id: 'unit-3',
        title: 'Ciclos — While / For',
        description: 'Repite pasos mientras se cumpla una condición.',
        sortOrder: 3,
        lessons: [],
      ),
      const LearningUnit(
        id: 'unit-4',
        title: 'Funciones',
        description: 'Agrupa pasos reutilizables.',
        sortOrder: 4,
        lessons: [],
      ),
      const LearningUnit(
        id: 'unit-5',
        title: 'Recursividad',
        description: 'Resuelve problemas que se llaman a sí mismos.',
        sortOrder: 5,
        lessons: [],
      ),
    ],
  );
}

LearningSnapshot demoFreshLearningSnapshot() {
  final snapshot = demoLearningSnapshot();

  return snapshot.copyWith(
    units: snapshot.units
        .map(
          (unit) => unit.copyWith(
            lessons: unit.lessons
                .map((lesson) => lesson.copyWith(completed: false))
                .toList(),
          ),
        )
        .toList(),
  );
}

LearningLesson _lesson({
  required String id,
  required int number,
  required String title,
  required String concept,
  required String instructions,
  required List<DiagramBlock> blocks,
  required int sortOrder,
  bool completed = false,
}) {
  return LearningLesson(
    id: id,
    unitId: 'unit-1',
    number: number,
    title: title,
    concept: concept,
    instructions: instructions,
    xpReward: 50,
    coinReward: 25,
    blocks: blocks,
    sortOrder: sortOrder,
    completed: completed,
  );
}

class FakeLearningRepository implements LearningRepository {
  FakeLearningRepository({
    LearningSnapshot? snapshot,
    this.loadFailure,
    this.completionFailure,
  }) : snapshot = snapshot ?? demoLearningSnapshot();

  LearningSnapshot snapshot;
  LearningFailure? loadFailure;
  LearningFailure? completionFailure;

  Completer<LearningSnapshot>? pendingLoad;
  int loadCalls = 0;
  String? lastLessonId;
  DateTime? lastLocalDate;
  int coins = 240;
  int xp = 100;
  int streakDays = 1;

  @override
  Future<LearningSnapshot> loadLearningPath(String userId) {
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
  Future<LessonCompletionResult> completeLesson({
    required String lessonId,
    required DateTime localDate,
  }) async {
    final failure = completionFailure;
    if (failure != null) {
      throw failure;
    }

    lastLessonId = lessonId;
    lastLocalDate = localDate;

    LearningLesson? target;

    for (final unit in snapshot.units) {
      for (final lesson in unit.lessons) {
        if (lesson.id == lessonId) {
          target = lesson;
          break;
        }
      }
    }

    if (target == null) {
      throw const LearningFailure('Esta lección ya no está disponible.');
    }

    if (target.completed) {
      return _result(alreadyCompleted: true);
    }

    coins += 25;
    xp += 50;
    streakDays = streakDays == 0 ? 1 : streakDays;

    final units = snapshot.units.map((unit) {
      if (!unit.lessons.any((lesson) => lesson.id == lessonId)) {
        return unit;
      }

      return unit.copyWith(
        lessons: unit.lessons
            .map(
              (lesson) => lesson.id == lessonId
                  ? lesson.copyWith(completed: true)
                  : lesson,
            )
            .toList(),
      );
    }).toList();

    snapshot = snapshot.copyWith(units: units);

    return _result(alreadyCompleted: false);
  }

  LessonCompletionResult _result({required bool alreadyCompleted}) {
    final level = (xp ~/ 500) + 1;

    return LessonCompletionResult(
      alreadyCompleted: alreadyCompleted,
      xpAwarded: alreadyCompleted ? 0 : 50,
      coinsAwarded: alreadyCompleted ? 0 : 25,
      totalXp: xp,
      level: level,
      nextLevelXp: level * 500,
      lessonsCompleted: snapshot.completedLessons,
      streakDays: streakDays,
      coins: coins,
    );
  }
}
