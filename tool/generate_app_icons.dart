import 'dart:io';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';

const _canvasSize = 1024.0;

const _background = BoxDecoration(
  gradient: LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Color(0xFF162538), Color(0xFF0C1726)],
  ),
);

void main() {
  testWidgets('generates FlowApp launcher icon assets', (tester) async {
    await tester.runAsync(_loadMaterialIcons);
    await tester.binding.setSurfaceSize(const Size(_canvasSize, _canvasSize));
    addTearDown(() => tester.binding.setSurfaceSize(null));

    await _export(
      tester,
      'assets/branding/app_icon.png',
      const _IconCanvas(background: _background, markSize: 620),
    );

    await _export(
      tester,
      'assets/branding/app_icon_foreground.png',
      const _IconCanvas(markSize: 620),
    );

    await _export(
      tester,
      'assets/branding/app_icon_monochrome.png',
      const _IconCanvas(markSize: 620, monochrome: true),
    );

    await _export(
      tester,
      'assets/branding/app_icon_macos.png',
      const _IconCanvas(markSize: 480, macos: true),
    );
  });
}

Future<void> _loadMaterialIcons() async {
  final bytes = await File(_materialIconsFontPath()).readAsBytes();
  final loader = FontLoader('MaterialIcons')
    ..addFont(
      Future.value(
        ByteData.view(bytes.buffer, bytes.offsetInBytes, bytes.lengthInBytes),
      ),
    );
  await loader.load();
}

String _materialIconsFontPath() {
  final candidates = <Directory>[];
  final flutterRoot = Platform.environment['FLUTTER_ROOT'];

  if (flutterRoot != null && flutterRoot.isNotEmpty) {
    candidates.add(
      Directory('$flutterRoot/bin/cache/artifacts/material_fonts'),
    );
  }

  var dir = File(Platform.resolvedExecutable).parent;
  for (var i = 0; i < 8; i++) {
    candidates.add(Directory('${dir.path}/material_fonts'));
    candidates.add(Directory('${dir.path}/bin/cache/artifacts/material_fonts'));
    final parent = dir.parent;
    if (parent.path == dir.path) {
      break;
    }
    dir = parent;
  }

  for (final candidate in candidates) {
    if (!candidate.existsSync()) {
      continue;
    }
    for (final entity in candidate.listSync()) {
      if (entity is File &&
          entity.path.toLowerCase().endsWith('materialicons-regular.otf')) {
        return entity.path;
      }
    }
  }

  throw StateError('No se encontró la fuente MaterialIcons de Flutter.');
}

Future<void> _export(WidgetTester tester, String path, Widget child) async {
  final key = GlobalKey();
  await tester.pumpWidget(
    MaterialApp(
      debugShowCheckedModeBanner: false,
      home: RepaintBoundary(
        key: key,
        child: SizedBox(
          width: _canvasSize,
          height: _canvasSize,
          child: child,
        ),
      ),
    ),
  );
  await tester.pumpAndSettle();

  final boundary =
      key.currentContext!.findRenderObject()! as RenderRepaintBoundary;

  await tester.runAsync(() async {
    final image = await boundary.toImage(pixelRatio: 1);
    final data = await image.toByteData(format: ui.ImageByteFormat.png);
    final file = File(path);
    await file.create(recursive: true);
    await file.writeAsBytes(data!.buffer.asUint8List());
    image.dispose();
  });
}

class _IconCanvas extends StatelessWidget {
  const _IconCanvas({
    required this.markSize,
    this.background,
    this.macos = false,
    this.monochrome = false,
  });

  final double markSize;
  final Decoration? background;
  final bool macos;
  final bool monochrome;

  @override
  Widget build(BuildContext context) {
    final mark = _FlowMark(size: markSize, monochrome: monochrome);

    if (macos) {
      return Center(
        child: Container(
          width: 824,
          height: 824,
          decoration: const BoxDecoration(
            borderRadius: BorderRadius.all(Radius.circular(185)),
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [Color(0xFF162538), Color(0xFF0C1726)],
            ),
          ),
          child: Center(child: mark),
        ),
      );
    }

    return Container(
      decoration: background,
      child: Center(child: mark),
    );
  }
}

class _FlowMark extends StatelessWidget {
  const _FlowMark({required this.size, this.monochrome = false});

  final double size;
  final bool monochrome;

  @override
  Widget build(BuildContext context) {
    final icon = Icon(
      Icons.account_tree_rounded,
      size: size,
      color: Colors.white,
    );

    if (monochrome) {
      return icon;
    }

    return ShaderMask(
      blendMode: BlendMode.srcIn,
      shaderCallback: (bounds) => const LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [Color(0xFF58CC02), Color(0xFF38BDF8)],
      ).createShader(bounds),
      child: icon,
    );
  }
}
