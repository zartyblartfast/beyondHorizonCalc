import 'dart:math' as math;
import 'package:BeyondHorizonCalc/services/curvature_calculator.dart';
import 'package:BeyondHorizonCalc/services/models/calculation_result.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('tangent geometry is top-invariant and unit/datum equivalent', () {
    for (final distance in [0.0, 10.0, 100.0]) {
      final reference = CurvatureCalculator.calculate(
          observerHeight: 100,
          distance: distance,
          refractionFactor: 1.07,
          isMetric: true);
      for (final metric in [true, false]) {
        for (final top in [20.0, 300.0]) {
          final result = CurvatureCalculator.calculate(
              observerHeight: metric ? 600 : 600 / 0.3048,
              interveningSurfaceElevation: metric ? 500 : 500 / 0.3048,
              targetHeight: metric ? 500 + top : (500 + top) / 0.3048,
              distance: metric ? distance : distance * 1000 / 1609.34,
              refractionFactor: 1.07,
              isMetric: metric);
          expect(result.horizonPosition, reference.horizonPosition);
          expect(result.horizonLineDistance,
              closeTo(reference.horizonLineDistance!, 1e-6));
          expect(result.observerToHorizonDistance,
              closeTo(reference.observerToHorizonDistance!, 1e-6));
          expect(result.horizonToTargetRadialDistance,
              closeTo(reference.horizonToTargetRadialDistance!, 1e-6));
          const r = CurvatureCalculator.EARTH_RADIUS_METERS * 1.07;
          final theta = distance * 1000 / r;
          final x = (r + top) * math.sin(theta);
          final y = (r + top) * math.cos(theta) - (r + 100);
          expect(result.observerToTargetTopDistance,
              closeTo(math.sqrt(x * x + y * y) / 1000, 1e-6));
        }
      }
    }
  });
  test('observer on surface has A=B; zero arc gives A=C', () {
    for (final h in [0.0, 100.0]) {
      for (final distance in [0.0, 1.0]) {
        final result = CurvatureCalculator.calculate(
            observerHeight: h,
            distance: distance,
            refractionFactor: 1,
            isMetric: true);
        if (h == 0) {
          expect(result.observerToHorizonDistance, 0);
          expect(
              result.horizonLineDistance, result.horizonToTargetRadialDistance);
          expect(result.horizonPosition,
              distance == 0 ? HorizonPosition.at : HorizonPosition.beyond);
        }
        if (distance == 0)
          expect(result.horizonLineDistance, closeTo(0, 1e-12));
        expect(result.observerToTargetTopDistance, isNull);
      }
    }
  });
  test('map roundtrip retains classification and legacy maps stay unavailable',
      () {
    final result = CurvatureCalculator.calculate(
        observerHeight: 100,
        distance: 10,
        refractionFactor: 1,
        isMetric: true,
        targetHeight: 20);
    expect(CalculationResult.fromMap(result.toMap()).toMap(), result.toMap());
    final legacy = CalculationResult.fromMap({'totalDistance': 12.0});
    expect(legacy.horizonPosition, isNull);
    expect(legacy.horizonLineDistance, isNull);
    expect(legacy.observerToTargetTopDistance, isNull);
    expect(legacy.totalDistance, 12);
  });
  test('classification normalizes only metre-based roundoff at C=B', () {
    const r = CurvatureCalculator.EARTH_RADIUS_METERS;
    final horizon = r * math.acos(r / (r + 100));
    for (final offset in [-1.0, -0.0000005, 0.0, 0.0000005, 1.0]) {
      final result = CurvatureCalculator.calculate(
        observerHeight: 100,
        distance: (horizon + offset) / 1000,
        refractionFactor: 1,
        isMetric: true,
      );
      expect(
          result.toMap()['horizonPosition'],
          offset < -1e-6
              ? 'before'
              : offset > 1e-6
                  ? 'beyond'
                  : 'at');
      if (offset.abs() < 1e-6) {
        expect(result.horizonToTargetRadialDistance, 0);
        expect(result.horizonLineDistance, result.observerToHorizonDistance);
      }
      expect(result.surfaceDistance, (horizon + offset) / 1000);
    }
  });
  test('canonical tangent distances follow A-C-B, C=B and A-B-C', () {
    const radius = CurvatureCalculator.EARTH_RADIUS_METERS * 1.07;
    const height = 100.0;
    final alpha = math.acos(radius / (radius + height));
    final horizon = radius * alpha;
    final ab = radius * math.tan(alpha) / 1000;
    for (final offset in [-1000.0, 0.0, 1000.0]) {
      for (final top in <double?>[null, 50.0, 200.0]) {
        final s = horizon + offset;
        final signedBc = radius * math.tan(s / radius - alpha) / 1000;
        final result = CurvatureCalculator.calculate(
          observerHeight: height,
          distance: s / 1000,
          refractionFactor: 1.07,
          isMetric: true,
          targetHeight: top,
        );
        expect(result.surfaceDistance, s / 1000);
        expect(result.observerToHorizonDistance, closeTo(ab, 1e-6));
        expect(result.horizonToTargetRadialDistance,
            closeTo(signedBc.abs(), 1e-6));
        expect(result.horizonLineDistance, closeTo(ab + signedBc, 1e-6));
        expect(result.observerToTargetTopDistance, result.totalDistance);
        if (offset <= 0) expect(result.visibleDistance, 0);
      }
    }
  });
}
