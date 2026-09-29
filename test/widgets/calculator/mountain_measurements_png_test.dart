import 'dart:io';
import 'dart:ui' as ui;

import 'package:BeyondHorizonCalc/services/curvature_calculator.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:flutter_test/flutter_test.dart';

import 'mountain_measurements_test.dart' show render;

void main() {
  setUpAll(() async {
    final font = Platform.environment['BHC_TEST_FONT'];
    if (font != null) {
      for (final family in [
        'Calibri',
        'Calibri, Calibri_MSFontService, sans-serif'
      ]) {
        await (FontLoader(family)
              ..addFont(Future.value(
                  ByteData.sublistView(File(font).readAsBytesSync()))))
            .load();
      }
    }
  });
  for (final width in [390.0, 1400.0]) {
    for (final scenario in ['hidden', 'tiny', 'above']) {
      testWidgets('Flutter SVG render $scenario at $width', (tester) async {
        tester.view.devicePixelRatio = 1;
        tester.view.physicalSize = Size(width, 1500);
        addTearDown(tester.view.resetPhysicalSize);
        addTearDown(tester.view.resetDevicePixelRatio);
        final cutoff = CurvatureCalculator.calculate(
                observerHeight: 2000,
                distance: 500,
                refractionFactor: 1,
                isMetric: true)
            .cutoffElevation!;
        final target = scenario == 'hidden'
            ? 5193.0
            : cutoff * 1000 + (scenario == 'tiny' ? -0.01 : 2000);
        final result = CurvatureCalculator.calculate(
            observerHeight: 2000,
            distance: 500,
            refractionFactor: 1,
            isMetric: true,
            targetHeight: target);
        final svg = (await tester.runAsync(() => render(result, target)))!;
        final key = GlobalKey();
        await tester.pumpWidget(MaterialApp(
            home: Scaffold(
                body: Center(
          child: RepaintBoundary(
            key: key,
            child: ColoredBox(
                color: Colors.white,
                child: SizedBox(
                    width: width < 683 ? width : 683,
                    height: 1400,
                    child: SvgPicture.string(svg, fit: BoxFit.contain))),
          ),
        ))));
        await tester.pumpAndSettle();
        expect(tester.takeException(), isNull);
        final bytes = await tester.runAsync(() async {
          final image = await (key.currentContext!.findRenderObject()!
                  as RenderRepaintBoundary)
              .toImage(pixelRatio: 2);
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
          File('$output/flutter-mountain-$scenario-${width.toInt()}.png')
              .writeAsBytesSync(bytes);
        }
      });
    }
  }
}
