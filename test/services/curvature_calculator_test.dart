import 'package:flutter_test/flutter_test.dart';
import 'package:BeyondHorizonCalc/services/curvature_calculator.dart';
import 'package:BeyondHorizonCalc/services/models/calculation_result.dart';
import 'dart:math' as math;

void main() {
  group('CurvatureCalculator', () {
    // Test constants
    const double delta = 0.001; // Acceptable difference for double comparison

    test('calculates horizon distance correctly', () {
      // Given: observer at 2 meters height with standard refraction
      const double observerHeight = 2.0; // meters
      const double distance = 10.0; // kilometers
      const double refractionFactor = 1.07;

      // When: calculating curvature
      final result = CurvatureCalculator.calculate(
        observerHeight: observerHeight,
        distance: distance,
        refractionFactor: refractionFactor,
        isMetric: true,
      );

      // Then: horizon distance should match expected value
      // Expected horizon distance = sqrt(2 * h * R * k)
      // where h is height, R is earth radius, k is refraction factor
      final expectedHorizonDistance = math.sqrt(2 *
              observerHeight *
              CurvatureCalculator.EARTH_RADIUS_METERS *
              refractionFactor) /
          1000; // Convert to km

      expect(result.horizonDistance, closeTo(expectedHorizonDistance, delta));
    });

    test('calculates hidden height correctly with target', () {
      // Given: observer and target with known parameters
      const double observerHeight = 2.0; // meters
      const double distance = 10.0; // kilometers
      const double refractionFactor = 1.07;
      const double targetHeight = 10.0; // meters

      // When: calculating curvature
      final result = CurvatureCalculator.calculate(
        observerHeight: observerHeight,
        distance: distance,
        refractionFactor: refractionFactor,
        isMetric: true,
        targetHeight: targetHeight,
      );

      // Then: hidden height should be positive and less than target height
      expect(result.hiddenHeight, greaterThan(0));
      expect(result.hiddenHeight, lessThan(targetHeight));
    });

    test('returns finite curvature values at maximum supported distance', () {
      // Given: the maximum distance accepted by the UI
      const double observerHeight = 2.0; // meters
      const double distance = 600.0; // kilometers
      const double refractionFactor = 1.07;

      // When: calculating curvature
      final result = CurvatureCalculator.calculate(
        observerHeight: observerHeight,
        distance: distance,
        refractionFactor: refractionFactor,
        isMetric: true,
      );

      // Then: the calculation remains finite and reports a hidden height
      expect(result.horizonDistance, isNotNull);
      expect(result.horizonDistance!.isFinite, isTrue);
      expect(result.hiddenHeight, isNotNull);
      expect(result.hiddenHeight!.isFinite, isTrue);
      expect(result.hiddenHeight, greaterThan(0));
    });

    test('calculates visible target height correctly', () {
      // Given: realistic observation scenario
      const double observerHeight = 2.0; // meters
      const double distance =
          10.0; // kilometers (increased to be beyond horizon)
      const double refractionFactor = 1.07;
      const double targetHeight = 100.0; // meters

      // When: calculating curvature
      final result = CurvatureCalculator.calculate(
        observerHeight: observerHeight,
        distance: distance,
        refractionFactor: refractionFactor,
        isMetric: true,
        targetHeight: targetHeight,
      );

      // Then: visible height should be less than total target height
      expect(result.visibleTargetHeight, isNotNull);
      expect(result.apparentVisibleHeight, isNotNull);
      expect(
          result.apparentVisibleHeight! <= result.visibleTargetHeight!, isTrue);
    });

    test('handles null target height gracefully', () {
      // Given: no target height specified
      const double observerHeight = 2.0; // meters
      const double distance = 5.0; // kilometers
      const double refractionFactor = 1.07;

      // When: calculating curvature
      final result = CurvatureCalculator.calculate(
        observerHeight: observerHeight,
        distance: distance,
        refractionFactor: refractionFactor,
        isMetric: true,
      );

      // Then: target-related values should be zero
      expect(result.visibleTargetHeight, equals(0));
      expect(result.apparentVisibleHeight, equals(0));
    });

    test('uses input distance when target is before the horizon', () {
      // Given: a target closer than the observer's horizon
      const double observerHeight = 2.0; // meters
      const double distance = 5.0; // kilometers
      const double refractionFactor = 1.07;

      // When: calculating curvature
      final result = CurvatureCalculator.calculate(
        observerHeight: observerHeight,
        distance: distance,
        refractionFactor: refractionFactor,
        isMetric: true,
      );

      // Then: total distance is the input and no beyond-horizon segment applies
      expect(result.totalDistance, closeTo(distance, delta));
      expect(result.visibleDistance, equals(0));
      expect(result.hiddenHeight, equals(0));
    });
  });
}
