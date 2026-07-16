import 'package:BeyondHorizonCalc/widgets/calculator_form.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('CalculatorForm renders form fields', (tester) async {
    await tester.binding.setSurfaceSize(const Size(1400, 3000));
    addTearDown(() => tester.binding.setSurfaceSize(null));

    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(body: CalculatorForm()),
      ),
    );

    expect(find.byType(Form), findsOneWidget);
  });
}
