import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:flow_app/app.dart';
import 'package:flow_app/features/profile/my_diagrams_screen.dart';

import 'helpers/fake_auth_repository.dart';
import 'helpers/fake_learning_repository.dart';
import 'helpers/fake_profile_repository.dart';
import 'helpers/fake_store_repository.dart';

void main() {
  Future<FakeAuthRepository> pumpProfile(
    WidgetTester tester, {
    Size size = const Size(390, 844),
  }) async {
    tester.view.physicalSize = size;
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    final authRepository = FakeAuthRepository(user: demoUser);
    addTearDown(authRepository.dispose);
    await tester.pumpWidget(
      FlowApp(
        authRepository: authRepository,
        learningRepository: FakeLearningRepository(),
        profileRepository: FakeProfileRepository(),
        storeRepository: FakeStoreRepository(),
      ),
    );
    await tester.tap(find.text('Perfil'));
    await tester.pumpAndSettle();

    return authRepository;
  }

  testWidgets('muestra el perfil estático', (tester) async {
    await pumpProfile(tester);

    expect(find.text('Estudiante Flow'), findsOneWidget);
    expect(find.text('estudiante@flow.app'), findsOneWidget);
    expect(find.text('Nivel 3'), findsOneWidget);
    expect(find.text('1,250 / 1,500 XP'), findsOneWidget);
    expect(find.text('1,250'), findsOneWidget);
    expect(find.text('7'), findsOneWidget);
    expect(find.text('8'), findsOneWidget);
    expect(find.text('XP total'), findsOneWidget);
    expect(find.text('Días de racha'), findsOneWidget);
    expect(find.text('Lecciones'), findsOneWidget);
    expect(find.text('Logros'), findsOneWidget);
    expect(find.text('3 de 12'), findsOneWidget);
    expect(find.text('Primer paso'), findsOneWidget);
    expect(find.text('Mente lógica'), findsOneWidget);
    expect(find.text('Constancia'), findsOneWidget);
    expect(find.text('Código limpio'), findsOneWidget);
    expect(find.text('Actividad'), findsOneWidget);
    expect(find.text('Últimas 5 semanas'), findsOneWidget);
    expect(find.text('Mis diagramas'), findsOneWidget);
    expect(find.text('Ver todos'), findsOneWidget);
    expect(find.text('Mi primer diagrama'), findsOneWidget);
    expect(find.text('¿Es un número positivo?'), findsOneWidget);
    expect(find.text('Cerrar sesión'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('Ver todos abre la galería de diagramas', (tester) async {
    await pumpProfile(tester);

    await tester.ensureVisible(find.text('Ver todos'));
    await tester.tap(find.text('Ver todos'));
    await tester.pumpAndSettle();

    expect(find.byType(MyDiagramsScreen), findsOneWidget);
    expect(find.text('Mi primer diagrama'), findsWidgets);
    expect(tester.takeException(), isNull);
  });

  testWidgets('Cerrar sesión vuelve a Bienvenida', (tester) async {
    final authRepository = await pumpProfile(tester);

    await tester.ensureVisible(find.text('Cerrar sesión'));
    await tester.tap(find.text('Cerrar sesión'));
    await tester.pumpAndSettle();

    expect(authRepository.signOutCalls, 1);
    expect(find.text('Comenzar'), findsOneWidget);
    expect(find.text('Estudiante Flow'), findsNothing);
    expect(tester.takeException(), isNull);
  });

  testWidgets('no desborda en una pantalla pequeña', (tester) async {
    await pumpProfile(tester, size: const Size(320, 640));

    expect(find.text('Estudiante Flow'), findsOneWidget);

    await tester.drag(
      find.byType(SingleChildScrollView),
      const Offset(0, -600),
    );
    await tester.pumpAndSettle();

    expect(tester.takeException(), isNull);
  });
}
