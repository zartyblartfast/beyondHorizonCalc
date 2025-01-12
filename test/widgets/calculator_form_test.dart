import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:BeyondHorizonCalc/widgets/calculator_form.dart';

void main() {
  group('CalculatorForm', () {
    testWidgets('renders form fields', (WidgetTester tester) async {
      // Build our app and trigger a frame.
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: CalculatorForm(),
          ),
        ),
      );

      // Verify form fields exist
      expect(find.byType(Form), findsOneWidget);
      // More specific tests will be added as we refactor
    });
  });
}
