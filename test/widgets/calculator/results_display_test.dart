import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:BeyondHorizonCalc/widgets/calculator/results_display.dart';
import 'package:BeyondHorizonCalc/services/models/calculation_result.dart';

void main() {
  group('ResultsDisplay', () {
    final testResult = CalculationResult(
      horizonDistance: 10.0,
      hiddenHeight: 20.0,
      totalDistance: 30.0,
      visibleDistance: 40.0,
      visibleTargetHeight: 50.0,
      apparentVisibleHeight: 45.0,
    );

    testWidgets('shows nothing when result is null', (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: ResultsDisplay(
              result: null,
              isMetric: true,
            ),
          ),
        ),
      );

      expect(find.byType(Card), findsNothing);
    });

    testWidgets('shows all results in metric units', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: ResultsDisplay(
              result: testResult,
              isMetric: true,
            ),
          ),
        ),
      );

      expect(find.text('10.00 km'), findsOneWidget);  // Horizon Distance
      expect(find.text('30.00 km'), findsOneWidget);  // Total Distance
      expect(find.text('20.00 m'), findsOneWidget);   // Hidden Height
      expect(find.text('50.00 m'), findsOneWidget);   // Visible Target Height
      expect(find.text('45.00 m'), findsOneWidget);   // Apparent Visible Height
    });

    testWidgets('shows all results in imperial units', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: ResultsDisplay(
              result: testResult,
              isMetric: false,
            ),
          ),
        ),
      );

      expect(find.text('6.21 mi'), findsOneWidget);    // Horizon Distance
      expect(find.text('18.64 mi'), findsOneWidget);   // Total Distance
      expect(find.text('65.62 ft'), findsOneWidget);   // Hidden Height
      expect(find.text('164.04 ft'), findsOneWidget);  // Visible Target Height
      expect(find.text('147.64 ft'), findsOneWidget);  // Apparent Visible Height
    });

    testWidgets('shows N/A for null values', (WidgetTester tester) async {
      final nullResult = CalculationResult(
        horizonDistance: null,
        hiddenHeight: null,
        totalDistance: null,
        visibleDistance: null,
        visibleTargetHeight: null,
        apparentVisibleHeight: null,
      );

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: ResultsDisplay(
              result: nullResult,
              isMetric: true,
            ),
          ),
        ),
      );

      // Verify all result fields show N/A
      expect(find.text('N/A'), findsNWidgets(3)); // Only visible fields when no target height
    });
  });
}
