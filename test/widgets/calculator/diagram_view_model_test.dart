import 'package:BeyondHorizonCalc/services/models/calculation_result.dart';
import 'package:BeyondHorizonCalc/widgets/calculator/diagram/horizon_diagram_view_model.dart';
import 'package:BeyondHorizonCalc/widgets/calculator/diagram_display.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('D0 labels canonical AC, never legacy AZ', () {
    final model = HorizonDiagramViewModel(
      result: const CalculationResult(horizonLineDistance: 42,
          observerToHorizonDistance: 12, horizonToTargetRadialDistance: 30,
          surfaceDistance: 41, totalDistance: 43),
      isMetric: true);
    final labels = model.getLabelValues();
    expect(labels['LoS_Distance_d0'], '42.0 km');
    expect(labels['d1'], '12.0 km');
    expect(labels['d2'], '30.0 km');
    expect(labels['L0'], '41.0 km');
    expect(HorizonDiagramViewModel(result: const CalculationResult(totalDistance: 43),
        isMetric: true).getLabelValues()['LoS_Distance_d0'], 'N/A');
  });
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
