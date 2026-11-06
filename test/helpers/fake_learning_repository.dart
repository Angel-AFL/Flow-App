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

const _yesOption = LessonOption(id: 'a', label: 'Opción correcta');
const _noOption = LessonOption(id: 'b', label: 'Opción incorrecta');

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
      LearningUnit(
        id: 'unit-2',
        title: 'Condicionales — If / Else',
        description: 'Toma decisiones dentro de un flujo.',
        sortOrder: 2,
        lessons: [
          _lesson(
            id: 'unit-2-lesson-1',
            unitId: 'unit-2',
            number: 1,
            title: '¿Qué es una condición?',
            concept:
                'Una condición es una expresión que solo puede dar verdadero '
                'o falso.',
            instructions: 'Elige la expresión que sea una condición válida.',
            sortOrder: 1,
            exercise: LessonExerciseKind.choice,
            question: '¿Cuál de estas expresiones es una condición?',
            options: const [
              LessonOption(id: 'a', label: 'edad >= 18'),
              LessonOption(id: 'b', label: 'Leer edad'),
            ],
            correctOptionId: 'a',
            explanation: 'Una condición compara valores y da verdadero o falso.',
          ),
          _lesson(
            id: 'unit-2-lesson-2',
            unitId: 'unit-2',
            number: 2,
            title: 'El rombo de decisión',
            concept:
                'El rombo representa una decisión con dos salidas: Sí y No.',
            instructions: 'Ordena el camino cuando la condición es verdadera.',
            sortOrder: 2,
            blocks: const [
              _start,
              DiagramBlock(
                id: 'read_age',
                kind: DiagramBlockKind.process,
                label: 'Leer edad',
              ),
              DiagramBlock(
                id: 'check',
                kind: DiagramBlockKind.decision,
                label: '¿Edad >= 18?',
                yesLabel: 'Sí',
                noLabel: 'No',
              ),
              _end,
            ],
          ),
          _lesson(
            id: 'unit-2-lesson-3',
            unitId: 'unit-2',
            number: 3,
            title: 'If / Else: elige el camino',
            concept:
                'Solo uno de los dos caminos del if/else se ejecuta.',
            instructions: 'Lee el pseudocódigo y elige la salida correcta.',
            sortOrder: 3,
            exercise: LessonExerciseKind.trace,
            snippet: 'edad = 20\nsi edad >= 18:\n  mostrar "Mayor"',
            question: '¿Qué se muestra si edad = 20?',
            options: const [
              LessonOption(id: 'a', label: 'Mayor'),
              LessonOption(id: 'b', label: 'Menor'),
            ],
            correctOptionId: 'a',
            explanation: '20 >= 18 es verdadero y se ejecuta el if.',
          ),
          _lesson(
            id: 'unit-2-lesson-4',
            unitId: 'unit-2',
            number: 4,
            title: 'Condiciones compuestas',
            concept: 'Con Y ambas condiciones deben cumplirse.',
            instructions: 'Elige el resultado de la condición compuesta.',
            sortOrder: 4,
            exercise: LessonExerciseKind.choice,
            question: '¿Qué devuelve edad >= 18 Y tiene_permiso?',
            options: const [_yesOption, _noOption],
            correctOptionId: 'a',
            explanation: 'Las dos partes deben ser verdaderas.',
          ),
        ],
      ),
      LearningUnit(
        id: 'unit-3',
        title: 'Ciclos — While / For',
        description: 'Repite pasos mientras se cumpla una condición.',
        sortOrder: 3,
        lessons: [
          _lesson(
            id: 'unit-3-lesson-1',
            unitId: 'unit-3',
            number: 1,
            title: '¿Por qué repetir pasos?',
            concept: 'Un ciclo repite pasos sin duplicar el diagrama.',
            instructions: 'Elige la ventaja principal de un ciclo.',
            sortOrder: 1,
            exercise: LessonExerciseKind.choice,
            question: '¿Cuál es la ventaja principal de usar un ciclo?',
            options: const [
              LessonOption(id: 'a', label: 'Repetir sin duplicar'),
              LessonOption(id: 'b', label: 'Evitar condiciones'),
            ],
            correctOptionId: 'a',
            explanation: 'La condición decide cuándo detenerse.',
          ),
          _lesson(
            id: 'unit-3-lesson-2',
            unitId: 'unit-3',
            number: 2,
            title: 'Ciclo while',
            concept: 'while revisa la condición antes de cada repetición.',
            instructions: 'Ordena los pasos para mostrar del 1 al 3.',
            sortOrder: 2,
            blocks: const [
              _start,
              DiagramBlock(
                id: 'init',
                kind: DiagramBlockKind.process,
                label: 'i = 1',
              ),
              DiagramBlock(
                id: 'check',
                kind: DiagramBlockKind.decision,
                label: '¿i <= 3?',
                yesLabel: 'Sí',
                noLabel: 'No',
              ),
              DiagramBlock(
                id: 'show',
                kind: DiagramBlockKind.process,
                label: 'Mostrar i',
              ),
              DiagramBlock(
                id: 'increment',
                kind: DiagramBlockKind.process,
                label: 'i = i + 1',
              ),
              _end,
            ],
          ),
          _lesson(
            id: 'unit-3-lesson-3',
            unitId: 'unit-3',
            number: 3,
            title: 'Ciclo for',
            concept: 'for agrupa inicialización, condición e incremento.',
            instructions: 'Ordena los pasos del ciclo for.',
            sortOrder: 3,
            blocks: const [
              _start,
              DiagramBlock(
                id: 'init',
                kind: DiagramBlockKind.process,
                label: 'i = 1',
              ),
              DiagramBlock(
                id: 'check',
                kind: DiagramBlockKind.decision,
                label: '¿i <= 5?',
                yesLabel: 'Sí',
                noLabel: 'No',
              ),
              DiagramBlock(
                id: 'show',
                kind: DiagramBlockKind.process,
                label: 'Mostrar i',
              ),
              DiagramBlock(
                id: 'increment',
                kind: DiagramBlockKind.process,
                label: 'i = i + 1',
              ),
              _end,
            ],
          ),
          _lesson(
            id: 'unit-3-lesson-4',
            unitId: 'unit-3',
            number: 4,
            title: 'Contador y acumulador',
            concept: 'Un acumulador guarda una suma.',
            instructions: 'Lee el pseudocódigo y elige el valor.',
            sortOrder: 4,
            exercise: LessonExerciseKind.trace,
            snippet: 'suma = 0\npara i = 1 hasta 4:\n  suma = suma + i',
            question: '¿Qué valor se muestra?',
            options: const [
              LessonOption(id: 'a', label: '10'),
              LessonOption(id: 'b', label: '4'),
            ],
            correctOptionId: 'a',
            explanation: '1 + 2 + 3 + 4 = 10.',
          ),
        ],
      ),
      LearningUnit(
        id: 'unit-4',
        title: 'Funciones',
        description: 'Agrupa pasos reutilizables.',
        sortOrder: 4,
        lessons: [
          _lesson(
            id: 'unit-4-lesson-1',
            unitId: 'unit-4',
            number: 1,
            title: '¿Qué es una función?',
            concept: 'Una función agrupa pasos con un nombre.',
            instructions: 'Elige para qué sirve una función.',
            sortOrder: 1,
            exercise: LessonExerciseKind.choice,
            question: '¿Para qué sirve una función?',
            options: const [
              LessonOption(id: 'a', label: 'Reutilizar pasos'),
              LessonOption(id: 'b', label: 'Repetir para siempre'),
            ],
            correctOptionId: 'a',
            explanation: 'Puedes llamar la función varias veces.',
          ),
          _lesson(
            id: 'unit-4-lesson-2',
            unitId: 'unit-4',
            number: 2,
            title: 'Parámetros y valor de retorno',
            concept: 'Los parámetros son los datos que recibe una función.',
            instructions: 'Lee el pseudocódigo y elige el resultado.',
            sortOrder: 2,
            exercise: LessonExerciseKind.trace,
            snippet: 'función doble(n):\n  devolver n * 2\n\ndoble(5)',
            question: '¿Qué devuelve doble(5)?',
            options: const [
              LessonOption(id: 'a', label: '10'),
              LessonOption(id: 'b', label: '5'),
            ],
            correctOptionId: 'a',
            explanation: '5 * 2 = 10.',
          ),
          _lesson(
            id: 'unit-4-lesson-3',
            unitId: 'unit-4',
            number: 3,
            title: 'Llamar una función',
            concept: 'Se llama por su nombre con argumentos entre paréntesis.',
            instructions: 'Ordena el flujo que llama a doble.',
            sortOrder: 3,
            blocks: const [
              _start,
              DiagramBlock(
                id: 'read',
                kind: DiagramBlockKind.process,
                label: 'Leer número',
              ),
              DiagramBlock(
                id: 'call',
                kind: DiagramBlockKind.process,
                label: 'Llamar doble(número)',
              ),
              DiagramBlock(
                id: 'show',
                kind: DiagramBlockKind.process,
                label: 'Mostrar resultado',
              ),
              _end,
            ],
          ),
          _lesson(
            id: 'unit-4-lesson-4',
            unitId: 'unit-4',
            number: 4,
            title: 'Reutilizar una función',
            concept: 'Cada llamada usa sus propios argumentos.',
            instructions: 'Lee el pseudocódigo y elige el valor.',
            sortOrder: 4,
            exercise: LessonExerciseKind.trace,
            snippet: 'doble(3) + doble(4)',
            question: '¿Qué valor se obtiene?',
            options: const [
              LessonOption(id: 'a', label: '14'),
              LessonOption(id: 'b', label: '7'),
            ],
            correctOptionId: 'a',
            explanation: '6 + 8 = 14.',
          ),
        ],
      ),
      LearningUnit(
        id: 'unit-5',
        title: 'Recursividad',
        description: 'Resuelve problemas que se llaman a sí mismos.',
        sortOrder: 5,
        lessons: [
          _lesson(
            id: 'unit-5-lesson-1',
            unitId: 'unit-5',
            number: 1,
            title: 'Caso base',
            concept: 'El caso base detiene las llamadas recursivas.',
            instructions: 'Elige qué ocurre si falta el caso base.',
            sortOrder: 1,
            exercise: LessonExerciseKind.choice,
            question: '¿Qué pasa si no hay caso base?',
            options: const [
              LessonOption(id: 'a', label: 'Se llama indefinidamente'),
              LessonOption(id: 'b', label: 'Devuelve 0'),
            ],
            correctOptionId: 'a',
            explanation: 'Sin parada, la función sigue llamándose.',
          ),
          _lesson(
            id: 'unit-5-lesson-2',
            unitId: 'unit-5',
            number: 2,
            title: 'Llamada recursiva',
            concept: 'Cada llamada debe acercarse al caso base.',
            instructions: 'Lee el pseudocódigo y elige el orden.',
            sortOrder: 2,
            exercise: LessonExerciseKind.trace,
            snippet: 'cuenta(3)\nmuestra 3, llama a cuenta(2)...',
            question: '¿Qué se muestra, en orden?',
            options: const [
              LessonOption(id: 'a', label: '3, 2, 1, Fin'),
              LessonOption(id: 'b', label: '1, 2, 3, Fin'),
            ],
            correctOptionId: 'a',
            explanation: 'Se muestra n y se llama con n - 1.',
          ),
          _lesson(
            id: 'unit-5-lesson-3',
            unitId: 'unit-5',
            number: 3,
            title: 'Factorial paso a paso',
            concept: 'factorial(n) = n * factorial(n - 1).',
            instructions: 'Lee el pseudocódigo y elige el valor.',
            sortOrder: 3,
            exercise: LessonExerciseKind.trace,
            snippet: 'factorial(4)',
            question: '¿Qué valor se muestra?',
            options: const [
              LessonOption(id: 'a', label: '24'),
              LessonOption(id: 'b', label: '12'),
            ],
            correctOptionId: 'a',
            explanation: '4 * 3 * 2 * 1 = 24.',
          ),
          _lesson(
            id: 'unit-5-lesson-4',
            unitId: 'unit-5',
            number: 4,
            title: 'Traza de la pila',
            concept: 'La pila se resuelve de abajo hacia arriba.',
            instructions: 'Elige qué llamada se resuelve primero.',
            sortOrder: 4,
            exercise: LessonExerciseKind.choice,
            question: 'Para factorial(3), ¿qué llamada se resuelve primero?',
            options: const [
              LessonOption(id: 'a', label: 'factorial(0)'),
              LessonOption(id: 'b', label: 'factorial(3)'),
            ],
            correctOptionId: 'a',
            explanation: 'La llamada más profunda es factorial(0).',
          ),
        ],
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

LearningSnapshot demoConditionalsLearningSnapshot() {
  final snapshot = demoLearningSnapshot();

  return snapshot.copyWith(
    units: snapshot.units
        .map(
          (unit) => unit.id == 'unit-1'
              ? unit.copyWith(
                  lessons: unit.lessons
                      .map((lesson) => lesson.copyWith(completed: true))
                      .toList(),
                )
              : unit,
        )
        .toList(),
  );
}

LearningSnapshot demoTraceLearningSnapshot() {
  final snapshot = demoConditionalsLearningSnapshot();

  return snapshot.copyWith(
    units: snapshot.units
        .map(
          (unit) => unit.id == 'unit-2'
              ? unit.copyWith(
                  lessons: unit.lessons
                      .map(
                        (lesson) => lesson.number <= 2
                            ? lesson.copyWith(completed: true)
                            : lesson,
                      )
                      .toList(),
                )
              : unit,
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
  required int sortOrder,
  String unitId = 'unit-1',
  List<DiagramBlock> blocks = const [],
  LessonExerciseKind exercise = LessonExerciseKind.order,
  String question = '',
  List<LessonOption> options = const [],
  String? correctOptionId,
  String explanation = '',
  String? snippet,
  bool completed = false,
}) {
  return LearningLesson(
    id: id,
    unitId: unitId,
    number: number,
    title: title,
    concept: concept,
    instructions: instructions,
    xpReward: 50,
    coinReward: 25,
    blocks: blocks,
    sortOrder: sortOrder,
    completed: completed,
    exercise: exercise,
    question: question,
    options: options,
    correctOptionId: correctOptionId,
    explanation: explanation,
    snippet: snippet,
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
