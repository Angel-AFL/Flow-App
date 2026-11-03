import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:flow_app/app.dart';
import 'package:flow_app/features/profile/models/profile_models.dart';
import 'package:flow_app/features/profile/my_diagrams_screen.dart';
import 'package:flow_app/features/profile/repositories/profile_repository.dart';
import 'package:flow_app/features/profile/widgets/profile_diagram_card.dart';

import 'helpers/fake_auth_repository.dart';
import 'helpers/fake_learning_repository.dart';
import 'helpers/fake_profile_repository.dart';
import 'helpers/fake_store_repository.dart';

void main() {
  Future<FakeProfileRepository> openProfile(
    WidgetTester tester, {
    FakeProfileRepository? profileRepository,
    Size size = const Size(390, 844),
    bool settle = true,
  }) async {
    tester.view.physicalSize = size;
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    final repository = profileRepository ?? FakeProfileRepository();

    await tester.pumpWidget(
      FlowApp(
        authRepository: FakeAuthRepository(user: demoUser),
        learningRepository: FakeLearningRepository(),
        profileRepository: repository,
        storeRepository: FakeStoreRepository(),
      ),
    );
    await tester.tap(find.text('Perfil'));

    if (settle) {
      await tester.pumpAndSettle();
    } else {
      await tester.pump();
    }

    return repository;
  }

  Future<void> openEditSheet(WidgetTester tester) async {
    await tester.tap(find.byKey(const Key('edit-profile')));
    await tester.pumpAndSettle();
  }

  testWidgets('muestra carga mientras llega el perfil', (tester) async {
    final completer = Completer<ProfileSnapshot>();
    final repository = FakeProfileRepository()..pendingLoad = completer;

    await openProfile(tester, profileRepository: repository, settle: false);

    expect(find.byType(CircularProgressIndicator), findsWidgets);

    completer.complete(demoProfileSnapshot());
    await tester.pumpAndSettle();

    expect(find.text('Estudiante Flow'), findsOneWidget);
    expect(find.text('1,250'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('muestra error y permite reintentar', (tester) async {
    final repository = FakeProfileRepository(
      loadFailure: const ProfileFailure(
        'No pudimos cargar tu perfil. Inténtalo de nuevo.',
      ),
    );

    await openProfile(tester, profileRepository: repository);

    expect(find.text('No pudimos cargar tu perfil'), findsOneWidget);
    expect(find.text('Reintentar'), findsOneWidget);

    repository.loadFailure = null;
    await tester.tap(find.text('Reintentar'));
    await tester.pumpAndSettle();

    expect(find.text('Estudiante Flow'), findsOneWidget);
    expect(repository.loadCalls, greaterThanOrEqualTo(2));
    expect(tester.takeException(), isNull);
  });

  testWidgets('edita nombre y usuario desde el perfil', (tester) async {
    final repository = await openProfile(tester);

    await openEditSheet(tester);

    expect(find.text('Editar perfil'), findsOneWidget);

    await tester.enterText(
      find.byKey(const Key('edit-display-name')),
      'Nuevo Nombre',
    );
    await tester.enterText(
      find.byKey(const Key('edit-username')),
      'nuevo_user',
    );
    await tester.tap(find.text('Guardar cambios'));
    await tester.pumpAndSettle();

    expect(repository.lastEdit?.displayName, 'Nuevo Nombre');
    expect(repository.lastEdit?.username, 'nuevo_user');
    expect(find.text('Nuevo Nombre'), findsOneWidget);
    expect(
      find.textContaining('@nuevo_user', findRichText: true),
      findsOneWidget,
    );
    expect(find.text('Perfil actualizado.'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('valida el nombre de usuario antes de guardar', (tester) async {
    final repository = await openProfile(tester);

    await openEditSheet(tester);

    await tester.enterText(
      find.byKey(const Key('edit-username')),
      'con espacio',
    );
    await tester.tap(find.text('Guardar cambios'));
    await tester.pump();

    expect(
      find.text('Solo letras minúsculas, números y guion bajo.'),
      findsOneWidget,
    );
    expect(repository.lastEdit, isNull);
    expect(tester.takeException(), isNull);
  });

  testWidgets('muestra error cuando el usuario ya está en uso', (tester) async {
    final repository = await openProfile(tester);

    await openEditSheet(tester);

    await tester.enterText(find.byKey(const Key('edit-username')), 'taken');
    await tester.tap(find.text('Guardar cambios'));
    await tester.pumpAndSettle();

    expect(find.text('Ese nombre de usuario ya está en uso.'), findsOneWidget);
    expect(find.text('Editar perfil'), findsOneWidget);
    expect(repository.lastEdit, isNull);
    expect(tester.takeException(), isNull);
  });

  testWidgets('muestra el título equipado en el perfil', (tester) async {
    await openProfile(tester);

    expect(find.text('Novato'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('muestra el estado vacío de diagramas', (tester) async {
    final repository = FakeProfileRepository(
      snapshot: demoProfileSnapshot(diagrams: const []),
    );

    await openProfile(tester, profileRepository: repository);

    expect(find.text('Aún no has creado diagramas.'), findsOneWidget);

    await tester.ensureVisible(find.text('Ver todos'));
    await tester.tap(find.text('Ver todos'));
    await tester.pumpAndSettle();

    expect(find.byType(MyDiagramsScreen), findsOneWidget);
    expect(
      find.descendant(
        of: find.byType(MyDiagramsScreen),
        matching: find.text('Aún no has creado diagramas.'),
      ),
      findsOneWidget,
    );
    expect(tester.takeException(), isNull);
  });

  testWidgets('abre la galería completa de diagramas', (tester) async {
    await openProfile(tester);

    await tester.ensureVisible(find.text('Ver todos'));
    await tester.tap(find.text('Ver todos'));
    await tester.pumpAndSettle();

    expect(find.byType(MyDiagramsScreen), findsOneWidget);
    expect(
      find.descendant(
        of: find.byType(MyDiagramsScreen),
        matching: find.byType(ProfileDiagramCard),
      ),
      findsNWidgets(2),
    );
    expect(find.text('Mi primer diagrama'), findsWidgets);
    expect(tester.takeException(), isNull);
  });
}
