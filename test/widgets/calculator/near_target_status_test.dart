import 'package:flutter_svg/flutter_svg.dart';
import 'package:BeyondHorizonCalc/widgets/calculator/diagram_display.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:BeyondHorizonCalc/models/line_of_sight_preset.dart';
import 'package:BeyondHorizonCalc/services/curvature_calculator.dart';
import 'package:BeyondHorizonCalc/services/models/calculation_result.dart';
import 'package:BeyondHorizonCalc/widgets/calculator/results_display.dart';
import 'package:BeyondHorizonCalc/widgets/calculator/share_result_dialog.dart';

Future<void> display(WidgetTester tester, CalculationResult result, double? top,
    bool share) async {
  rootBundle.clear();
  await tester.pumpWidget(MaterialApp(
      home: Scaffold(
          body: SingleChildScrollView(
              child: share
                  ? ShareResultDialog(
                      scenarioName: 'Near',
                      observerHeight: '100',
                      surfaceElevation: '0',
                      distance: '10',
                      refractionFactor: '1',
                      targetHeight: top?.toString() ?? '',
                      targetBaseElevation: '0',
                      targetInputType: TargetInputType.elevation,
                      result: result,
                      isMetric: true)
                  : ResultsDisplay(
                      result: result, targetHeight: top, isMetric: true)))));
  await tester.runAsync(() async {
    await Future<void>.delayed(const Duration(milliseconds: 150));
  });
  await tester.pump();
}

void main() {
  testWidgets('zero physical span has no percentage claim', (tester) async {
    final result = CurvatureCalculator.calculate(
        observerHeight: 100,
        distance: 10,
        targetHeight: 0,
        refractionFactor: 1,
        isMetric: true);
    for (final share in [false, true]) {
      await display(tester, result, 0, share);
      expect(find.textContaining('No positive target span'), findsOneWidget);
      expect(find.textContaining('100%'), findsNothing);
    }
  });
  testWidgets(
      'below-surface endpoints explicitly withhold visibility and schematic',
      (tester) async {
    for (final base in [0.0, 100.0]) {
      final result = CurvatureCalculator.calculate(
          observerHeight: 200,
          interveningSurfaceElevation: 100,
          targetBaseElevation: base,
          targetHeight: 90,
          distance: 10,
          refractionFactor: 1,
          isMetric: true);
      for (final share in [false, true]) {
        await display(tester, result, 90, share);
        expect(find.textContaining('below the horizon-forming surface'),
            findsWidgets);
        expect(find.textContaining('100%'), findsNothing);
        if (share) expect(find.byType(SvgPicture), findsNothing);
      }
      await tester.pumpWidget(MaterialApp(
          home: DiagramDisplay(
              result: result, targetHeight: 90, isMetric: true)));
      expect(find.textContaining('below the horizon-forming surface'),
          findsOneWidget);
      expect(find.byType(SvgPicture), findsNothing);
    }
  });
  testWidgets('no top has no percentage in main and share', (tester) async {
    final result = CurvatureCalculator.calculate(
        observerHeight: 100, distance: 10, refractionFactor: 1, isMetric: true);
    for (final share in [false, true]) {
      await display(tester, result, null, share);
      expect(find.textContaining('No target top supplied'), findsOneWidget);
      expect(find.textContaining('100%'), findsNothing);
    }
  });
  testWidgets(
      'supported near target below C is 100 percent curvature-only in main and share',
      (tester) async {
    final result = CurvatureCalculator.calculate(
        observerHeight: 100,
        distance: 10,
        targetHeight: 20,
        refractionFactor: 1,
        isMetric: true);
    for (final share in [false, true]) {
      await display(tester, result, 20, share);
      expect(
          find.textContaining('Target is before the observer'), findsOneWidget);
      expect(
          find.textContaining('100% visible (curvature only)'), findsOneWidget);
      expect(find.textContaining('Hidden height'), findsNothing);
      expect(find.textContaining('CZ'), findsNothing);
      expect(tester.takeException(), isNull);
    }
  });
}
