import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:flow_app/app.dart';

void main() {
  Future<void> pumpStore(
    WidgetTester tester, {
    Size size = const Size(390, 844),
  }) async {
    tester.view.physicalSize = size;
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await tester.pumpWidget(const FlowApp());
    await tester.tap(find.text('Tienda'));
    await tester.pumpAndSettle();
  }

  testWidgets('muestra la tienda estática', (tester) async {
    await pumpStore(tester);

    expect(find.text('Tienda Flow'), findsOneWidget);
    expect(find.text('TU SALDO'), findsOneWidget);
    expect(find.text('240'), findsOneWidget);
    expect(find.text('Skins para diagramas'), findsOneWidget);
    expect(find.text('3 estilos'), findsOneWidget);
    expect(find.text('Clásico'), findsOneWidget);
    expect(find.text('Equipada'), findsOneWidget);
    expect(find.text('Pixel Art'), findsOneWidget);
    expect(find.text('120'), findsOneWidget);
    expect(find.text('Cyber'), findsOneWidget);
    expect(find.text('200'), findsOneWidget);
    expect(find.text('Ver skin'), findsNWidgets(3));
    expect(tester.takeException(), isNull);
  });

  testWidgets('no desborda en una pantalla pequeña', (tester) async {
    await pumpStore(tester, size: const Size(320, 640));

    expect(find.text('Tienda Flow'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });
}
