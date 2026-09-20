import 'dart:convert';

import 'package:BeyondHorizonCalc/services/custom_scenario_store.dart';
import 'package:BeyondHorizonCalc/models/line_of_sight_preset.dart';
import 'package:BeyondHorizonCalc/widgets/calculator_form.dart';
import 'package:BeyondHorizonCalc/widgets/calculator/input_fields.dart';
import 'package:BeyondHorizonCalc/widgets/calculator/results_display.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';

import '../services/custom_scenario_store_test.dart' show scenario;
import 'calculator_form_test.dart' show inputField;

class MemoryStorage {
  bool unavailable = false;
  bool cannotClear = false;
  String? value;
  int writes = 0;
  late final store = CustomScenarioStore(
    read: () => unavailable ? throw StateError('blocked') : value,
    write: (raw) {
      if (unavailable) throw StateError('blocked');
      value = raw;
      writes++;
    },
    remove: () {
      if (unavailable || cannotClear) throw StateError('blocked');
      value = null;
    },
  );
}

Future<void> mount(WidgetTester tester, MemoryStorage memory) async {
  rootBundle.clear();
  await tester.binding.setSurfaceSize(const Size(1400, 3000));
  addTearDown(() => tester.binding.setSurfaceSize(null));
  await tester.pumpWidget(MaterialApp(
    home: Scaffold(body: CalculatorForm(scenarioStore: memory.store)),
  ));
  for (var i = 0; i < 100; i++) {
    await tester
        .runAsync(() => Future<void>.delayed(const Duration(milliseconds: 20)));
    await tester.pump();
    if (find
        .byKey(const ValueKey('preset_mode_selector'))
        .evaluate()
        .isNotEmpty) {
      await tester.pump();
      return;
    }
  }
  fail('Calculator did not load');
}

InputFields inputs(WidgetTester tester) =>
    tester.widget(find.byType(InputFields));

void main() {
  for (final above in [true, false]) {
    testWidgets('zero surface restores its explicit mode: above=$above',
        (tester) async {
      final saved = scenario()
        ..['surfaceElevation'] = '0'
        ..['surfaceAboveSeaLevel'] = above
        ..['targetHeight'] = ''
        ..['targetBaseElevation'] = '';
      final memory = MemoryStorage()..value = jsonEncode(saved);
      await mount(tester, memory);
      expect(inputField('Horizon surface elevation'),
          above ? findsOneWidget : findsNothing);
      expect(inputs(tester).targetHeightController.text, '');
      expect(inputs(tester).targetBaseElevationController.text, '');
      await tester.binding.setSurfaceSize(const Size(590, 5000));
      await tester.pump();
      await tester.pump();
      expect(inputField('Horizon surface elevation'),
          above ? findsOneWidget : findsNothing);
      expect(inputs(tester).interveningSurfaceElevationController.text, '0');
      expect(tester.takeException(), isNull);
    });
  }

  for (final unavailable in [true, false]) {
    testWidgets(
        'bad or unavailable storage falls back to the example: blocked=$unavailable',
        (tester) async {
      final memory = MemoryStorage()
        ..value = '{bad'
        ..unavailable = unavailable;
      await mount(tester, memory);
      expect(inputs(tester).isCustomPreset, isFalse);
      expect(find.text('Previous custom values restored'), findsNothing);
      await tester.tap(find.text('Edit these values'));
      await tester.pump();
      await tester.pump();
      await tester.enterText(inputField('Surface distance to target'), '50');
      await tester.tap(find.text('Calculate visibility'));
      await tester.pump();
      expect(
          tester
              .widget<ResultsDisplay>(find.byType(ResultsDisplay))
              .result!
              .inputDistance,
          50);
      expect(tester.takeException(), isNull);
    });
  }

  testWidgets('failed clear reports failure and retains the saved record',
      (tester) async {
    final memory = MemoryStorage()
      ..value = jsonEncode(scenario())
      ..cannotClear = true;
    await mount(tester, memory);
    await tester.tap(find.text('Clear saved values'));
    await tester.pump();
    expect(memory.store.load(), scenario());
    expect(find.text('Previous custom values restored'), findsOneWidget);
    expect(find.text('Saved values could not be cleared in this browser.'),
        findsOneWidget);
  });

  testWidgets(
      'reload ignores unfinished edits and successful unit calculation saves converted inputs',
      (tester) async {
    final memory = MemoryStorage()..value = jsonEncode(scenario());
    await mount(tester, memory);
    await tester.enterText(inputField('Surface distance to target'), '32');
    await tester.pump();
    await tester.pumpWidget(const SizedBox.shrink());
    await mount(tester, memory);
    expect(inputs(tester).distanceController.text, '25');
    await tester.tap(find.text('Metric'));
    await tester.pump();
    await tester.pump();
    final saved = memory.store.load()!;
    expect(saved['isMetric'], isTrue);
    expect(
        saved['observerHeight'], inputs(tester).observerHeightController.text);
    expect(saved['surfaceElevation'],
        inputs(tester).interveningSurfaceElevationController.text);
    expect(saved['distance'], inputs(tester).distanceController.text);
    expect(memory.writes, 1);
    await tester.pumpWidget(const SizedBox.shrink());
    await mount(tester, memory);
    expect(inputs(tester).isMetric, isTrue);
    expect(inputs(tester).distanceController.text, saved['distance']);
    expect(memory.writes, 1);
  });

  testWidgets(
      'clear removes storage without resetting fields or resaving on mode changes',
      (tester) async {
    final memory = MemoryStorage()..value = jsonEncode(scenario());
    await mount(tester, memory);
    await tester.enterText(inputField('Surface distance to target'), '32');
    await tester.pump();
    final result =
        tester.widget<ResultsDisplay>(find.byType(ResultsDisplay)).result;
    expect(find.text('Clear saved values'), findsOneWidget);
    await tester.tap(find.text('Clear saved values'));
    await tester.pump();
    expect(memory.value, isNull);
    expect(inputs(tester).distanceController.text, '32');
    expect(inputs(tester).isMetric, isFalse);
    expect(inputs(tester).interveningSurfaceElevationController.text, '20');
    expect(tester.widget<ResultsDisplay>(find.byType(ResultsDisplay)).result,
        same(result));
    expect(find.text('Inputs changed — recalculate'), findsOneWidget);
    expect(find.text('Previous custom values restored'), findsNothing);
    await tester.binding.setSurfaceSize(const Size(590, 5000));
    await tester.pump();
    await tester.pump();
    await tester.tap(find.text('Example scenario'));
    await tester.pump();
    await tester.pump();
    await tester.tap(find.text('My own values'));
    await tester.pump();
    await tester.pump();
    expect(memory.value, isNull);
    expect(memory.writes, 0);
    await tester.tap(find.text('Calculate visibility'));
    await tester.pump();
    expect(memory.store.load(), isNotNull);
    expect(memory.writes, 1);
  });

  testWidgets(
      'My own values restores saved custom but Edit these values copies the example',
      (tester) async {
    final memory = MemoryStorage()..value = jsonEncode(scenario());
    await mount(tester, memory);
    final saved = memory.value;
    await tester.tap(find.text('Example scenario'));
    await tester.pump();
    await tester.pump();
    expect(find.text('Previous custom values restored'), findsNothing);
    expect(inputField('Horizon surface elevation'), findsNothing);
    final exampleObserver = inputs(tester).observerHeightController.text;
    await tester.tap(find.text('My own values'));
    await tester.pump();
    await tester.pump();
    expect(inputs(tester).observerHeightController.text, '300');
    expect(inputs(tester).interveningSurfaceElevationController.text, '20');
    expect(find.text('Previous custom values restored'), findsOneWidget);
    await tester.tap(find.text('Example scenario'));
    await tester.pump();
    await tester.pump();
    await tester.tap(find.text('Edit these values'));
    await tester.pump();
    await tester.pump();
    expect(inputs(tester).isCustomPreset, isTrue);
    expect(inputs(tester).observerHeightController.text, exampleObserver);
    expect(find.text('Previous custom values restored'), findsNothing);
    expect(memory.value, saved);
    expect(memory.writes, 0);
  });

  testWidgets('only successful custom calculations replace the saved inputs',
      (tester) async {
    final memory = MemoryStorage();
    await mount(tester, memory);
    expect(memory.value, isNull);
    await tester.tap(find.text('Edit these values'));
    await tester.pump();
    await tester.pump();
    expect(memory.value, isNull); // Copying is not a new calculation request.
    await tester.enterText(inputField('Surface distance to target'), '42');
    await tester.pump();
    expect(memory.value, isNull);
    await tester.tap(find.text('Calculate visibility'));
    await tester.pump();
    expect(memory.store.load(), isNotNull);
    expect(memory.store.load()!['distance'], '42');
    final saved = memory.value;
    await tester.enterText(inputField('Surface distance to target'), '0');
    await tester.tap(find.text('Calculate visibility'));
    await tester.pump();
    expect(memory.value, saved);
    await tester.tap(find.text('Example scenario'));
    await tester.pump();
    await tester.pump();
    await tester.tap(find.text('Calculate visibility'));
    await tester.pump();
    expect(memory.value, saved);
    expect(memory.writes, 1);
  });

  testWidgets(
      'reload restores every custom input and recalculates without writing',
      (tester) async {
    final memory = MemoryStorage()..value = jsonEncode(scenario());
    await mount(tester, memory);
    final fields = inputs(tester);
    expect(fields.isCustomPreset, isTrue);
    expect(fields.isMetric, isFalse);
    expect(fields.targetInputType, TargetInputType.structure);
    expect(fields.observerHeightController.text, '300');
    expect(fields.distanceController.text, '25');
    expect(fields.refractionFactorController.text, '1.07');
    expect(fields.targetHeightController.text, '100');
    expect(fields.targetBaseElevationController.text, '50');
    expect(fields.interveningSurfaceElevationController.text, '20');
    expect(inputField('Horizon surface elevation'), findsOneWidget);
    expect(find.text('Previous custom values restored'), findsOneWidget);
    final result = tester.widget<ResultsDisplay>(find.byType(ResultsDisplay));
    expect(result.isMetric, isFalse);
    expect(result.result!.inputDistance, closeTo(25 * 1.60934, 0.001));
    expect(result.result!.h1, closeTo(280, 0.001));
    expect(memory.writes, 0);
    expect(tester.takeException(), isNull);
  });
}
