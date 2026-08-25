import 'package:BeyondHorizonCalc/widgets/calculator_form.dart';
import 'package:BeyondHorizonCalc/models/line_of_sight_preset.dart';
import 'package:BeyondHorizonCalc/services/models/calculation_result.dart';
import 'package:BeyondHorizonCalc/widgets/calculator/share_result_dialog.dart';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

Future<void> pumpCalculatorWithPresets(WidgetTester tester) async {
  await tester.binding.setSurfaceSize(const Size(1400, 3000));
  addTearDown(() => tester.binding.setSurfaceSize(null));

  await tester.pumpWidget(
    const MaterialApp(
      home: Scaffold(body: CalculatorForm()),
    ),
  );

  for (var attempt = 0; attempt < 100; attempt++) {
    await tester.runAsync(
      () => Future<void>.delayed(const Duration(milliseconds: 50)),
    );
    await tester.pump();
    if (find.byKey(const ValueKey('preset_dropdown')).evaluate().isNotEmpty) {
      return;
    }
  }

  fail('The default example scenario did not finish loading');
}

void main() {
  testWidgets('Share result opens a compact input and result summary',
      (tester) async {
    await pumpCalculatorWithPresets(tester);

    expect(find.byType(Form), findsOneWidget);
    expect(find.text('Share result'), findsOneWidget);
    await tester.tap(find.text('Share result'));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 300));

    expect(find.byKey(const ValueKey('share_result_dialog')), findsOneWidget);
    expect(find.text('Beyond Horizon Calculator'), findsOneWidget);
    expect(find.text('Inputs'), findsOneWidget);
    expect(find.text('Results'), findsOneWidget);
    expect(find.text('Karagöl Area to Shkhara - World Record'), findsWidgets);
    expect(find.text('3035.0 m AMSL'), findsOneWidget);
    expect(find.text('493.1 km'), findsOneWidget);
    expect(find.text('1.20'), findsOneWidget);
    expect(find.text('Apparent visible height'), findsNothing);
    expect(find.byKey(const ValueKey('share_result_diagram')), findsOneWidget);
    expect(find.byKey(const ValueKey('share_result_globe')), findsOneWidget);
    expect(find.byKey(const ValueKey('share_result_png')), findsOneWidget);
    expect(find.text('Copy PNG'), findsOneWidget);
    expect(find.text('Download PNG'), findsOneWidget);
  });

  testWidgets('Copy PNG creates a real PNG image', (tester) async {
    await tester.binding.setSurfaceSize(const Size(1400, 1200));
    addTearDown(() => tester.binding.setSurfaceSize(null));
    Uint8List? copiedBytes;

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: ShareResultDialog(
            scenarioName: 'Test scenario',
            observerHeight: '3035.0',
            surfaceElevation: '0.0',
            distance: '493.1',
            refractionFactor: '1.20',
            targetHeight: '5193.0',
            targetBaseElevation: '0.0',
            targetInputType: TargetInputType.elevation,
            result: const CalculationResult(
              horizonDistance: 197.3,
              hiddenHeight: 3.2,
              visibleTargetHeight: 1.993,
              dipAngle: 1.75,
              h1: 3035,
            ),
            isMetric: true,
            onCopyPng: (bytes) async => copiedBytes = bytes,
          ),
        ),
      ),
    );
    await tester.pump(const Duration(milliseconds: 500));
    for (var attempt = 0; attempt < 10; attempt++) {
      await tester.runAsync(
        () => Future<void>.delayed(const Duration(milliseconds: 50)),
      );
      await tester.pump();
    }
    final copyButton = tester.widget<FilledButton>(
      find.byWidgetPredicate((widget) => widget is FilledButton),
    );
    copyButton.onPressed!();
    await tester.pump();
    await tester.runAsync(() async {
      for (var attempt = 0; attempt < 20 && copiedBytes == null; attempt++) {
        await Future<void>.delayed(const Duration(milliseconds: 100));
      }
    });

    expect(copiedBytes, isNotNull);
    expect(copiedBytes!.length, greaterThan(1000));
    expect(copiedBytes!.take(8), [137, 80, 78, 71, 13, 10, 26, 10]);
  });
}
