import 'dart:io';
import 'dart:ui' as ui;
import 'package:flutter/rendering.dart';
import 'package:BeyondHorizonCalc/widgets/calculator/results_display.dart';
import 'package:BeyondHorizonCalc/widgets/calculator/diagram/diagram_key.dart';
import 'dart:typed_data';

import 'package:BeyondHorizonCalc/models/line_of_sight_preset.dart';
import 'package:BeyondHorizonCalc/services/curvature_calculator.dart';
import 'package:BeyondHorizonCalc/widgets/calculator/share_result_dialog.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  setUpAll(() async {
    // Optional real font and artifact output for human inspection; normal CI
    // still exercises the actual rendering/encoding/copy callback below.
    final font = Platform.environment['BHC_TEST_FONT'];
    if (font != null) {
      final icons = FontLoader('MaterialIcons')
        ..addFont(rootBundle.load('fonts/MaterialIcons-Regular.otf'));
      await icons.load();
      for (final family in [
        'ArtifactRoboto',
        'Calibri',
        'Calibri, Calibri_MSFontService, sans-serif',
        'Arial',
        'sans-serif'
      ]) {
        final loader = FontLoader(family)
          ..addFont(
              Future.value(ByteData.sublistView(File(font).readAsBytesSync())));
        await loader.load();
      }
    }
  });

  for (final width in [390.0, 1400.0]) {
    testWidgets('renders page results and expanded key $width', (tester) async {
      tester.view.devicePixelRatio = 1;
      tester.view.physicalSize = Size(width, 1600);
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);
      final key = GlobalKey();
      final result = CurvatureCalculator.calculate(
          observerHeight: 2,
          distance: 50,
          refractionFactor: 1,
          isMetric: true,
          targetHeight: 10);
      await tester.pumpWidget(MaterialApp(
        theme: ThemeData(
            fontFamily: Platform.environment['BHC_TEST_FONT'] == null
                ? null
                : 'ArtifactRoboto'),
        home: Scaffold(
            body: RepaintBoundary(
                key: key,
                child: ColoredBox(
                  color: Colors.white,
                  child: Column(mainAxisSize: MainAxisSize.min, children: [
                    ResultsDisplay(
                        result: result, isMetric: true, targetHeight: 10),
                    const DiagramKey(),
                  ]),
                ))),
      ));
      await tester.tap(find.text('Diagram key: points and distances'));
      await tester.pumpAndSettle();
      expect(find.text('C-Z'), findsOneWidget);
      expect(find.text('148.6 m'), findsOneWidget);
      expect(tester.takeException(), isNull);
      final boundary =
          key.currentContext!.findRenderObject()! as RenderRepaintBoundary;
      final bytes = await tester.runAsync(() async {
        final image = await boundary.toImage(pixelRatio: 2);
        try {
          return (await image.toByteData(format: ui.ImageByteFormat.png))!
              .buffer
              .asUint8List();
        } finally {
          image.dispose();
        }
      });
      expect(bytes!.length, greaterThan(1000));
      final output = Platform.environment['BHC_PNG_OUTPUT_DIR'];
      if (output != null) {
        File('$output/target-shortfall-page-key-${width.toInt()}.png')
            .writeAsBytesSync(bytes);
      }
    });
    for (final metric in [true, false]) {
      testWidgets('exports hidden target PNG $width metric=$metric',
          (tester) async {
        rootBundle.clear();
        tester.view.devicePixelRatio = 1;
        tester.view.physicalSize = Size(width, 1800);
        addTearDown(tester.view.resetPhysicalSize);
        addTearDown(tester.view.resetDevicePixelRatio);
        Uint8List? copied;
        final result = CurvatureCalculator.calculate(
            observerHeight: metric ? 2 : 2 / 0.3048,
            distance: metric ? 50 : 50000 / 1609.34,
            refractionFactor: 1,
            isMetric: metric,
            targetHeight: metric ? 10 : 10 / 0.3048);
        await tester.pumpWidget(MaterialApp(
          theme: ThemeData(
              fontFamily: Platform.environment['BHC_TEST_FONT'] == null
                  ? null
                  : 'ArtifactRoboto'),
          home: Scaffold(
              body: ShareResultDialog(
            scenarioName: 'My own values',
            observerHeight: metric ? '2' : (2 / 0.3048).toStringAsFixed(3),
            surfaceElevation: '0',
            distance: metric ? '50' : (50000 / 1609.34).toStringAsFixed(3),
            refractionFactor: '1',
            targetHeight: metric ? '10' : (10 / 0.3048).toStringAsFixed(3),
            targetBaseElevation: '0',
            targetInputType: TargetInputType.elevation,
            result: result,
            isMetric: metric,
            onCopyPng: (bytes) async => copied = bytes,
          )),
        ));
        for (var i = 0; i < 10; i++) {
          await tester.runAsync(
              () => Future<void>.delayed(const Duration(milliseconds: 50)));
          await tester.pump(const Duration(milliseconds: 100));
        }
        expect(
            find.text('Target top below horizon line (CZ)'), findsOneWidget);
        expect(find.byType(CircularProgressIndicator), findsNothing);
        expect(find.text('beyondhorizoncalc.com'), findsOneWidget);
        expect(tester.takeException(), isNull);
        tester
            .widget<FilledButton>(
                find.byWidgetPredicate((widget) => widget is FilledButton))
            .onPressed!();
        await tester.pump();
        await tester.runAsync(() async {
          for (var i = 0; i < 40 && copied == null; i++) {
            await Future<void>.delayed(const Duration(milliseconds: 100));
          }
        });
        expect(copied, isNotNull);
        expect(copied!.length, greaterThan(1000));
        expect(copied!.take(8), [137, 80, 78, 71, 13, 10, 26, 10]);
        final output = Platform.environment['BHC_PNG_OUTPUT_DIR'];
        if (output != null) {
          final file = File(
              '$output/target-shortfall-${width.toInt()}-${metric ? 'metric' : 'imperial'}.png');
          file.writeAsBytesSync(copied!);
          print('PNG ${file.absolute.path} (${copied!.length} bytes)');
        }
        await tester.pump();
        expect(
            find.text('PNG copied. Paste it into your post.'), findsOneWidget);
        expect(tester.takeException(), isNull);
      });
    }
  }
}
