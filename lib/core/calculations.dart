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
  /// 
  /// For an observer at height h above sea level, the geometric dip angle is:
  /// dip = arccos(R / (R + h)) where R is Earth's radius
  /// This can be approximated as: dip ≈ 0.0293 * sqrt(h) where h is in meters
  /// 
  /// @param heightMeters Observer's height above sea level in meters
  /// @return The geometric dip angle in degrees
  static double calculateGeometricDip(double heightMeters) {
    // Convert Earth's radius to meters for the calculation
    const double earthRadiusMeters = AppConstants.earthRadius * 1000;
    
    // Using the exact formula
    double dip = math.acos(earthRadiusMeters / (earthRadiusMeters + heightMeters));
    // Convert from radians to degrees
    return dip * (180 / math.pi);
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
