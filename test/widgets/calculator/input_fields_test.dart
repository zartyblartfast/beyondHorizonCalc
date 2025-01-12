import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:BeyondHorizonCalc/widgets/calculator/input_fields.dart';

void main() {
  group('InputFields', () {
    late TextEditingController observerHeightController;
    late TextEditingController distanceController;
    late TextEditingController refractionFactorController;
    late TextEditingController targetHeightController;

    setUp(() {
      observerHeightController = TextEditingController();
      distanceController = TextEditingController();
      refractionFactorController = TextEditingController();
      targetHeightController = TextEditingController();
    });

    tearDown(() {
      observerHeightController.dispose();
      distanceController.dispose();
      refractionFactorController.dispose();
      targetHeightController.dispose();
    });

    testWidgets('renders all input fields with correct labels', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: InputFields(
              observerHeightController: observerHeightController,
              distanceController: distanceController,
              refractionFactorController: refractionFactorController,
              targetHeightController: targetHeightController,
              isMetric: true,
              onMetricChanged: (_) {},
              onCalculate: () {},
            ),
          ),
        ),
      );

      // Verify all labels are present
      expect(find.text('Observer Height'), findsOneWidget);
      expect(find.text('Distance'), findsOneWidget);
      expect(find.text('Refraction Factor'), findsOneWidget);
      expect(find.text('Target Height (Optional)'), findsOneWidget);
      expect(find.text('Units:'), findsOneWidget);
      expect(find.text('Calculate'), findsOneWidget);
    });

    testWidgets('shows correct units based on isMetric', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: InputFields(
              observerHeightController: observerHeightController,
              distanceController: distanceController,
              refractionFactorController: refractionFactorController,
              targetHeightController: targetHeightController,
              isMetric: true,
              onMetricChanged: (_) {},
              onCalculate: () {},
            ),
          ),
        ),
      );

      // Verify metric units are shown
      expect(find.text('m'), findsNWidgets(2));  // Observer height and target height
      expect(find.text('km'), findsOneWidget);   // Distance
      
      // Rebuild with imperial units
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: InputFields(
              observerHeightController: observerHeightController,
              distanceController: distanceController,
              refractionFactorController: refractionFactorController,
              targetHeightController: targetHeightController,
              isMetric: false,
              onMetricChanged: (_) {},
              onCalculate: () {},
            ),
          ),
        ),
      );

      // Verify imperial units are shown
      expect(find.text('ft'), findsNWidgets(2));  // Observer height and target height
      expect(find.text('mi'), findsOneWidget);    // Distance
    });

    testWidgets('calls onMetricChanged when unit toggle is pressed', (WidgetTester tester) async {
      bool metricValue = true;
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: InputFields(
              observerHeightController: observerHeightController,
              distanceController: distanceController,
              refractionFactorController: refractionFactorController,
              targetHeightController: targetHeightController,
              isMetric: true,
              onMetricChanged: (value) => metricValue = value,
              onCalculate: () {},
            ),
          ),
        ),
      );

      // Tap the Imperial toggle button
      await tester.tap(find.text('Imperial'));
      await tester.pump();

      expect(metricValue, false);
    });

    testWidgets('calls onCalculate when calculate button is pressed', (WidgetTester tester) async {
      bool calculatePressed = false;
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: InputFields(
              observerHeightController: observerHeightController,
              distanceController: distanceController,
              refractionFactorController: refractionFactorController,
              targetHeightController: targetHeightController,
              isMetric: true,
              onMetricChanged: (_) {},
              onCalculate: () => calculatePressed = true,
            ),
          ),
        ),
      );

      await tester.tap(find.text('Calculate'));
      await tester.pump();

      expect(calculatePressed, true);
    });
  });
}
