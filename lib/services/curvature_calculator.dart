import 'dart:math' as math;
import 'models/calculation_result.dart';

class CurvatureCalculator {
  static const double EARTH_RADIUS_METERS = 6371000;

  /// Calculates earth curvature effects based on input parameters
  /// 
  /// [observerHeight] Height of observer in meters (metric) or feet (imperial)
  /// [distance] Distance in kilometers (metric) or miles (imperial)
  /// [refractionFactor] Atmospheric refraction factor (typically 1.07)
  /// [targetHeight] Optional target height in meters (metric) or feet (imperial)
  /// [isMetric] Whether the input values are in metric units
  /// 
  /// Returns [CalculationResult] containing all calculated values in meters and kilometers
  static CalculationResult calculate({
    required double observerHeight,
    required double distance,
    required double refractionFactor,
    required bool isMetric,
    double? targetHeight,
  }) {
    final double effectiveRadius = EARTH_RADIUS_METERS * refractionFactor;

    // Convert all inputs to meters for calculation
    final double heightMeters = isMetric ? observerHeight : observerHeight * 0.3048;
    final double distanceMeters = isMetric ? distance * 1000 : distance * 1609.34;
    final double? targetHeightMeters = targetHeight == null 
        ? null 
        : (isMetric ? targetHeight : targetHeight * 0.3048);

    // Print intermediate values for debugging
    print('Input distance: $distance km');
    print('Distance in meters: $distanceMeters m');
    print('Effective radius: $effectiveRadius m');

    // Calculate using the same method as legacy JavaScript
    final double R = EARTH_RADIUS_METERS * refractionFactor;
    final double C = 2 * math.pi * R;  // Earth's circumference
    
    // Calculate d1 (distance to horizon)
    final double d1 = math.sqrt(2 * heightMeters * R);
    
    // Calculate l2
    final double l2 = distanceMeters - d1;
    
    // Calculate BOX angle
    final double BOX_fraction = l2 / C;
    final double BOX_angle = 2 * math.pi * BOX_fraction;
    
    // Calculate OC and hidden height (XC)
    final double OC = R / math.cos(BOX_angle);
    final double hiddenHeight = (OC - R) / 1000;  // Convert to kilometers
    
    // Calculate total distance (d0) and visible distance (d2)
    final double d2 = R * math.sin(BOX_angle);
    final double d0 = d1 + d2;
    
    // Calculate visible height of target if target height is provided
    double visibleTargetHeight = 0;
    double apparentVisibleHeight = 0;
    double perspectiveScaledHeight = 0;

    if (targetHeightMeters != null && targetHeightMeters > 0) {
      // Actual visible height is target height minus hidden height
      // Note: Convert hidden height back to meters for the subtraction
      visibleTargetHeight = targetHeightMeters - (hiddenHeight * 1000);
      visibleTargetHeight = visibleTargetHeight < 0 ? 0 : visibleTargetHeight;

      // Calculate apparent visible height
      if (visibleTargetHeight > 0) {
        // CD = CZ * cos(angle)
        final double angle = distanceMeters / effectiveRadius;
        apparentVisibleHeight = visibleTargetHeight * math.cos(angle);

        // Calculate perspective scaled height using pinhole camera model
        const double FOCAL_LENGTH = 1000.0; // 1km focal length
        perspectiveScaledHeight = FOCAL_LENGTH * apparentVisibleHeight / distanceMeters;
        perspectiveScaledHeight = perspectiveScaledHeight < 0 ? 0 : perspectiveScaledHeight;
      }
    }

    // Convert distances to km/mi
    final double distanceConversion = isMetric ? 0.001 : 0.000621371; // meters to km/mi

    return CalculationResult(
      horizonDistance: d1 * distanceConversion,
      hiddenHeight: hiddenHeight,  
      totalDistance: d0 * distanceConversion,
      visibleDistance: (d0 - d1) * distanceConversion,
      visibleTargetHeight: visibleTargetHeight / 1000,  
      apparentVisibleHeight: apparentVisibleHeight / 1000,
      perspectiveScaledHeight: perspectiveScaledHeight / 1000,
      inputDistance: distance,  // Original input distance
    );
  }
}
