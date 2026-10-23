import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:flow_app/app.dart';

void main() {
  Future<void> pumpLearn(
    WidgetTester tester, {
    Size size = const Size(390, 844),
  }) async {
    tester.view.physicalSize = size;
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await tester.pumpWidget(const FlowApp());
    await tester.ensureVisible(find.text('Comenzar'));
    await tester.tap(find.text('Comenzar'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Aprender'));
    await tester.pumpAndSettle();
  }

  testWidgets('muestra la ruta de aprendizaje estática', (tester) async {
    await pumpLearn(tester);

    expect(find.text('Ruta de aprendizaje'), findsOneWidget);
    expect(find.text('UNIDAD 1'), findsOneWidget);
    expect(find.text('Diagramas lineales'), findsOneWidget);
    expect(find.text('2 de 3 lecciones'), findsOneWidget);
    expect(find.text('67%'), findsOneWidget);
    expect(find.text('¿Qué es un diagrama?'), findsOneWidget);
    expect(find.text('Conoce los símbolos'), findsOneWidget);
    expect(find.text('Tu primer diagrama'), findsOneWidget);
    expect(find.text('+50 XP · 5 min'), findsOneWidget);
    expect(find.text('Condicionales — If / Else'), findsOneWidget);
    expect(find.text('Ciclos — While / For'), findsOneWidget);
    expect(find.text('Funciones'), findsOneWidget);
    expect(find.text('Recursividad'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('no desborda en una pantalla pequeña', (tester) async {
    await pumpLearn(tester, size: const Size(320, 640));

    expect(find.text('Ruta de aprendizaje'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });
}
