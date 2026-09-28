import 'package:BeyondHorizonCalc/services/curvature_calculator.dart';
import 'package:BeyondHorizonCalc/services/models/calculation_result.dart';
import 'package:flutter_test/flutter_test.dart';

CalculationResult calculate(
        {double? top = 110,
        double distance = 50,
        bool metric = true,
        double surface = 100,
        double base = 105}) =>
    CurvatureCalculator.calculate(
      observerHeight: metric ? surface + 2 : (surface + 2) / 0.3048,
      interveningSurfaceElevation: metric ? surface : surface / 0.3048,
      distance: metric ? distance : distance * 1000 / 1609.34,
      refractionFactor: 1,
      isMetric: metric,
      targetHeight: top == null
          ? null
          : metric
              ? top
              : top / 0.3048,
      targetBaseElevation: metric ? base : base / 0.3048,
    );

void main() {
  test('boundary survives imperial round-trip across datums', () {
    for (final surface in [0.0, 100.0, 1800.0]) {
      for (final distance in [
        10.0,
        50.0,
        100.0,
        200.0,
        ...List.generate(100, (i) => 10 + i * 0.371)
      ]) {
        final cutoff =
            calculate(surface: surface, distance: distance).cutoffElevation! *
                1000;
        expect(
            calculate(
                    surface: surface,
                    distance: distance,
                    top: cutoff,
                    metric: false)
                .targetTopShortfall,
            0,
            reason: 'surface=$surface distance=$distance');
      }
    }
  });
  test('before horizon has zero shortfall when top supplied', () {
    expect(calculate(distance: 1).targetTopShortfall, 0);
    expect(calculate(distance: 1, top: null).targetTopShortfall, isNull);
  });
  test(
      'boundary, visible, missing and legacy results have no positive shortfall',
      () {
    final cutoff = calculate().cutoffElevation! * 1000;
    expect(calculate(top: cutoff).targetTopShortfall, 0);
    expect(calculate(top: cutoff + 10).targetTopShortfall, 0);
    expect(calculate(top: null).targetTopShortfall, isNull);
    expect(CalculationResult.fromMap({}).targetTopShortfall, isNull);
  });
  test('imperial and translated surface/base datums preserve shortfall', () {
    expect(calculate(metric: false).targetTopShortfall,
        closeTo(calculate().targetTopShortfall!, 1e-12));
    expect(calculate(surface: 0, base: 5, top: 10).targetTopShortfall,
        closeTo(calculate().targetTopShortfall!, 1e-12));
  });
  test('tiny positive shortfall is retained', () {
    final cutoff = calculate().cutoffElevation! * 1000;
    expect(calculate(top: cutoff - 0.001).targetTopShortfall,
        closeTo(0.000001, 1e-12));
  });
  test('hidden target shortfall uses top AMSL, not capped hidden span', () {
    final result = calculate();
    expect(result.hiddenHeight, 0.005);
    expect(result.visibleTargetHeight, 0);
    expect(result.toMap()['targetTopShortfall'],
        closeTo(result.cutoffElevation! - 0.110, 1e-12));
    final restored = CalculationResult.fromMap(result.toMap());
    expect(restored.toMap()['targetTopShortfall'],
        result.toMap()['targetTopShortfall']);
  });
}
