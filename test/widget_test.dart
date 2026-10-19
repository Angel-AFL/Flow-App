import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:flow_app/app.dart';

void main() {
  Future<void> pumpApp(
    WidgetTester tester, {
    Size size = const Size(390, 844),
  }) async {
    tester.view.physicalSize = size;
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await tester.pumpWidget(const FlowApp());
  }

  testWidgets('renderiza el contenido estático de Inicio', (tester) async {
    await pumpApp(tester);

    expect(find.text('¡Hola, estudiante!'), findsOneWidget);
    expect(find.text('Fundamentos de diagramas de flujo'), findsOneWidget);
    expect(find.text('38%'), findsOneWidget);
    expect(find.text('Continuar lección'), findsOneWidget);
    expect(find.text('1,250'), findsOneWidget);
    expect(find.text('8'), findsOneWidget);
    expect(find.text('7 días'), findsOneWidget);
    expect(find.text('Tu primer diagrama'), findsOneWidget);
    expect(find.text('Meta diaria'), findsOneWidget);
    expect(find.text('2/3'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('la barra inferior navega a los placeholders', (tester) async {
    await pumpApp(tester);

    await tester.tap(find.text('Tienda'));
    await tester.pumpAndSettle();

    expect(find.text('PRÓXIMAMENTE'), findsOneWidget);
    expect(find.text('¡Hola, estudiante!'), findsNothing);
    expect(tester.takeException(), isNull);
  });

  testWidgets('no desborda en una pantalla pequeña', (tester) async {
    await pumpApp(tester, size: const Size(320, 640));

    expect(find.text('¡Hola, estudiante!'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });
}
