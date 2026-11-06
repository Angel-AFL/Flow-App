import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:flow_app/app.dart';
import 'package:flow_app/features/profile/repositories/profile_repository.dart';

import 'helpers/fake_auth_repository.dart';
import 'helpers/fake_learning_repository.dart';
import 'helpers/fake_profile_repository.dart';
import 'helpers/fake_store_repository.dart';

void main() {
  Future<void> pumpWelcome(
    WidgetTester tester, {
    Size size = const Size(390, 844),
    FakeProfileRepository? profileRepository,
  }) async {
    tester.view.physicalSize = size;
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await tester.pumpWidget(
      FlowApp(
        authRepository: FakeAuthRepository(user: demoUser),
        learningRepository: FakeLearningRepository(),
        profileRepository: profileRepository ?? FakeProfileRepository(),
        storeRepository: FakeStoreRepository(),
      ),
    );
    await tester.pumpAndSettle();
  }

  Future<void> pumpApp(
    WidgetTester tester, {
    Size size = const Size(390, 844),
    FakeProfileRepository? profileRepository,
  }) async {
    await pumpWelcome(
      tester,
      size: size,
      profileRepository: profileRepository,
    );
  }

  testWidgets('renderiza el contenido real de Inicio', (tester) async {
    await pumpApp(tester);

    expect(find.text('¡Hola, Estudiante Flow!'), findsOneWidget);
    expect(find.text('Diagramas lineales'), findsOneWidget);
    expect(find.text('50%'), findsOneWidget);
    expect(find.textContaining('Tu primer diagrama'), findsOneWidget);
    expect(find.text('Continuar lección'), findsOneWidget);
    expect(find.text('1,250'), findsOneWidget);
    expect(find.text('8'), findsOneWidget);
    expect(find.text('Racha'), findsOneWidget);
    expect(find.text('7'), findsNWidgets(2));
    expect(find.text('Ver perfil'), findsOneWidget);
    expect(find.text('Meta diaria'), findsOneWidget);
    expect(find.text('2 de 3 actividades completadas'), findsOneWidget);
    expect(find.text('2/3'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('Inicio abre la lección pendiente', (tester) async {
    await pumpApp(tester);

    await tester.tap(find.text('Continuar lección'));
    await tester.pumpAndSettle();

    expect(find.text('LECCIÓN 3'), findsOneWidget);
    expect(find.text('Aprobar diagrama'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('Inicio muestra la meta diaria completada', (tester) async {
    await pumpApp(
      tester,
      profileRepository: FakeProfileRepository(todayActivityCount: 4),
    );

    expect(find.text('Meta diaria completada'), findsOneWidget);
    expect(find.text('3/3'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('Inicio muestra error y permite reintentar', (tester) async {
    final profile = FakeProfileRepository(
      statsFailure: const ProfileFailure(
        'No pudimos cargar tu progreso. Inténtalo de nuevo.',
      ),
    );

    await pumpApp(tester, profileRepository: profile);

    expect(find.text('No pudimos cargar tu inicio'), findsOneWidget);
    expect(find.text('Reintentar'), findsOneWidget);

    profile.statsFailure = null;
    await tester.tap(find.text('Reintentar'));
    await tester.pumpAndSettle();

    expect(find.text('¡Hola, Estudiante Flow!'), findsOneWidget);
    expect(profile.statsCalls, greaterThanOrEqualTo(2));
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

  testWidgets('renderiza la comunidad y su workshop', (tester) async {
    await pumpApp(tester);

    await tester.tap(find.text('Comunidad'));
    await tester.pumpAndSettle();

    expect(find.text('Para ti'), findsOneWidget);
    expect(find.text('Siguiendo'), findsOneWidget);
    expect(find.text('Workshop'), findsOneWidget);

    await tester.tap(find.text('Workshop'));
    await tester.pumpAndSettle();

    expect(find.text('Reto: semáforo inteligente'), findsOneWidget);
    expect(find.text('Bucle infinito'), findsOneWidget);
    expect(find.textContaining('CodeAlex'), findsOneWidget);
    expect(find.text('Cajero Automático'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('las pestañas de Comunidad cambian la vista', (tester) async {
    await pumpApp(tester);

    await tester.tap(find.text('Comunidad'));
    await tester.pumpAndSettle();

    await tester.tap(find.text('Siguiendo'));
    await tester.pumpAndSettle();

    expect(find.text('Aún no sigues a nadie'), findsOneWidget);

    await tester.tap(find.text('Workshop'));
    await tester.pumpAndSettle();

    expect(find.text('Bucle infinito'), findsOneWidget);
    expect(find.text('Aún no sigues a nadie'), findsNothing);
    expect(tester.takeException(), isNull);
  });

  testWidgets('el workshop muestra feedback al abrir un reto', (
    tester,
  ) async {
    await pumpApp(tester);

    await tester.tap(find.text('Comunidad'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Workshop'));
    await tester.pumpAndSettle();

    await tester.tap(find.text('Bucle infinito'));
    await tester.pump();

    expect(
      find.text('Cargando nivel: Bucle infinito...'),
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

    expect(find.text('¡Hola, Estudiante Flow!'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });
}
