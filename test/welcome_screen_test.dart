import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:flow_app/app.dart';

import 'helpers/fake_auth_repository.dart';
import 'helpers/fake_profile_repository.dart';

void main() {
  Future<void> pumpWelcome(
    WidgetTester tester, {
    Size size = const Size(390, 844),
  }) async {
    tester.view.physicalSize = size;
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    final authRepository = FakeAuthRepository();
    addTearDown(authRepository.dispose);
    await tester.pumpWidget(
      FlowApp(
        authRepository: authRepository,
        profileRepository: FakeProfileRepository(),
      ),
    );
  }

  testWidgets('muestra la pantalla de bienvenida', (tester) async {
    await pumpWelcome(tester);

    expect(find.text('FlowApp'), findsOneWidget);
    expect(
      find.text('Aprende a pensar\npaso a paso.', findRichText: true),
      findsOneWidget,
    );
    expect(
      find.text(
        'Domina la lógica de programación creando diagramas que cobran vida.',
      ),
      findsOneWidget,
    );
    expect(find.text('Comenzar'), findsOneWidget);
    expect(find.text('Ya tengo una cuenta'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('Comenzar abre el registro', (tester) async {
    await pumpWelcome(tester);

    await tester.tap(find.text('Comenzar'));
    await tester.pumpAndSettle();

    expect(find.text('Crea tu\ncuenta.'), findsOneWidget);
    expect(find.text('Crear cuenta'), findsOneWidget);
    expect(find.text('Entrar'), findsNothing);
    expect(tester.takeException(), isNull);
  });

  testWidgets('Ya tengo una cuenta abre el login', (tester) async {
    await pumpWelcome(tester);

    await tester.tap(find.text('Ya tengo una cuenta'));
    await tester.pumpAndSettle();

    expect(find.text('Bienvenido\nde nuevo.'), findsOneWidget);
    expect(find.text('Entrar'), findsOneWidget);
    expect(find.text('Crear cuenta'), findsNothing);
    expect(tester.takeException(), isNull);
  });

  testWidgets('el botón de tema muestra feedback', (tester) async {
    await pumpWelcome(tester);

    await tester.tap(find.byIcon(Icons.wb_sunny_outlined));
    await tester.pump();

    expect(
      find.text('El tema claro estará disponible próximamente.'),
      findsOneWidget,
    );
    expect(tester.takeException(), isNull);
  });

  testWidgets('no desborda en una pantalla pequeña', (tester) async {
    await pumpWelcome(tester, size: const Size(320, 640));

    expect(find.text('Comenzar'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });
}
