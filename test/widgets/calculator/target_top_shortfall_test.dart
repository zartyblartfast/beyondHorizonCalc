import 'package:BeyondHorizonCalc/services/curvature_calculator.dart';
import 'package:BeyondHorizonCalc/models/line_of_sight_preset.dart';
import 'package:BeyondHorizonCalc/services/models/calculation_result.dart';
import 'package:BeyondHorizonCalc/widgets/calculator/results_display.dart';
import 'package:BeyondHorizonCalc/widgets/calculator/share_result_dialog.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

const label = 'Target top below horizon line (CZ)';
Widget page(CalculationResult result, bool metric, {double? top = 110}) =>
    ResultsDisplay(result: result, isMetric: metric, targetHeight: top);
Widget share(CalculationResult result, bool metric, {String top = '110'}) =>
    ShareResultDialog(
        scenarioName: 'My own values',
        observerHeight: '102',
        surfaceElevation: '100',
        distance: '50',
        refractionFactor: '1',
        targetHeight: top,
        targetBaseElevation: '105',
        targetInputType: TargetInputType.elevation,
        result: result,
        isMetric: metric);

void main() {
  CalculationResult calculate(double? top, double distance) =>
      CurvatureCalculator.calculate(
          observerHeight: 102,
          interveningSurfaceElevation: 100,
          distance: distance,
          refractionFactor: 1,
          isMetric: true,
          targetHeight: top,
          targetBaseElevation: 105);
  final cutoff = calculate(null, 50).cutoffElevation! * 1000;
  for (final scenario in [
    (name: 'hidden', top: 110.0, distance: 50.0, shown: true),
    (name: 'boundary', top: cutoff, distance: 50.0, shown: false),
    (name: 'above line', top: cutoff + 1, distance: 50.0, shown: false),
    (name: 'before horizon', top: 110.0, distance: 1.0, shown: false),
    (name: 'missing top', top: null, distance: 50.0, shown: false),
  ]) {
    testWidgets('calculated ${scenario.name} has page/share conditional parity',
        (tester) async {
      final result = calculate(scenario.top, scenario.distance);
      for (final widget in [
        page(result, true, top: scenario.top),
        share(result, true, top: scenario.top?.toString() ?? '')
      ]) {
        await tester.pumpWidget(MaterialApp(home: Scaffold(body: widget)));
        await tester.pump();
        expect(
            find.text(label), scenario.shown ? findsOneWidget : findsNothing);
        expect(tester.takeException(), isNull);
      }
    });
  }
  for (final metric in [true, false]) {
    testWidgets('tiny positive stays positive on page and share metric=$metric',
        (tester) async {
      const result = CalculationResult(targetTopShortfall: 0.000001);
      for (final widget in [page(result, metric), share(result, metric)]) {
        await tester.pumpWidget(MaterialApp(home: Scaffold(body: widget)));
        await tester.pump();
        expect(find.text(label), findsOneWidget);
        expect(find.text(metric ? '< 0.1 m' : '< 0.1 ft'), findsOneWidget);
      }
    });
  }
  for (final shortfall in [null, 0.0]) {
    testWidgets('no row for unavailable or nonpositive shortfall $shortfall',
        (tester) async {
      final result = CalculationResult(targetTopShortfall: shortfall);
      for (final widget in [page(result, true), share(result, true)]) {
        await tester.pumpWidget(MaterialApp(home: Scaffold(body: widget)));
        await tester.pump();
        expect(find.text(label), findsNothing);
      }
    });
  }
  testWidgets('missing top hides row even with stale positive result',
      (tester) async {
    const result = CalculationResult(targetTopShortfall: 0.1);
    for (final widget in [
      page(result, true, top: null),
      share(result, true, top: '')
    ]) {
      await tester.pumpWidget(MaterialApp(home: Scaffold(body: widget)));
      await tester.pump();
      expect(find.text(label), findsNothing);
    }
  });
  for (final width in [390.0, 1400.0]) {
    for (final metric in [true, false]) {
      testWidgets(
          'page/share shortfall parity and wrapping $width metric=$metric',
          (tester) async {
        tester.view.devicePixelRatio = 1;
        tester.view.physicalSize = Size(width, 1600);
        addTearDown(tester.view.resetPhysicalSize);
        addTearDown(tester.view.resetDevicePixelRatio);
        const result = CalculationResult(
            targetTopShortfall: 0.123, visibleTargetHeight: 0);
        for (final isShare in [false, true]) {
          await tester.pumpWidget(MaterialApp(
              home: Scaffold(
                  body:
                      isShare ? share(result, metric) : page(result, metric))));
          for (var i = 0; i < 10; i++) {
            await tester.runAsync(
                () => Future<void>.delayed(const Duration(milliseconds: 50)));
            await tester.pump(const Duration(milliseconds: 100));
          }
          expect(find.text(label), findsOneWidget);
          expect(find.text(metric ? '123.0 m' : '403.5 ft'), findsOneWidget);
          final visible =
              find.text(isShare ? 'Visible height' : 'Visible Height (h3)');
          expect(tester.getTopLeft(find.text(label)).dy,
              greaterThan(tester.getBottomLeft(visible).dy));
          if (!isShare) {
            expect(
                tester.getBottomLeft(find.text(label)).dy,
                lessThan(tester
                    .getTopLeft(find.text('Apparent Visible Height (CD)'))
                    .dy));
          }
          expect(tester.takeException(), isNull);
        }
      });
    }
  }
}
