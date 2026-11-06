import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:flow_app/app.dart';

import 'helpers/fake_auth_repository.dart';
import 'helpers/fake_learning_repository.dart';
import 'helpers/fake_profile_repository.dart';
import 'helpers/fake_store_repository.dart';

void main() {
  Future<FakeLearningRepository> pumpLesson(
    WidgetTester tester, {
    Size size = const Size(390, 844),
    FakeLearningRepository? learningRepository,
    String lessonTitle = 'Tu primer diagrama',
  }) async {
    tester.view.physicalSize = size;
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    final learning = learningRepository ?? FakeLearningRepository();

    await tester.pumpWidget(
      FlowApp(
        authRepository: FakeAuthRepository(user: demoUser),
        learningRepository: learning,
        profileRepository: FakeProfileRepository(),
        storeRepository: FakeStoreRepository(),
      ),
    );
    await tester.tap(find.text('Aprender'));
    await tester.pumpAndSettle();
    final lesson = find.text(lessonTitle);
    await tester.ensureVisible(lesson);
    await tester.tap(lesson);
    await tester.pumpAndSettle();

    return learning;
  }

  Future<void> placeInOrder(
    WidgetTester tester, {
    List<String> labels = const ['Inicio', 'Mostrar mensaje', 'Fin'],
  }) async {
    for (final label in labels) {
      final target = find.text(label);
      await tester.ensureVisible(target);
      await tester.tap(target);
      await tester.pump();
    }
  }

  testWidgets('abre la lección 3 desde la ruta de aprendizaje', (tester) async {
    await pumpLesson(tester);

    expect(find.text('LECCIÓN 3'), findsOneWidget);
    expect(find.text('CONCEPTO'), findsOneWidget);
    expect(find.text('Espacio 1'), findsOneWidget);
    expect(find.text('Espacio 2'), findsOneWidget);
    expect(find.text('Espacio 3'), findsOneWidget);
    expect(find.text('Aprobar diagrama'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('aprueba el diagrama en orden y actualiza el progreso', (
    tester,
  ) async {
    final learning = await pumpLesson(tester);

    await placeInOrder(tester);
    await tester.ensureVisible(find.text('Aprobar diagrama'));
    await tester.tap(find.text('Aprobar diagrama'));
    await tester.pumpAndSettle();

    expect(find.text('¡Diagrama aprobado!'), findsOneWidget);
    expect(find.text('+50 XP'), findsOneWidget);
    expect(find.text('+25 monedas'), findsOneWidget);

    await tester.ensureVisible(find.text('Volver a la ruta'));
    await tester.tap(find.text('Volver a la ruta'));
    await tester.pumpAndSettle();

    expect(find.text('Ruta de aprendizaje'), findsOneWidget);
    expect(find.text('3 de 4 lecciones'), findsOneWidget);
    expect(find.text('75%'), findsOneWidget);
    expect(learning.lastLessonId, 'unit-1-lesson-3');
    expect(learning.coins, 265);
    expect(
      find.textContaining('Recompensa: +50 XP y +25 monedas'),
      findsOneWidget,
    );
    expect(tester.takeException(), isNull);
  });

  testWidgets('permite repasar una lección completada sin recompensa', (
    tester,
  ) async {
    final learning = FakeLearningRepository();

    await tester.pumpWidget(
      FlowApp(
        authRepository: FakeAuthRepository(user: demoUser),
        learningRepository: learning,
        profileRepository: FakeProfileRepository(),
        storeRepository: FakeStoreRepository(),
      ),
    );
    await tester.tap(find.text('Aprender'));
    await tester.pumpAndSettle();

    final reviewLesson = find.text('¿Qué es un diagrama de flujo?');
    await tester.ensureVisible(reviewLesson);
    await tester.tap(reviewLesson);
    await tester.pumpAndSettle();

    expect(find.text('REPASO'), findsOneWidget);

    await placeInOrder(tester, labels: const ['Inicio', 'Mostrar Hola', 'Fin']);
    await tester.ensureVisible(find.text('Aprobar diagrama'));
    await tester.tap(find.text('Aprobar diagrama'));
    await tester.pumpAndSettle();

    expect(find.text('¡Repaso completado!'), findsOneWidget);
    expect(find.textContaining('No hay recompensa adicional'), findsOneWidget);

    await tester.ensureVisible(find.text('Volver a la ruta'));
    await tester.tap(find.text('Volver a la ruta'));
    await tester.pumpAndSettle();

    expect(learning.lastLessonId, 'unit-1-lesson-1');
    expect(learning.coins, 240);
    expect(learning.snapshot.completedLessons, 2);
    expect(find.textContaining('Repaso guardado'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('muestra un mensaje cuando el orden es incorrecto', (
    tester,
  ) async {
    await pumpLesson(tester);

    for (final label in ['Fin', 'Inicio', 'Mostrar mensaje']) {
      await tester.tap(find.text(label));
      await tester.pump();
    }
    await tester.ensureVisible(find.text('Aprobar diagrama'));
    await tester.tap(find.text('Aprobar diagrama'));
    await tester.pumpAndSettle();

    expect(
      find.text(
        'Casi. Revisa el orden: el flujo empieza en Inicio y termina en Fin.',
      ),
      findsOneWidget,
    );
    expect(find.text('¡Diagrama aprobado!'), findsNothing);

    await tester.ensureVisible(find.text('Reiniciar'));
    await tester.tap(find.text('Reiniciar'));
    await tester.pumpAndSettle();

    expect(find.text('Espacio 1'), findsOneWidget);
    expect(
      find.text(
        'Casi. Revisa el orden: el flujo empieza en Inicio y termina en Fin.',
      ),
      findsNothing,
    );
    expect(tester.takeException(), isNull);
  });

  testWidgets('permite quitar un bloque colocado', (tester) async {
    await pumpLesson(tester);

    final start = find.text('Inicio');
    await tester.ensureVisible(start);
    await tester.tap(start);
    await tester.pump();
    expect(find.text('Espacio 1'), findsNothing);

    await tester.ensureVisible(start);
    await tester.tap(start);
    await tester.pump();

    expect(find.text('Espacio 1'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('aprueba una lección de quiz y guarda el progreso', (
    tester,
  ) async {
    final learning = await pumpLesson(
      tester,
      learningRepository: FakeLearningRepository(
        snapshot: demoConditionalsLearningSnapshot(),
      ),
      lessonTitle: '¿Qué es una condición?',
    );

    expect(find.text('TU RESPUESTA'), findsOneWidget);
    expect(find.text('Comprobar respuesta'), findsOneWidget);

    await tester.ensureVisible(find.text('edad >= 18'));
    await tester.tap(find.text('edad >= 18'));
    await tester.pump();

    await tester.ensureVisible(find.text('Comprobar respuesta'));
    await tester.tap(find.text('Comprobar respuesta'));
    await tester.pumpAndSettle();

    expect(find.text('¡Diagrama aprobado!'), findsOneWidget);
    expect(
      find.text('Una condición compara valores y da verdadero o falso.'),
      findsOneWidget,
    );

    await tester.ensureVisible(find.text('Volver a la ruta'));
    await tester.tap(find.text('Volver a la ruta'));
    await tester.pumpAndSettle();

    expect(learning.lastLessonId, 'unit-2-lesson-1');
    expect(learning.coins, 265);
    expect(tester.takeException(), isNull);
  });

  testWidgets('muestra un mensaje cuando el quiz es incorrecto', (
    tester,
  ) async {
    await pumpLesson(
      tester,
      learningRepository: FakeLearningRepository(
        snapshot: demoConditionalsLearningSnapshot(),
      ),
      lessonTitle: '¿Qué es una condición?',
    );

    await tester.ensureVisible(find.text('Leer edad'));
    await tester.tap(find.text('Leer edad'));
    await tester.pump();

    await tester.ensureVisible(find.text('Comprobar respuesta'));
    await tester.tap(find.text('Comprobar respuesta'));
    await tester.pumpAndSettle();

    expect(
      find.text('Casi. Vuelve a leer el concepto y prueba otra opción.'),
      findsOneWidget,
    );
    expect(find.text('¡Diagrama aprobado!'), findsNothing);
    expect(tester.takeException(), isNull);
  });

  testWidgets('aprueba una lección de traza con pseudocódigo', (tester) async {
    final learning = await pumpLesson(
      tester,
      learningRepository: FakeLearningRepository(
        snapshot: demoTraceLearningSnapshot(),
      ),
      lessonTitle: 'If / Else: elige el camino',
    );

    expect(find.text('TRAZA EL FLUJO'), findsOneWidget);
    expect(
      find.text('edad = 20\nsi edad >= 18:\n  mostrar "Mayor"'),
      findsOneWidget,
    );

    await tester.ensureVisible(find.text('Mayor'));
    await tester.tap(find.text('Mayor'));
    await tester.pump();

    await tester.ensureVisible(find.text('Comprobar respuesta'));
    await tester.tap(find.text('Comprobar respuesta'));
    await tester.pumpAndSettle();

    expect(find.text('¡Diagrama aprobado!'), findsOneWidget);

    await tester.ensureVisible(find.text('Volver a la ruta'));
    await tester.tap(find.text('Volver a la ruta'));
    await tester.pumpAndSettle();

    expect(learning.lastLessonId, 'unit-2-lesson-3');
    expect(tester.takeException(), isNull);
  });

  testWidgets('no desborda en una pantalla pequeña', (tester) async {
    await pumpLesson(tester, size: const Size(320, 640));

    expect(find.text('LECCIÓN 3'), findsOneWidget);
    expect(find.text('Aprobar diagrama'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });
}
