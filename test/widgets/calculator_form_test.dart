import 'package:BeyondHorizonCalc/widgets/calculator_form.dart';
import 'package:BeyondHorizonCalc/models/line_of_sight_preset.dart';
import 'package:BeyondHorizonCalc/services/models/calculation_result.dart';
import 'package:BeyondHorizonCalc/widgets/calculator/share_result_dialog.dart';
import 'package:BeyondHorizonCalc/widgets/calculator/input_fields.dart';
import 'package:BeyondHorizonCalc/widgets/calculator/results_display.dart';
import 'package:BeyondHorizonCalc/widgets/calculator/diagram_display.dart';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';

Future<void> pumpCalculatorWithPresets(WidgetTester tester) async {
  rootBundle.clear();
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

Finder inputField(String label) => find.byWidgetPredicate(
      (widget) => widget is TextField && widget.decoration?.labelText == label,
    );

void main() {
  testWidgets('Narrow rebuild safely tracks surface controller changes',
      (tester) async {
    await pumpCalculatorWithPresets(tester);
    await tester.tap(find.text('Edit these values'));
    await tester.pump();
    await tester.pump();
    await tester.tap(find.text('Surface above sea level'));
    await tester.pump();
    await tester.enterText(inputField('Horizon surface elevation'), '10');
    await tester.tap(find.text('Calculate visibility'));
    await tester.pump();
    await tester.binding.setSurfaceSize(const Size(590, 5000));
    await tester.pump();
    await tester.pump();
    expect(tester.takeException(), isNull);
    expect(find.text('Inputs changed — recalculate'), findsNothing);
    expect(
        tester
            .widget<InputFields>(find.byType(InputFields))
            .interveningSurfaceElevationController
            .text,
        '10');
    await tester.enterText(inputField('Horizon surface elevation'), '11');
    await tester.pump();
    expect(find.text('Inputs changed — recalculate'), findsOneWidget);
    await tester.tap(find.text('Calculate visibility'));
    await tester.pump();
    expect(find.text('Inputs changed — recalculate'), findsNothing);
    await tester.pumpWidget(const SizedBox.shrink());
    await tester.pump();
    expect(tester.takeException(), isNull);
  });

  for (final entry in {
    'Observer eye elevation': '100',
    'Distance to target': '50',
    'Target top elevation (optional)': '200',
    'Base elevation': '20',
    'Horizon surface elevation': '10',
  }.entries) {
    testWidgets('${entry.key} marks results dirty', (tester) async {
      await pumpCalculatorWithPresets(tester);
      await tester.tap(find.text('Edit these values'));
      await tester.pump();
      await tester.pump();
      if (entry.key == 'Base elevation') {
        await tester.tap(find.text('Structure height + base elevation'));
        await tester.pump();
      }
      if (entry.key == 'Horizon surface elevation') {
        await tester.tap(find.text('Surface above sea level'));
        await tester.pump();
      }
      await tester.tap(find.text('Calculate visibility'));
      await tester.pump();
      expect(find.text('Inputs changed — recalculate'), findsNothing);
      await tester.enterText(inputField(entry.key), entry.value);
      await tester.pump();
      expect(find.text('Inputs changed — recalculate'), findsOneWidget);
      await tester.tap(find.text('Calculate visibility'));
      await tester.pump();
      expect(find.text('Inputs changed — recalculate'), findsNothing);
    });
  }

  testWidgets('Refraction changes also mark example results dirty',
      (tester) async {
    await pumpCalculatorWithPresets(tester);
    await tester.pump();
    final oldResult =
        tester.widget<ResultsDisplay>(find.byType(ResultsDisplay)).result;
    await tester.tap(find.text('Very High (1.20)').last);
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 300));
    await tester.tap(find.text('None (1.00)').last);
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 300));
    expect(find.text('Inputs changed — recalculate'), findsOneWidget);
    expect(tester.widget<ResultsDisplay>(find.byType(ResultsDisplay)).result,
        same(oldResult));
    await tester.tap(find.text('Share result'));
    await tester.pump();
    final dialog =
        tester.widget<ShareResultDialog>(find.byType(ShareResultDialog));
    expect(dialog.refractionFactor, '1.00');
    expect(dialog.result.horizonDistance, isNot(oldResult!.horizonDistance));
  });

  testWidgets('Surface selection tracks its effective elevation',
      (tester) async {
    await pumpCalculatorWithPresets(tester);
    await tester.tap(find.text('Edit these values'));
    await tester.pump();
    await tester.pump();
    await tester.tap(find.text('Surface above sea level'));
    await tester.pump();

    await tester.enterText(inputField('Horizon surface elevation'), '10');
    await tester.tap(find.text('Calculate visibility'));
    await tester.pump();
    await tester.tap(find.text('Sea level'));
    await tester.pump();
    expect(find.text('Inputs changed — recalculate'), findsOneWidget);
    await tester.tap(find.text('Calculate visibility'));
    await tester.pump();
    await tester.tap(find.text('Surface above sea level'));
    await tester.pump();
    expect(find.text('Inputs changed — recalculate'), findsOneWidget);
    await tester.tap(find.text('Share result'));
    await tester.pump();
    final dialog =
        tester.widget<ShareResultDialog>(find.byType(ShareResultDialog));
    expect(dialog.surfaceElevation, '10');
    expect(dialog.result.h1, 3025);
  });

  testWidgets('Units preserve dirty invalid inputs and presets recalculate',
      (tester) async {
    await pumpCalculatorWithPresets(tester);
    await tester.tap(find.text('Edit these values'));
    await tester.pump();
    await tester.pump();
    final oldResult =
        tester.widget<ResultsDisplay>(find.byType(ResultsDisplay)).result;
    await tester.enterText(inputField('Distance to target'), '.');
    await tester.tap(find.text('Imperial'));
    await tester.pump();
    await tester.pump();
    expect(tester.takeException(), isNull);
    expect(find.text('Inputs changed — recalculate'), findsOneWidget);
    expect(tester.widget<ResultsDisplay>(find.byType(ResultsDisplay)).result,
        same(oldResult));
    expect(tester.widget<ResultsDisplay>(find.byType(ResultsDisplay)).isMetric,
        isTrue);
    await tester.tap(find.text('Share result'));
    await tester.pump();
    expect(find.byType(ShareResultDialog), findsNothing);
    await tester.enterText(inputField('Distance to target'), '50');
    await tester.tap(find.text('Metric'));
    await tester.pump();
    await tester.pump();
    expect(find.text('Inputs changed — recalculate'), findsNothing);
    await tester.enterText(inputField('Distance to target'), '0');
    await tester.pump();
    expect(find.text('Inputs changed — recalculate'), findsOneWidget);
    await tester.tap(find.text('Example scenario'));
    await tester.pump();
    await tester.pump();
    expect(find.text('Inputs changed — recalculate'), findsNothing);
    expect(
        tester
            .widget<ResultsDisplay>(find.byType(ResultsDisplay))
            .result!
            .inputDistance,
        493.1);
  });

  testWidgets('Target mode changes flag the retained result snapshot',
      (tester) async {
    await pumpCalculatorWithPresets(tester);
    await tester.tap(find.text('Edit these values'));
    await tester.pump();
    await tester.pump();
    final oldDiagram =
        tester.widget<DiagramDisplay>(find.byType(DiagramDisplay));
    await tester.tap(find.text('Structure height + base elevation'));
    await tester.pump();
    expect(find.text('Inputs changed — recalculate'), findsOneWidget);
    expect(
        tester
            .widget<DiagramDisplay>(find.byType(DiagramDisplay))
            .isStructureTarget,
        oldDiagram.isStructureTarget);
    await tester.enterText(inputField('Structure height (optional)'), '100');
    await tester.enterText(inputField('Base elevation'), '200');
    await tester.pump();
    expect(
        tester.widget<ResultsDisplay>(find.byType(ResultsDisplay)).targetHeight,
        oldDiagram.targetHeight);
    await tester.tap(find.text('Share result'));
    await tester.pump();
    final dialog =
        tester.widget<ShareResultDialog>(find.byType(ShareResultDialog));
    expect(dialog.targetHeight, '100');
    expect(dialog.targetBaseElevation, '200');
    expect(dialog.targetInputType, TargetInputType.structure);
    expect(find.text('Inputs changed — recalculate'), findsNothing);
  });
  testWidgets('Edited inputs stay dirty until calculation succeeds',
      (tester) async {
    await pumpCalculatorWithPresets(tester);
    await tester.tap(find.text('Edit these values'));
    await tester.pump();
    await tester.pump();
    final dirty = find.text('Inputs changed — recalculate');
    expect(dirty, findsNothing);
    final observer = tester
        .widget<TextField>(inputField('Observer eye elevation'))
        .controller!;
    observer.selection = const TextSelection.collapsed(offset: 1);
    await tester.pump();
    expect(dirty, findsNothing);
    await tester.enterText(inputField('Distance to target'), '0');
    await tester.pump();
    expect(dirty, findsOneWidget);
    await tester.tap(find.text('Calculate visibility'));
    await tester.pump();
    expect(dirty, findsOneWidget);
    await tester.tap(find.text('Share result'));
    await tester.pump();
    expect(find.byType(ShareResultDialog), findsNothing);
    expect(find.text('Distance must be greater than 0'), findsOneWidget);
    expect(dirty, findsOneWidget);
    await tester.enterText(inputField('Distance to target'), '493.1');
    await tester.pump();
    expect(dirty, findsOneWidget); // Reverting text is not recalculation.
    await tester.tap(find.text('Calculate visibility'));
    await tester.pump();
    expect(dirty, findsNothing);
  });

  testWidgets('Share recalculates edited inputs before capturing the summary',
      (tester) async {
    await pumpCalculatorWithPresets(tester);
    await tester.tap(find.text('Edit these values'));
    await tester.pump();
    await tester.pump();
    await tester.enterText(inputField('Observer eye elevation'), '100');
    await tester.enterText(inputField('Distance to target'), '50');
    await tester.tap(find.text('Share result'));
    await tester.pump();
    final dialog =
        tester.widget<ShareResultDialog>(find.byType(ShareResultDialog));
    expect(dialog.observerHeight, '100');
    expect(dialog.distance, '50');
    expect(dialog.result.h1, 100);
    expect(dialog.result.inputDistance, 50);
  });

  testWidgets('Share result opens a compact input and result summary',
      (tester) async {
    await pumpCalculatorWithPresets(tester);

    expect(find.byType(Form), findsOneWidget);
    expect(find.text('Share result'), findsOneWidget);
    final shareCenter = tester.getCenter(find.text('Share result'));
    final calculateCenter = tester.getCenter(find.text('Calculate visibility'));
    expect(shareCenter.dy, closeTo(calculateCenter.dy, 1));
    expect(shareCenter.dx, lessThan(calculateCenter.dx));
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
