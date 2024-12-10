import 'dart:math' as math;
import 'constants.dart';

/// Class containing earth curve calculation methods
class EarthCurveCalculator {
  /// Calculate the distance to the horizon given observer height
  static double calculateDistanceToHorizon(double observerHeight) {
    return math.sqrt(2 * AppConstants.earthRadius * observerHeight);
  }

  /// Calculate hidden height given total distance
  static double calculateHiddenHeight(double totalDistance) {
    return (totalDistance * totalDistance) / (2 * AppConstants.earthRadius);
  }

  /// Calculate geometric dip angle
  static double calculateGeometricDip(double observerHeight) {
    return math.acos(AppConstants.earthRadius / (AppConstants.earthRadius + observerHeight));
  }

  /// Convert kilometers to miles
  static double kmToMiles(double km) {
    return km * AppConstants.kmToMiles;
  }

  /// Convert meters to feet
  static double metersToFeet(double meters) {
    return meters * AppConstants.metersToFeet;
  }
}
