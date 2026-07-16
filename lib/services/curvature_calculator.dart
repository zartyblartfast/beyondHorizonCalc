import 'dart:math' as math;
import 'models/calculation_result.dart';

class CurvatureCalculator {
  static const double EARTH_RADIUS_METERS = 6371000;

  /// Calculates earth curvature effects based on input parameters
  ///
  /// [observerHeight] Height of observer in meters (metric) or feet (imperial)
  /// [distance] Distance in kilometers (metric) or miles (imperial)
  /// [refractionFactor] Atmospheric refraction factor (typically 1.07)
  /// [targetHeight] Optional target top elevation in meters (metric) or feet (imperial)
  /// [targetBaseElevation] Optional target base elevation in the same height units
  /// [isMetric] Whether the input values are in metric units
  ///
  /// Returns [CalculationResult] containing all calculated values in meters and kilometers
  static CalculationResult calculate({
    required double observerHeight,
    required double distance,
    required double refractionFactor,
    required bool isMetric,
    double? targetHeight,
    double targetBaseElevation = 0,
  }) {
    final double effectiveRadius = EARTH_RADIUS_METERS * refractionFactor;
    final double heightMeters =
        isMetric ? observerHeight : observerHeight * 0.3048;
    final double distanceMeters =
        isMetric ? distance * 1000 : distance * 1609.34;
    final double? targetHeightMeters = targetHeight == null
        ? null
        : (isMetric ? targetHeight : targetHeight * 0.3048);
    final double targetBaseElevationMeters =
        isMetric ? targetBaseElevation : targetBaseElevation * 0.3048;

    final double R = effectiveRadius;
    final double C = 2 * math.pi * R; // Earth's circumference
    final double d1 = math.sqrt(2 * heightMeters * R);
    final double dipAngle = math.acos(R / (R + heightMeters)) * (180 / math.pi);

    if (d1 >= distanceMeters) {
      // Object is fully visible
      double visibleTargetHeight = targetHeightMeters == null
          ? 0
          : math.max(
              targetHeightMeters - targetBaseElevationMeters,
              0,
            );
      double apparentVisibleHeight = 0;
      double perspectiveScaledHeight = 0;

      if (visibleTargetHeight > 0) {
        // Calculate apparent visible height based on full target height
        final double angle = distanceMeters / effectiveRadius;
        apparentVisibleHeight = visibleTargetHeight * math.cos(angle);

        // Calculate perspective scaled height using pinhole camera model
        const double FOCAL_LENGTH = 1000.0; // 1km focal length
        perspectiveScaledHeight =
            FOCAL_LENGTH * apparentVisibleHeight / distanceMeters;
        perspectiveScaledHeight =
            perspectiveScaledHeight < 0 ? 0 : perspectiveScaledHeight;
      }

      return CalculationResult(
        horizonDistance: d1 / 1000, // Horizon distance is still relevant
        hiddenHeight: 0, // No part is hidden
        cutoffElevation: 0,
        totalDistance:
            distanceMeters / 1000, // Total distance is just the input distance
        visibleDistance:
            0, // d2 is not applicable here, maybe set to 0 or distanceMeters? Let's use 0 for now.
        visibleTargetHeight: visibleTargetHeight / 1000,
        apparentVisibleHeight: apparentVisibleHeight / 1000,
        perspectiveScaledHeight: perspectiveScaledHeight / 1000,
        inputDistance: distance, // Store original input
        h1: observerHeight, // Store original input
        dipAngle: dipAngle, // Add dip angle
      );
    } else {
      // Object is partially or fully hidden beyond the horizon, proceed with original calculations

      // Calculate l2
      final double l2 = distanceMeters - d1;

      // Calculate BOX angle
      final double BOX_fraction = l2 / C;
      final double BOX_angle = 2 * math.pi * BOX_fraction;

      // Calculate the line-of-sight cutoff elevation at the target.
      final double OC = R / math.cos(BOX_angle);
      final double cutoffElevationMeters = OC - R;
      final double hiddenHeight = cutoffElevationMeters / 1000;

      // Calculate total distance (d0) and visible distance (d2)
      final double d2 = R *
          math.sin(
              BOX_angle); // Note: d2 here is distance from horizon point along curve
      final double d0 = d1 +
          d2; // This might need re-evaluation. Is d0 always observer-to-target-tangent? Let's keep for now.

      // If no target height, return basic calculations
      if (targetHeightMeters == null) {
        return CalculationResult(
          horizonDistance: d1 / 1000, // Convert to km
          hiddenHeight: hiddenHeight,
          cutoffElevation: hiddenHeight,
          totalDistance:
              d0 / 1000, // Convert to km - Check if this definition is correct
          visibleDistance: d2 / 1000, // Convert to km
          inputDistance: distance, // Store original input
          h1: observerHeight, // Store original input
          dipAngle: dipAngle, // Add dip angle
        );
      }

      // Calculate visible height of target if target height is provided
      double visibleTargetHeight = 0;
      double apparentVisibleHeight = 0;
      double perspectiveScaledHeight = 0;

      final double targetPhysicalHeight =
          math.max(targetHeightMeters - targetBaseElevationMeters, 0);
      final double hiddenTargetHeight = math.min(
        math.max(cutoffElevationMeters - targetBaseElevationMeters, 0),
        targetPhysicalHeight,
      );

      if (targetPhysicalHeight > 0) {
        visibleTargetHeight = targetPhysicalHeight - hiddenTargetHeight;

        // For 'beyond the horizon' cases, use the arc length from the horizon to the target (l2) for angle and perspective calculations
        if (visibleTargetHeight > 0) {
          // Angle subtended by l2 at Earth's center
          final double angle = l2 / effectiveRadius;
          apparentVisibleHeight = visibleTargetHeight * math.cos(angle);

          // Perspective scaled height uses l2, not full distance
          const double FOCAL_LENGTH = 1000.0; // 1km focal length
          perspectiveScaledHeight =
              l2 > 0 ? FOCAL_LENGTH * apparentVisibleHeight / l2 : 0;
          perspectiveScaledHeight =
              perspectiveScaledHeight < 0 ? 0 : perspectiveScaledHeight;
        }
      }

      return CalculationResult(
        horizonDistance: d1 / 1000, // Convert to km
        hiddenHeight: hiddenTargetHeight / 1000,
        cutoffElevation: cutoffElevationMeters / 1000,
        totalDistance: d0 / 1000, // Convert to km - Check definition
        visibleDistance: d2 / 1000, // Convert to km
        visibleTargetHeight: visibleTargetHeight / 1000,
        apparentVisibleHeight: apparentVisibleHeight / 1000,
        perspectiveScaledHeight: perspectiveScaledHeight / 1000,
        inputDistance: distance, // Original input distance
        h1: observerHeight, // Store original input value
        dipAngle: dipAngle, // Add dip angle
      );
    }
  }
}
