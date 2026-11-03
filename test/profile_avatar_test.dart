import 'dart:convert';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:flow_app/core/theme/app_theme.dart';
import 'package:flow_app/features/profile/models/profile_models.dart';
import 'package:flow_app/features/profile/profile_screen.dart';
import 'package:flow_app/features/profile/repositories/profile_repository.dart';
import 'package:flow_app/features/profile/services/profile_image_picker.dart';

import 'helpers/fake_profile_repository.dart';

const _onePixelPng =
    'iVBORw0KGgoAAAANSUhEUgAAAAEAAAABCAQAAAC1HAwCAAAAC0lEQVR42mNk'
    '+A8AAQUBAScY42YAAAAASUVORK5CYII=';

void main() {
  final imageBytes = base64Decode(_onePixelPng);
  final pickedImage = PickedProfileImage(
    bytes: Uint8List.fromList(imageBytes),
    extension: 'png',
    mimeType: 'image/png',
  );

  Future<FakeProfileRepository> pumpProfile(
    WidgetTester tester, {
    required PickProfileImage pickImage,
    Size size = const Size(390, 844),
  }) async {
    tester.view.physicalSize = size;
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    final repository = FakeProfileRepository();

    await tester.pumpWidget(
      MaterialApp(
        theme: AppTheme.dark,
        home: Scaffold(
          body: ProfileScreen(
            userId: 'user-1',
            userEmail: 'estudiante@flow.app',
            repository: repository,
            onSignOut: () async {},
            pickImage: pickImage,
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();

    return repository;
  }

  testWidgets('Cambiar foto carga la imagen de la galería', (tester) async {
    var calls = 0;

    final repository = await pumpProfile(
      tester,
      pickImage: () async {
        calls++;
        return pickedImage;
      },
    );

    await tester.ensureVisible(find.text('Cambiar foto'));
    await tester.tap(find.text('Cambiar foto'));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 400));

    expect(calls, 1);
    expect(repository.lastAvatar, isNotNull);
    expect(find.byKey(const Key('profile-avatar-image')), findsOneWidget);
    expect(find.text('Foto de perfil actualizada.'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('tocar el avatar también abre la galería', (tester) async {
    var calls = 0;

    await pumpProfile(
      tester,
      pickImage: () async {
        calls++;
        return pickedImage;
      },
    );

    await tester.tap(find.byKey(const Key('profile-avatar')));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 400));

    expect(calls, 1);
    expect(find.byKey(const Key('profile-avatar-image')), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('cancelar la galería mantiene las iniciales', (tester) async {
    await pumpProfile(tester, pickImage: () async => null);

    await tester.ensureVisible(find.text('Cambiar foto'));
    await tester.tap(find.text('Cambiar foto'));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 400));

    expect(find.byKey(const Key('profile-avatar-image')), findsNothing);
    expect(find.text('EF'), findsOneWidget);
    expect(find.text('Foto de perfil actualizada.'), findsNothing);
    expect(tester.takeException(), isNull);
  });

  testWidgets('muestra feedback cuando falla la galería', (tester) async {
    await pumpProfile(
      tester,
      pickImage: () async => throw Exception('picker failed'),
    );

    await tester.ensureVisible(find.text('Cambiar foto'));
    await tester.tap(find.text('Cambiar foto'));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 400));

    expect(
      find.text('No se pudo abrir la galería. Inténtalo de nuevo.'),
      findsOneWidget,
    );
    expect(find.byKey(const Key('profile-avatar-image')), findsNothing);
    expect(tester.takeException(), isNull);
  });

  testWidgets('muestra feedback cuando falla la subida', (tester) async {
    final repository = await pumpProfile(
      tester,
      pickImage: () async => pickedImage,
    );
    repository.uploadFailure = const ProfileFailure(
      'No pudimos subir la foto. Inténtalo de nuevo.',
    );

    await tester.ensureVisible(find.text('Cambiar foto'));
    await tester.tap(find.text('Cambiar foto'));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 400));

    expect(
      find.text('No pudimos subir la foto. Inténtalo de nuevo.'),
      findsOneWidget,
    );
    expect(find.byKey(const Key('profile-avatar-image')), findsNothing);
    expect(tester.takeException(), isNull);
  });
}
