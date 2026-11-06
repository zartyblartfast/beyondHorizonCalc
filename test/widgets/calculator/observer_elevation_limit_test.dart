import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:BeyondHorizonCalc/services/scenario_comparison.dart';
import 'package:BeyondHorizonCalc/widgets/calculator/input_fields.dart';
import '../calculator_form_test.dart' show pumpCalculatorWithPresets;

void main() {
  for (final metric in [true, false]) {
    final scale = metric ? 1.0 : 3.28084;
    testWidgets('main observer upper boundary metric=$metric', (tester) async {
      await pumpCalculatorWithPresets(tester);
      await tester.tap(find.text('Edit these values'));
      await tester.pump();
      var fields = tester.widget<InputFields>(find.byType(InputFields));
      if (fields.isMetric != metric) {
        fields.onMetricChanged(metric);
        await tester.pump();
        fields = tester.widget<InputFields>(find.byType(InputFields));
      }
      final field = tester.widgetList<TextFormField>(find.byType(TextFormField))
          .firstWhere((f) => identical(f.controller, fields.observerHeightController));
      expect(field.validator!('${1000000 * scale}'), isNull);
      expect(field.validator!('${1000001 * scale}'), isNotNull);
    });
    testWidgets('main distance upper boundary metric=$metric', (tester) async {
      await pumpCalculatorWithPresets(tester);
      await tester.tap(find.text('Edit these values'));
      await tester.pump();
      var fields = tester.widget<InputFields>(find.byType(InputFields));
      if (fields.isMetric != metric) {
        fields.onMetricChanged(metric);
        await tester.pump();
        fields = tester.widget<InputFields>(find.byType(InputFields));
      }
      final field = tester.widgetList<TextFormField>(find.byType(TextFormField))
          .firstWhere((f) => identical(f.controller, fields.distanceController));
      final distanceScale = metric ? 1.0 : 0.621371;
      expect(field.validator!('${4000 * distanceScale}'), isNull);
      expect(field.validator!('${4001 * distanceScale}'), isNotNull);
    });
    test('comparison distance upper boundary metric=$metric', () {
      final distanceScale = metric ? 1.0 : 0.621371;
      ScenarioComparison generate(double distance) => ScenarioComparison.generate(
        inputs: ComparisonInputs(observerElevation: 1000000 * scale,
          surfaceElevation: 0, distance: distance * distanceScale,
          refractionFactor: 1, isMetric: metric, targetTop: 9000 * scale),
        variable: ComparisonVariable.distance,
        start: 3999 * distanceScale, end: distance * distanceScale,
        increment: distanceScale);
      expect(generate(4000).rows.length, 2);
      expect(() => generate(4001), throwsFormatException);
    });
    test('comparison observer upper boundary metric=$metric', () {
      ScenarioComparison generate(double eye, {double target = 9000}) =>
          ScenarioComparison.generate(
            inputs: ComparisonInputs(observerElevation: eye * scale,
              surfaceElevation: 0, distance: 100, refractionFactor: 1,
              isMetric: metric, targetTop: target * scale),
            variable: ComparisonVariable.elevation,
            start: 999999 * scale, end: eye * scale, increment: scale);
      final table = generate(1000000);
      expect(table.rows.length, 2);
      expect(table.rows.last.value, 1000000 * scale);
      expect(() => generate(1000001), throwsFormatException);
      expect(() => generate(1000000, target: 9001), throwsFormatException);
    });
  }
}
