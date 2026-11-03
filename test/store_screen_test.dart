import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:flow_app/app.dart';
import 'package:flow_app/features/store/models/store_models.dart';
import 'package:flow_app/features/store/repositories/store_repository.dart';

import 'helpers/fake_auth_repository.dart';
import 'helpers/fake_learning_repository.dart';
import 'helpers/fake_profile_repository.dart';
import 'helpers/fake_store_repository.dart';

void main() {
  Future<FakeStoreRepository> pumpStore(
    WidgetTester tester, {
    FakeStoreRepository? storeRepository,
    Size size = const Size(390, 844),
  }) async {
    tester.view.physicalSize = size;
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    final store = storeRepository ?? FakeStoreRepository();

    await tester.pumpWidget(
      FlowApp(
        authRepository: FakeAuthRepository(user: demoUser),
        learningRepository: FakeLearningRepository(),
        profileRepository: FakeProfileRepository(),
        storeRepository: store,
      ),
    );
    await tester.tap(find.text('Tienda'));
    await tester.pumpAndSettle();

    return store;
  }

  List<StoreItem> withOwned(String code) {
    return demoStoreItems
        .map(
          (item) => item.code == code
              ? item.copyWith(owned: true, quantity: 1)
              : item,
        )
        .toList();
  }

  Future<void> confirmPurchase(WidgetTester tester, String label) async {
    await tester.tap(find.text(label));
    await tester.pumpAndSettle();
    await tester.tap(find.textContaining('Comprar por'));
    await tester.pumpAndSettle();
  }

  testWidgets('muestra saldo, categorías y skins', (tester) async {
    await pumpStore(tester);

    expect(find.text('Tienda Flow'), findsOneWidget);
    expect(find.text('TU SALDO'), findsOneWidget);
    expect(find.text('240'), findsOneWidget);
    expect(find.text('Skins para diagramas'), findsOneWidget);
    expect(find.text('3 ítems'), findsOneWidget);
    expect(find.text('Clásico'), findsOneWidget);
    expect(find.text('Equipado'), findsNWidgets(2));
    expect(find.text('Pixel Art'), findsOneWidget);
    expect(find.text('120'), findsOneWidget);
    expect(find.text('Cyber'), findsOneWidget);
    expect(find.text('200'), findsOneWidget);
    expect(find.text('Comprar'), findsNWidgets(2));
    expect(find.text('Cofre diario listo: +25 monedas'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('compra una skin y descuenta monedas', (tester) async {
    final store = await pumpStore(tester);

    await tester.tap(find.text('Comprar').first);
    await tester.pumpAndSettle();

    expect(find.text('Confirmar compra'), findsOneWidget);
    expect(find.text('Pixel Art'), findsWidgets);
    expect(find.text('Comprar por 120'), findsOneWidget);

    await tester.tap(find.text('Comprar por 120'));
    await tester.pumpAndSettle();

    expect(store.lastPurchasedCode, 'skin_pixel');
    expect(store.snapshot.coins, 120);
    expect(find.text('120'), findsOneWidget);
    expect(find.text('¡Compraste Pixel Art!'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('bloquea la compra si no hay saldo suficiente', (tester) async {
    final store = FakeStoreRepository(snapshot: demoStoreSnapshot(coins: 10));
    await pumpStore(tester, storeRepository: store);

    await tester.tap(find.text('Comprar').first);
    await tester.pumpAndSettle();

    expect(find.text('Saldo insuficiente'), findsOneWidget);

    final button = tester.widget<FilledButton>(
      find.widgetWithText(FilledButton, 'Saldo insuficiente'),
    );
    expect(button.onPressed, isNull);
    expect(store.lastPurchasedCode, isNull);
    expect(tester.takeException(), isNull);
  });

  testWidgets('equipa una skin comprada', (tester) async {
    final store = FakeStoreRepository(
      snapshot: demoStoreSnapshot(items: withOwned('skin_pixel')),
    );
    await pumpStore(tester, storeRepository: store);

    await tester.tap(find.text('Equipar'));
    await tester.pumpAndSettle();

    expect(store.lastEquippedCode, 'skin_pixel');
    expect(store.snapshot.equippedSkin?.code, 'skin_pixel');
    expect(find.text('Pixel Art equipado.'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('compra y equipa un título', (tester) async {
    final store = await pumpStore(tester);

    await tester.tap(find.text('Títulos'));
    await tester.pumpAndSettle();

    expect(find.text('Novato'), findsWidgets);
    expect(find.text('Explorador'), findsWidgets);
    expect(find.text('80'), findsOneWidget);

    await confirmPurchase(tester, 'Comprar');

    expect(store.lastPurchasedCode, 'title_explorer');
    expect(find.text('Equipar'), findsOneWidget);

    await tester.tap(find.text('Equipar'));
    await tester.pumpAndSettle();

    expect(store.lastEquippedCode, 'title_explorer');
    expect(store.snapshot.equippedTitle?.code, 'title_explorer');
    expect(tester.takeException(), isNull);
  });

  testWidgets('añade una plantilla a Mis diagramas', (tester) async {
    final store = FakeStoreRepository(
      snapshot: demoStoreSnapshot(items: withOwned('template_age')),
    );
    await pumpStore(tester, storeRepository: store);

    await tester.ensureVisible(find.text('Plantillas'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Plantillas'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Añadir'));
    await tester.pumpAndSettle();

    expect(store.lastTemplateCode, 'template_age');
    expect(find.text('Plantilla añadida a Mis diagramas.'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('usa un consumible y activa el XP x2', (tester) async {
    final store = FakeStoreRepository(
      snapshot: demoStoreSnapshot(items: withOwned('consumable_xp_boost')),
    );
    await pumpStore(tester, storeRepository: store);

    await tester.ensureVisible(find.text('Extras'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Extras'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Usar'));
    await tester.pumpAndSettle();

    expect(store.lastConsumableCode, 'consumable_xp_boost');
    expect(find.text('XP x2 activo'), findsOneWidget);
    expect(find.text('XP x2 activado durante 24 h.'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('reclama el cofre diario', (tester) async {
    final store = await pumpStore(tester);

    await tester.tap(find.text('Reclamar'));
    await tester.pumpAndSettle();

    expect(store.snapshot.coins, 265);
    expect(find.text('265'), findsOneWidget);
    expect(find.text('¡Cofre reclamado! +25 monedas.'), findsOneWidget);
    expect(find.text('En espera'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('muestra error y permite reintentar', (tester) async {
    final store = FakeStoreRepository(
      loadFailure: const StoreFailure(
        'No pudimos cargar la tienda. Inténtalo de nuevo.',
      ),
    );

    await pumpStore(tester, storeRepository: store);

    expect(find.text('No pudimos cargar la tienda'), findsOneWidget);
    expect(find.text('Reintentar'), findsOneWidget);

    store.loadFailure = null;
    await tester.tap(find.text('Reintentar'));
    await tester.pumpAndSettle();

    expect(find.text('Tienda Flow'), findsOneWidget);
    expect(store.loadCalls, greaterThanOrEqualTo(2));
    expect(tester.takeException(), isNull);
  });

  testWidgets('no desborda en una pantalla pequeña', (tester) async {
    await pumpStore(tester, size: const Size(320, 640));

    expect(find.text('Tienda Flow'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });
}
