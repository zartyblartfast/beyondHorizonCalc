import 'package:BeyondHorizonCalc/services/models/calculation_result.dart';
import 'package:BeyondHorizonCalc/widgets/calculator/diagram/horizon_diagram_view_model.dart';
import 'package:BeyondHorizonCalc/widgets/calculator/diagram_display.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('classifies a fully hidden target from the visible portion', () {
    final viewModel = HorizonDiagramViewModel(
      result: const CalculationResult(
        hiddenHeight: 0.1,
        visibleTargetHeight: 0,
      ),
      targetHeight: 100,
      isMetric: true,
    );

    expect(viewModel.getVisibilityState(), 'Hidden');
  });

  test('classifies a fully visible target', () {
    final viewModel = HorizonDiagramViewModel(
      result: const CalculationResult(
        hiddenHeight: 0,
        visibleTargetHeight: 0.1,
      ),
      targetHeight: 100,
      isMetric: true,
    );

    expect(viewModel.getVisibilityState(), 'Visible');
  });

  testWidgets('does not show mountain geometry for structure targets',
      (tester) async {
    tester.view.physicalSize = const Size(1400, 2500);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(
          body: DiagramDisplay(
            result: CalculationResult(),
            targetHeight: 100,
            isMetric: true,
            isStructureTarget: true,
          ),
        ),
      ),
    );

    expect(
      find.textContaining('mountain diagrams are available in elevation mode'),
      findsOneWidget,
    );

    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(
          body: DiagramDisplay(
            result: CalculationResult(),
            targetHeight: 100,
            isMetric: true,
          ),
        ),
      ),
    );
    expect(tester.takeException(), isNull);
  });
}
