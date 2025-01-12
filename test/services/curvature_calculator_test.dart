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
      const double observerHeight = 2.0;  // meters
      const double distance = 10.0;       // kilometers
      const double refractionFactor = 1.07;
      
      // When: calculating curvature
      final result = CurvatureCalculator.calculate(
        observerHeight: observerHeight,
        distance: distance,
        refractionFactor: refractionFactor,
      );
      
      // Then: horizon distance should match expected value
      // Expected horizon distance = sqrt(2 * h * R * k)
      // where h is height, R is earth radius, k is refraction factor
      final expectedHorizonDistance = math.sqrt(
        2 * observerHeight * CurvatureCalculator.EARTH_RADIUS_METERS * refractionFactor
      ) / 1000; // Convert to km
      
      expect(result.horizonDistance, closeTo(expectedHorizonDistance, delta));
    });

    test('calculates hidden height correctly with target', () {
      // Given: observer and target with known parameters
      const double observerHeight = 2.0;    // meters
      const double distance = 10.0;         // kilometers
      const double refractionFactor = 1.07;
      const double targetHeight = 10.0;     // meters
      
      // When: calculating curvature
      final result = CurvatureCalculator.calculate(
        observerHeight: observerHeight,
        distance: distance,
        refractionFactor: refractionFactor,
        targetHeight: targetHeight,
      );
      
      // Then: hidden height should be positive and less than target height
      expect(result.hiddenHeight, greaterThan(0));
      expect(result.hiddenHeight, lessThan(targetHeight));
    });

    test('handles error case when angle exceeds 90 degrees', () {
      // Given: extreme distance causing angle > 90 degrees
      const double observerHeight = 2.0;     // meters
      const double distance = 20000.0;       // kilometers
      const double refractionFactor = 1.07;
      
      // When: calculating curvature
      final result = CurvatureCalculator.calculate(
        observerHeight: observerHeight,
        distance: distance,
        refractionFactor: refractionFactor,
      );
      
      // Then: should return zero values
      expect(result.horizonDistance, equals(0));
      expect(result.hiddenHeight, equals(0));
      expect(result.totalDistance, equals(0));
      expect(result.visibleDistance, equals(0));
    });

    test('calculates visible target height correctly', () {
      // Given: realistic observation scenario
      const double observerHeight = 2.0;     // meters
      const double distance = 10.0;          // kilometers (increased to be beyond horizon)
      const double refractionFactor = 1.07;
      const double targetHeight = 100.0;     // meters
      
      // When: calculating curvature
      final result = CurvatureCalculator.calculate(
        observerHeight: observerHeight,
        distance: distance,
        refractionFactor: refractionFactor,
        targetHeight: targetHeight,
      );
      
      // Then: visible height should be less than total target height
      expect(result.visibleTargetHeight, isNotNull);
      expect(result.apparentVisibleHeight, isNotNull);
      expect(result.apparentVisibleHeight! <= result.visibleTargetHeight!, isTrue);
    });

    test('handles null target height gracefully', () {
      // Given: no target height specified
      const double observerHeight = 2.0;     // meters
      const double distance = 5.0;           // kilometers
      const double refractionFactor = 1.07;
      
      // When: calculating curvature
      final result = CurvatureCalculator.calculate(
        observerHeight: observerHeight,
        distance: distance,
        refractionFactor: refractionFactor,
      );
      
      // Then: target-related values should be zero
      expect(result.visibleTargetHeight, equals(0));
      expect(result.apparentVisibleHeight, equals(0));
    });

    test('total distance is sum of horizon distance and beyond', () {
      // Given: standard observation parameters
      const double observerHeight = 2.0;     // meters
      const double distance = 5.0;           // kilometers
      const double refractionFactor = 1.07;
      
      // When: calculating curvature
      final result = CurvatureCalculator.calculate(
        observerHeight: observerHeight,
        distance: distance,
        refractionFactor: refractionFactor,
      );
      
      // Then: total distance should be greater than horizon distance
      expect(result.totalDistance, isNotNull);
      expect(result.horizonDistance, isNotNull);
      expect(result.totalDistance! >= result.horizonDistance!, isTrue);
    });
  });
}
