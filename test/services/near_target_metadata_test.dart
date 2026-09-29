import 'dart:math' as math;
import 'package:flutter_test/flutter_test.dart';
import 'package:BeyondHorizonCalc/services/curvature_calculator.dart';
import 'package:BeyondHorizonCalc/services/models/calculation_result.dart';

void main() {
  test('metadata covers every return path, imperial and unclamped endpoints',
      () {
    for (final distance in [10.0, 100.0]) {
      for (final top in [null, 120.0]) {
        final metric = CurvatureCalculator.calculate(
            observerHeight: 200,
            interveningSurfaceElevation: 100,
            targetBaseElevation: 100,
            targetHeight: top,
            distance: distance,
            refractionFactor: 1.2,
            isMetric: true);
        final imperial = CurvatureCalculator.calculate(
            observerHeight: 200 / .3048,
            interveningSurfaceElevation: 100 / .3048,
            targetBaseElevation: 100 / .3048,
            targetHeight: top == null ? null : top / .3048,
            distance: distance / 1.60934,
            refractionFactor: 1.2,
            isMetric: false);
        expect(imperial.observerAboveSurfaceKm,
            closeTo(metric.observerAboveSurfaceKm!, 1e-12));
        expect(imperial.targetBaseAboveSurfaceKm, closeTo(0, 1e-12));
        expect(imperial.tangentRadialHeightKm,
            closeTo(metric.tangentRadialHeightKm!, 1e-9));
        if (top == null) {
          expect(imperial.targetTopAboveSurfaceKm, isNull);
        } else {
          expect(imperial.targetTopAboveSurfaceKm,
              closeTo(metric.targetTopAboveSurfaceKm!, 1e-12));
        }
      }
    }
    final unsupported = CurvatureCalculator.calculate(
        observerHeight: 90,
        interveningSurfaceElevation: 100,
        targetHeight: 80,
        distance: 10,
        refractionFactor: 1,
        isMetric: true);
    expect(unsupported.observerAboveSurfaceKm, -.01);
    expect(unsupported.targetBaseAboveSurfaceKm, -.1);
    expect(unsupported.targetTopAboveSurfaceKm, -.02);
    expect(unsupported.h1, 0); // Legacy clamp remains untouched.
  });
  test(
      'near schematic metadata preserves datum and tangent radial intersection',
      () {
    final result = CurvatureCalculator.calculate(
        observerHeight: 200,
        interveningSurfaceElevation: 100,
        targetBaseElevation: 100,
        targetHeight: 120,
        distance: 10,
        refractionFactor: 1,
        isMetric: true);
    final map = result.toMap();
    expect(map['observerAboveSurfaceKm'], .1);
    expect(map['targetBaseAboveSurfaceKm'], 0);
    expect(map['targetTopAboveSurfaceKm'], .02);
    final beta = 10000 / 6371000 - math.acos(6371000 / 6371100);
    expect(map['tangentRadialHeightKm'],
        closeTo(6371000 * (1 / math.cos(beta) - 1) / 1000, 1e-9));
    final copy = CalculationResult.fromMap(map).toMap();
    for (final key in [
      'observerAboveSurfaceKm',
      'targetBaseAboveSurfaceKm',
      'targetTopAboveSurfaceKm',
      'tangentRadialHeightKm'
    ]) {
      expect(copy[key], map[key]);
      expect(CalculationResult.fromMap({}).toMap()[key], isNull);
    }
    // Neither the old zero cutoff nor legacy visibility is repurposed.
    expect(result.cutoffElevation, 0);
    expect(result.visibleTargetHeight, .02);
  });
}
