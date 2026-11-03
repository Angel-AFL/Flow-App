import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:flow_app/app.dart';
import 'package:flow_app/core/auth/auth_repository.dart';

import 'helpers/fake_auth_repository.dart';
import 'helpers/fake_profile_repository.dart';
import 'helpers/fake_store_repository.dart';

void main() {
  Future<FakeAuthRepository> pumpApp(
    WidgetTester tester, {
    Size size = const Size(390, 844),
    FakeAuthRepository? authRepository,
  }) async {
    tester.view.physicalSize = size;
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    final auth = authRepository ?? FakeAuthRepository();
    addTearDown(auth.dispose);
    await tester.pumpWidget(
      FlowApp(
        authRepository: auth,
        profileRepository: FakeProfileRepository(),
        storeRepository: FakeStoreRepository(),
      ),
    );

    return auth;
  }

  Future<void> openLogin(WidgetTester tester) async {
    final target = find.text('Ya tengo una cuenta');
    await tester.ensureVisible(target);
    await tester.tap(target);
    await tester.pumpAndSettle();
  }

  Future<void> openSignUp(WidgetTester tester) async {
    final target = find.text('Comenzar');
    await tester.ensureVisible(target);
    await tester.tap(target);
    await tester.pumpAndSettle();
  }

  Future<void> fillLogin(
    WidgetTester tester, {
    String email = 'alumno@flow.app',
    String password = 'password123',
  }) async {
    await tester.enterText(find.byKey(const Key('login-email')), email);
    await tester.enterText(find.byKey(const Key('login-password')), password);
  }

  Future<void> fillSignUp(
    WidgetTester tester, {
    String email = 'alumno@flow.app',
    String password = 'password123',
    String? confirmPassword,
  }) async {
    await tester.enterText(find.byKey(const Key('signup-email')), email);
    await tester.enterText(find.byKey(const Key('signup-password')), password);
    await tester.enterText(
      find.byKey(const Key('signup-confirm-password')),
      confirmPassword ?? password,
    );
  }

  testWidgets('el login valida correo y contraseña vacíos', (tester) async {
    final auth = await pumpApp(tester);
    await openLogin(tester);

    await tester.tap(find.text('Entrar'));
    await tester.pump();

    expect(find.text('Ingresa tu correo.'), findsOneWidget);
    expect(find.text('Ingresa tu contraseña.'), findsOneWidget);
    expect(auth.signInCalls, 0);
    expect(tester.takeException(), isNull);
  });

  testWidgets('el login rechaza un correo inválido', (tester) async {
    final auth = await pumpApp(tester);
    await openLogin(tester);

    await fillLogin(tester, email: 'no-es-un-correo');
    await tester.tap(find.text('Entrar'));
    await tester.pump();

    expect(find.text('Ingresa un correo válido.'), findsOneWidget);
    expect(auth.signInCalls, 0);
    expect(tester.takeException(), isNull);
  });

  testWidgets('el login exitoso entra al shell', (tester) async {
    final auth = await pumpApp(tester);
    await openLogin(tester);

    await fillLogin(tester);
    await tester.tap(find.text('Entrar'));
    await tester.pumpAndSettle();

    expect(auth.signInCalls, 1);
    expect(auth.lastEmail, 'alumno@flow.app');
    expect(find.text('¡Hola, estudiante!'), findsOneWidget);
    expect(find.text('Entrar'), findsNothing);
    expect(tester.takeException(), isNull);
  });

  testWidgets('el login muestra el error de credenciales', (tester) async {
    final auth = await pumpApp(
      tester,
      authRepository: FakeAuthRepository(
        signInFailure: const AuthFailure(
          'Correo o contraseña incorrectos.',
          code: 'invalid_credentials',
        ),
      ),
    );
    await openLogin(tester);

    await fillLogin(tester);
    await tester.tap(find.text('Entrar'));
    await tester.pumpAndSettle();

    expect(auth.signInCalls, 1);
    expect(find.text('Correo o contraseña incorrectos.'), findsOneWidget);
    expect(find.text('Entrar'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('el registro exige una contraseña de 8 caracteres', (
    tester,
  ) async {
    final auth = await pumpApp(tester);
    await openSignUp(tester);

    await fillSignUp(tester, password: '1234');
    await tester.tap(find.text('Crear cuenta'));
    await tester.pump();

    expect(find.text('Usa al menos 8 caracteres.'), findsOneWidget);
    expect(auth.signUpCalls, 0);
    expect(tester.takeException(), isNull);
  });

  testWidgets('el registro valida que las contraseñas coincidan', (
    tester,
  ) async {
    final auth = await pumpApp(tester);
    await openSignUp(tester);

    await fillSignUp(
      tester,
      password: 'password123',
      confirmPassword: 'password124',
    );
    await tester.tap(find.text('Crear cuenta'));
    await tester.pump();

    expect(find.text('Las contraseñas no coinciden.'), findsOneWidget);
    expect(auth.signUpCalls, 0);
    expect(tester.takeException(), isNull);
  });

  testWidgets('el registro exitoso entra al shell', (tester) async {
    final auth = await pumpApp(tester);
    await openSignUp(tester);

    await fillSignUp(tester);
    await tester.tap(find.text('Crear cuenta'));
    await tester.pumpAndSettle();

    expect(auth.signUpCalls, 1);
    expect(find.text('¡Hola, estudiante!'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('el registro con confirmación de correo muestra el aviso', (
    tester,
  ) async {
    final auth = await pumpApp(
      tester,
      authRepository: FakeAuthRepository(
        signUpResult: SignUpResult.confirmationRequired,
      ),
    );
    await openSignUp(tester);

    await fillSignUp(tester, email: 'nuevo@flow.app');
    await tester.tap(find.text('Crear cuenta'));
    await tester.pumpAndSettle();

    expect(auth.signUpCalls, 1);
    expect(find.text('Revisa tu\ncorreo.'), findsOneWidget);
    expect(find.text('nuevo@flow.app'), findsOneWidget);
    expect(find.text('Ir a iniciar sesión'), findsOneWidget);
    expect(find.text('¡Hola, estudiante!'), findsNothing);
    expect(tester.takeException(), isNull);
  });

  testWidgets('el login no desborda en una pantalla pequeña', (tester) async {
    await pumpApp(tester, size: const Size(320, 640));
    await openLogin(tester);

    expect(find.text('Entrar'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('el registro no desborda en una pantalla pequeña', (
    tester,
  ) async {
    await pumpApp(tester, size: const Size(320, 640));
    await openSignUp(tester);

    expect(find.text('Crear cuenta'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });
}
