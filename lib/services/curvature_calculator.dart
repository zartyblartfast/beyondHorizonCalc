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

    // Calculate geometric dip angle (can be calculated regardless of visibility)
    final double dipAngle = math.acos(R / (R + heightMeters)) * (180 / math.pi);

    // Check if the horizon extends beyond the object
    if (d1 >= distanceMeters) {
      // Object is fully visible
      double visibleTargetHeight = targetHeightMeters ?? 0; // Use full target height if available
      double apparentVisibleHeight = 0;
      double perspectiveScaledHeight = 0;

      if (visibleTargetHeight > 0) {
        // Calculate apparent visible height based on full target height
        final double angle = distanceMeters / effectiveRadius;
        apparentVisibleHeight = visibleTargetHeight * math.cos(angle);

        // Calculate perspective scaled height using pinhole camera model
        const double FOCAL_LENGTH = 1000.0; // 1km focal length
        perspectiveScaledHeight = FOCAL_LENGTH * apparentVisibleHeight / distanceMeters;
        perspectiveScaledHeight = perspectiveScaledHeight < 0 ? 0 : perspectiveScaledHeight;
      }

      return CalculationResult(
        horizonDistance: d1 / 1000,          // Horizon distance is still relevant
        hiddenHeight: 0,                     // No part is hidden
        totalDistance: distanceMeters / 1000, // Total distance is just the input distance
        visibleDistance: 0,                  // d2 is not applicable here, maybe set to 0 or distanceMeters? Let's use 0 for now.
        visibleTargetHeight: visibleTargetHeight / 1000,
        apparentVisibleHeight: apparentVisibleHeight / 1000,
        perspectiveScaledHeight: perspectiveScaledHeight / 1000,
        inputDistance: distance,             // Store original input
        h1: observerHeight,                  // Store original input
        dipAngle: dipAngle,                  // Add dip angle
      );

    } else {
      // Object is partially or fully hidden beyond the horizon, proceed with original calculations
      
      // Calculate l2
      final double l2 = distanceMeters - d1;
      
      // Calculate BOX angle
      final double BOX_fraction = l2 / C;
      final double BOX_angle = 2 * math.pi * BOX_fraction;
      
      // Calculate OC and hidden height (XC)
      final double OC = R / math.cos(BOX_angle);
      final double hiddenHeight = (OC - R) / 1000;  // Convert to kilometers
      
      // Calculate total distance (d0) and visible distance (d2)
      final double d2 = R * math.sin(BOX_angle); // Note: d2 here is distance from horizon point along curve
      final double d0 = d1 + d2; // This might need re-evaluation. Is d0 always observer-to-target-tangent? Let's keep for now.


      // If no target height, return basic calculations
      if (targetHeightMeters == null) {
        return CalculationResult(
          horizonDistance: d1 / 1000,  // Convert to km
          hiddenHeight: hiddenHeight,
          totalDistance: d0 / 1000,    // Convert to km - Check if this definition is correct
          visibleDistance: d2 / 1000,  // Convert to km
          inputDistance: distance,     // Store original input
          h1: observerHeight,          // Store original input
          dipAngle: dipAngle,          // Add dip angle
        );
      }

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
          // CD = CZ * cos(angle) - Angle should probably be BOX_angle or related?
          // Let's stick with the original angle calc for now, but this might need review.
          final double angle = distanceMeters / effectiveRadius; // Original calculation used total distance
          apparentVisibleHeight = visibleTargetHeight * math.cos(angle);

          // Calculate perspective scaled height using pinhole camera model
          const double FOCAL_LENGTH = 1000.0; // 1km focal length
          perspectiveScaledHeight = FOCAL_LENGTH * apparentVisibleHeight / distanceMeters;
          perspectiveScaledHeight = perspectiveScaledHeight < 0 ? 0 : perspectiveScaledHeight;
        }
      }
      
      return CalculationResult(
        horizonDistance: d1 / 1000,  // Convert to km
        hiddenHeight: hiddenHeight,
        totalDistance: d0 / 1000,  // Convert to km - Check definition
        visibleDistance: d2 / 1000,  // Convert to km
        visibleTargetHeight: visibleTargetHeight / 1000,  
        apparentVisibleHeight: apparentVisibleHeight / 1000,
        perspectiveScaledHeight: perspectiveScaledHeight / 1000,
        inputDistance: distance,     // Original input distance
        h1: observerHeight,          // Store original input value
        dipAngle: dipAngle,          // Add dip angle
      );
    }
  }
}
