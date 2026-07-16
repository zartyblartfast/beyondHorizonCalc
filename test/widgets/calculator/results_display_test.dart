import 'package:BeyondHorizonCalc/services/models/calculation_result.dart';
import 'package:BeyondHorizonCalc/widgets/calculator/results_display.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('ResultsDisplay', () {
    const testResult = CalculationResult(
      horizonDistance: 10,
      hiddenHeight: 0.02,
      visibleTargetHeight: 0.05,
      apparentVisibleHeight: 0.045,
      perspectiveScaledHeight: 0.0015,
      dipAngle: 1.23,
    );

    testWidgets('shows nothing when result is null', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: ResultsDisplay(result: null, isMetric: true),
          ),
        ),
      );

      expect(find.byType(Card), findsNothing);
    });

    testWidgets('shows target portions in metric units', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: ResultsDisplay(
              result: testResult,
              isMetric: true,
              targetHeight: 70,
            ),
          ),
        ),
      );

      expect(find.text('10.00 km'), findsOneWidget);
      expect(find.text('20.0 m'), findsOneWidget);
      expect(find.text('50.0 m'), findsOneWidget);
      expect(find.text('45.0 m'), findsOneWidget);
      expect(find.text('1.5 m'), findsOneWidget);
      expect(find.text('1.23°'), findsOneWidget);
    });

    testWidgets('shows target portions in imperial units', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: ResultsDisplay(
              result: testResult,
              isMetric: false,
              targetHeight: 230,
            ),
          ),
        ),
      );

      expect(find.text('6.21 mi'), findsOneWidget);
      expect(find.text('65.6 ft'), findsOneWidget);
      expect(find.text('164.0 ft'), findsOneWidget);
      expect(find.text('147.6 ft'), findsOneWidget);
      expect(find.text('4.9 ft'), findsOneWidget);
    });

    testWidgets('shows N/A for null distance and hidden height',
        (tester) async {
      const nullResult = CalculationResult(
        horizonDistance: null,
        hiddenHeight: null,
        dipAngle: null,
      );

      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: ResultsDisplay(result: nullResult, isMetric: true),
          ),
        ),
      );

      expect(find.text('N/A'), findsNWidgets(2));
      expect(find.text('N/A°'), findsOneWidget);
    });
  });
}
