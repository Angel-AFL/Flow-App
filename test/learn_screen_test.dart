import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:flow_app/app.dart';
import 'package:flow_app/features/learn/repositories/learning_repository.dart';

import 'helpers/fake_auth_repository.dart';
import 'helpers/fake_learning_repository.dart';
import 'helpers/fake_profile_repository.dart';
import 'helpers/fake_store_repository.dart';

void main() {
  Future<FakeLearningRepository> pumpLearn(
    WidgetTester tester, {
    Size size = const Size(390, 844),
    FakeLearningRepository? learningRepository,
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

    return learning;
  }

  testWidgets('muestra la ruta de aprendizaje desde el repositorio', (
    tester,
  ) async {
    await pumpLearn(tester);

    expect(find.text('Ruta de aprendizaje'), findsOneWidget);
    expect(find.text('UNIDAD 1'), findsOneWidget);
    expect(find.text('Diagramas lineales'), findsOneWidget);
    expect(find.text('2 de 4 lecciones'), findsOneWidget);
    expect(find.text('50%'), findsOneWidget);
    expect(find.text('¿Qué es un diagrama de flujo?'), findsOneWidget);
    expect(find.text('Conoce los símbolos'), findsOneWidget);
    expect(find.text('Tu primer diagrama'), findsOneWidget);
    expect(find.text('+50 XP'), findsOneWidget);
    expect(find.text('Una secuencia completa'), findsOneWidget);
    expect(find.text('Condicionales — If / Else'), findsOneWidget);
    expect(find.text('Ciclos — While / For'), findsOneWidget);
    expect(find.text('Funciones'), findsOneWidget);
    expect(find.text('Recursividad'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('la primera lección es interactiva sin progreso previo', (
    tester,
  ) async {
    await pumpLearn(
      tester,
      learningRepository: FakeLearningRepository(
        snapshot: demoFreshLearningSnapshot(),
      ),
    );

    expect(find.text('0 de 4 lecciones'), findsOneWidget);
    expect(find.text('0%'), findsOneWidget);
    expect(find.text('¿Qué es un diagrama de flujo?'), findsOneWidget);

    final firstLesson = find.text('¿Qué es un diagrama de flujo?');
    await tester.ensureVisible(firstLesson);
    await tester.tap(firstLesson);
    await tester.pumpAndSettle();

    expect(find.text('LECCIÓN 1'), findsOneWidget);
    expect(find.text('CONCEPTO'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('muestra error y permite reintentar', (tester) async {
    final learning = FakeLearningRepository(
      loadFailure: const LearningFailure(
        'No pudimos cargar las lecciones. Inténtalo de nuevo.',
      ),
    );

    await pumpLearn(tester, learningRepository: learning);

    expect(find.text('No pudimos cargar tus lecciones'), findsOneWidget);
    expect(find.text('Reintentar'), findsOneWidget);

    learning.loadFailure = null;
    await tester.tap(find.text('Reintentar'));
    await tester.pumpAndSettle();

    expect(find.text('Tu primer diagrama'), findsOneWidget);
    expect(learning.loadCalls, greaterThanOrEqualTo(2));
    expect(tester.takeException(), isNull);
  });

  testWidgets('no desborda en una pantalla pequeña', (tester) async {
    await pumpLearn(tester, size: const Size(320, 640));

    expect(find.text('Ruta de aprendizaje'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });
}
