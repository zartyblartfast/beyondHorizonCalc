import 'dart:math' as math;

import 'package:BeyondHorizonCalc/services/curvature_calculator.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('reports D0 as direct observer-to-target-top distance above the horizon surface', () {
    const observerElevation = 16.5;
    const surfaceElevation = 0.0;
    const surfaceDistanceKm = 51.4;
    const refraction = 1.10;
    const targetTopElevation = 183.0;
    final radius = CurvatureCalculator.EARTH_RADIUS_METERS * refraction;
    final angle = surfaceDistanceKm * 1000 / radius;
    final expectedTopDistance = math.sqrt(
          math.pow(radius + observerElevation - surfaceElevation, 2) +
              math.pow(radius + targetTopElevation - surfaceElevation, 2) -
              2 *
                  (radius + observerElevation - surfaceElevation) *
                  (radius + targetTopElevation - surfaceElevation) *
                  math.cos(angle),
        ) /
        1000;

    final result = CurvatureCalculator.calculate(
      observerHeight: observerElevation,
      interveningSurfaceElevation: surfaceElevation,
      distance: surfaceDistanceKm,
      refractionFactor: refraction,
      targetHeight: targetTopElevation,
      isMetric: true,
    );

    expect(result.totalDistance, closeTo(expectedTopDistance, 0.0000001));
  });
}
