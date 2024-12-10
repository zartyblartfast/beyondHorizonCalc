import 'dart:math' as math;

/// Constants used throughout the application
class AppConstants {
  /// Earth's radius in kilometers
  static const double earthRadius = 6371.0;

  /// Conversion factor from kilometers to miles
  static const double kmToMiles = 0.621371;

  /// Conversion factor from meters to feet
  static const double metersToFeet = 3.28084;

  /// Calculates the geometric dip (angle of depression to the horizon) for an observer
  /// at a given height above sea level.
  /// 
  /// For an observer at height h above sea level, the geometric dip angle is:
  /// dip = arccos(R / (R + h)) where R is Earth's radius
  /// This can be approximated as: dip ≈ 0.0293 * sqrt(h) where h is in meters
  /// 
  /// @param heightMeters Observer's height above sea level in meters
  /// @return The geometric dip angle in degrees
  static double calculateGeometricDip(double heightMeters) {
    // Convert Earth's radius to meters for the calculation
    const double earthRadiusMeters = earthRadius * 1000;
    
    // Using the exact formula
    double dip = math.acos(earthRadiusMeters / (earthRadiusMeters + heightMeters));
    // Convert from radians to degrees
    return dip * (180 / math.pi);
    
    // Alternatively, using the approximation:
    // return 0.0293 * math.sqrt(heightMeters);
  }
}
