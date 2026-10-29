import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:BeyondHorizonCalc/widgets/calculator/comparison_dialog.dart';
import 'package:BeyondHorizonCalc/widgets/calculator/input_fields.dart';
import '../calculator_form_test.dart' show pumpCalculatorWithPresets;

void main() {
  testWidgets(
      'comparison beside Share snapshots current structure inputs without changing them',
      (tester) async {
    await pumpCalculatorWithPresets(tester);
    await tester.tap(find.text('Edit these values'));
    await tester.pump();
    await tester.pump();
    await tester.tap(find.text('Use base elevation + height instead'));
    await tester.pump();
    final fields = tester.widget<InputFields>(find.byType(InputFields));
    fields.observerHeightController.text = '110';
    fields.interveningSurfaceElevationController.text = '100';
    fields.distanceController.text = '30';
    fields.targetBaseElevationController.text = '100';
    fields.targetHeightController.text = '50';
    await tester.pump();
    expect(find.text('Share result'), findsOneWidget);
    await tester.tap(find.text('Compare scenarios'));
    await tester.pump();
    final dialog =
        tester.widget<ComparisonDialog>(find.byType(ComparisonDialog));
    expect(dialog.inputs.observerElevation, 110);
    expect(dialog.inputs.surfaceElevation, 100);
    expect(dialog.inputs.targetBase, 100);
    expect(dialog.inputs.targetTop, 150);
    expect(dialog.inputs.refractionFactor,
        double.parse(fields.refractionFactorController.text));
    await tester.enterText(
        find.byKey(const ValueKey('comparison_start')), '120');
    await tester.enterText(find.byKey(const ValueKey('comparison_end')), '150');
    await tester.tap(find.text('Generate table'));
    await tester.pump();
    await tester.tap(find.byTooltip('Close'));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 400));
    expect(fields.observerHeightController.text, '110');
    expect(fields.targetHeightController.text, '50');
    expect(fields.distanceController.text, '30');
    expect(find.byType(ComparisonDialog), findsNothing);
    expect(tester.takeException(), isNull);
  });
}
