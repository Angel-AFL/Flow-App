import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:flow_app/app.dart';

void main() {
  Future<void> pumpWelcome(
    WidgetTester tester, {
    Size size = const Size(390, 844),
  }) async {
    tester.view.physicalSize = size;
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await tester.pumpWidget(const FlowApp());
  }

  Future<void> pumpApp(
    WidgetTester tester, {
    Size size = const Size(390, 844),
  }) async {
    await pumpWelcome(tester, size: size);
    await tester.ensureVisible(find.text('Comenzar'));
    await tester.tap(find.text('Comenzar'));
    await tester.pumpAndSettle();
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

  testWidgets('la barra inferior navega a Perfil', (tester) async {
    await pumpApp(tester);

    await tester.tap(find.text('Perfil'));
    await tester.pumpAndSettle();

    expect(find.text('Estudiante Flow'), findsOneWidget);
    expect(find.text('Logros'), findsOneWidget);
    expect(find.text('¡Hola, estudiante!'), findsNothing);
    expect(tester.takeException(), isNull);
  });

  testWidgets('renderiza el feed de Comunidad', (tester) async {
    await pumpApp(tester);

    await tester.tap(find.text('Comunidad'));
    await tester.pumpAndSettle();

    expect(find.text('Para ti'), findsOneWidget);
    expect(find.text('Siguiendo'), findsOneWidget);
    expect(find.text('Workshop'), findsOneWidget);
    expect(find.text('Reto: semáforo inteligente'), findsOneWidget);
    expect(find.text('CodeAlex'), findsOneWidget);
    expect(find.text('Mi primer diagrama'), findsOneWidget);
    expect(find.text('¿Es un número positivo?'), findsOneWidget);
    expect(find.text('Mostrar mensaje'), findsOneWidget);
    expect(find.text('Es > 0'), findsOneWidget);
    expect(find.text('48'), findsOneWidget);
    expect(find.text('Remix'), findsNWidgets(2));
    expect(tester.takeException(), isNull);
  });

  testWidgets('las pestañas de Comunidad cambian el feed', (tester) async {
    await pumpApp(tester);

    await tester.tap(find.text('Comunidad'));
    await tester.pumpAndSettle();

    await tester.tap(find.text('Siguiendo'));
    await tester.pumpAndSettle();

    expect(find.text('Suma hasta 10'), findsOneWidget);
    expect(find.text('Mi primer diagrama'), findsNothing);

    await tester.tap(find.text('Workshop'));
    await tester.pumpAndSettle();

    expect(find.text('Clasifica el número'), findsOneWidget);
    expect(find.text('Suma hasta 10'), findsNothing);
    expect(tester.takeException(), isNull);
  });

  testWidgets('el like actualiza el contador y Remix muestra feedback', (
    tester,
  ) async {
    await pumpApp(tester);

    await tester.tap(find.text('Comunidad'));
    await tester.pumpAndSettle();

    expect(find.text('48'), findsOneWidget);

    await tester.tap(find.byIcon(Icons.favorite_border_rounded).first);
    await tester.pumpAndSettle();

    expect(find.text('49'), findsOneWidget);
    expect(find.byIcon(Icons.favorite_rounded), findsOneWidget);

    await tester.tap(find.text('Remix').first);
    await tester.pump();

    expect(
      find.text('El Remix estará disponible próximamente.'),
      findsOneWidget,
    );
    expect(tester.takeException(), isNull);
  });

  testWidgets('Comunidad no desborda en una pantalla pequeña', (tester) async {
    await pumpApp(tester, size: const Size(320, 640));

    await tester.tap(find.text('Comunidad'));
    await tester.pumpAndSettle();

    expect(find.text('Para ti'), findsOneWidget);

    await tester.drag(
      find.byType(SingleChildScrollView),
      const Offset(0, -500),
    );
    await tester.pumpAndSettle();

    expect(tester.takeException(), isNull);
  });

  testWidgets('Inicio no desborda en una pantalla pequeña', (tester) async {
    await pumpApp(tester, size: const Size(320, 640));

    expect(find.text('¡Hola, estudiante!'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });
}
