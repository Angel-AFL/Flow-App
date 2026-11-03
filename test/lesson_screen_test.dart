import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:flow_app/app.dart';

import 'helpers/fake_auth_repository.dart';
import 'helpers/fake_profile_repository.dart';

void main() {
  Future<void> pumpLesson(
    WidgetTester tester, {
    Size size = const Size(390, 844),
  }) async {
    tester.view.physicalSize = size;
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await tester.pumpWidget(
      FlowApp(
        authRepository: FakeAuthRepository(user: demoUser),
        profileRepository: FakeProfileRepository(),
      ),
    );
    await tester.tap(find.text('Aprender'));
    await tester.pumpAndSettle();
    await tester.ensureVisible(find.text('Tu primer diagrama'));
    await tester.tap(find.text('Tu primer diagrama'));
    await tester.pumpAndSettle();
  }

  Future<void> placeInOrder(WidgetTester tester) async {
    for (final label in ['Inicio', 'Mostrar mensaje', 'Fin']) {
      await tester.tap(find.text(label));
      await tester.pump();
    }
  }

  testWidgets('abre la lección 3 desde la ruta de aprendizaje', (tester) async {
    await pumpLesson(tester);

    expect(find.text('LECCIÓN 3'), findsOneWidget);
    expect(find.text('Espacio 1'), findsOneWidget);
    expect(find.text('Espacio 2'), findsOneWidget);
    expect(find.text('Espacio 3'), findsOneWidget);
    expect(find.text('Aprobar diagrama'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('aprueba el diagrama en orden y actualiza el progreso', (
    tester,
  ) async {
    await pumpLesson(tester);

    await placeInOrder(tester);
    await tester.ensureVisible(find.text('Aprobar diagrama'));
    await tester.tap(find.text('Aprobar diagrama'));
    await tester.pumpAndSettle();

    expect(find.text('¡Diagrama aprobado!'), findsOneWidget);
    expect(find.text('+50 XP'), findsOneWidget);

    await tester.ensureVisible(find.text('Volver a la ruta'));
    await tester.tap(find.text('Volver a la ruta'));
    await tester.pumpAndSettle();

    expect(find.text('Ruta de aprendizaje'), findsOneWidget);
    expect(find.text('3 de 3 lecciones'), findsOneWidget);
    expect(find.text('100%'), findsOneWidget);
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

    await tester.tap(find.text('Inicio'));
    await tester.pump();
    expect(find.text('Espacio 1'), findsNothing);

    await tester.tap(find.text('Inicio'));
    await tester.pump();

    expect(find.text('Espacio 1'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('no desborda en una pantalla pequeña', (tester) async {
    await pumpLesson(tester, size: const Size(320, 640));

    expect(find.text('LECCIÓN 3'), findsOneWidget);
    expect(find.text('Aprobar diagrama'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });
}
