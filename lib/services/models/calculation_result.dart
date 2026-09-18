class CalculationResult {
  /// Distance fields are normalized to kilometres, regardless of UI units.
  final double? surfaceDistance;
  final double? observerToTargetBaseDistance;
  final double? observerToTargetTopDistance;
  final double? horizonLineDistance;
  final double? observerToHorizonDistance;
  final double? horizonToTargetRadialDistance;
  final double? horizonDistance; // in kilometers
  final double? hiddenHeight; // in kilometers
  final double?
      cutoffElevation; // line-of-sight cutoff above sea level, in kilometers
  final double? totalDistance; // in kilometers
  final double? visibleDistance; // in kilometers
  final double? visibleTargetHeight; // in kilometers
  final double? apparentVisibleHeight; // in kilometers
  final double? perspectiveScaledHeight; // in kilometers
  final double? inputDistance; // in kilometers/miles based on isMetric
  final double? h1; // observer height above intervening surface, in input units
  final double? dipAngle; // angle in degrees to look down to horizon

  const CalculationResult({
    this.surfaceDistance,
    this.observerToTargetBaseDistance,
    this.observerToTargetTopDistance,
    this.horizonLineDistance,
    this.observerToHorizonDistance,
    this.horizonToTargetRadialDistance,
    this.horizonDistance = 0,
    this.hiddenHeight = 0,
    this.cutoffElevation = 0,
    this.totalDistance = 0,
    this.visibleDistance = 0,
    this.visibleTargetHeight = 0,
    this.apparentVisibleHeight = 0,
    this.perspectiveScaledHeight = 0,
    this.inputDistance = 0,
    this.h1 = 0,
    this.dipAngle = 0,
  });

  // Convert to Map for backward compatibility with existing code
  Map<String, dynamic> toMap() {
    return {
      'surfaceDistance': surfaceDistance,
      'observerToTargetBaseDistance': observerToTargetBaseDistance,
      'observerToTargetTopDistance': observerToTargetTopDistance,
      'horizonLineDistance': horizonLineDistance,
      'observerToHorizonDistance': observerToHorizonDistance,
      'horizonToTargetRadialDistance': horizonToTargetRadialDistance,
      'horizonDistance': horizonDistance,
      'hiddenHeight': hiddenHeight,
      'cutoffElevation': cutoffElevation,
      'totalDistance': totalDistance,
      'visibleDistance': visibleDistance,
      'visibleTargetHeight': visibleTargetHeight,
      'apparentVisibleHeight': apparentVisibleHeight,
      'perspectiveScaledHeight': perspectiveScaledHeight,
      'inputDistance': inputDistance,
      'h1': h1,
      'dipAngle': dipAngle,
    };
  }

  // Create from Map for backward compatibility
  factory CalculationResult.fromMap(Map<String, dynamic> map) {
    return CalculationResult(
      surfaceDistance: map['surfaceDistance'] as double?,
      observerToTargetBaseDistance: map['observerToTargetBaseDistance'] as double?,
      observerToTargetTopDistance: map['observerToTargetTopDistance'] as double?,
      horizonLineDistance: map['horizonLineDistance'] as double?,
      observerToHorizonDistance: map['observerToHorizonDistance'] as double?,
      horizonToTargetRadialDistance: map['horizonToTargetRadialDistance'] as double?,
      horizonDistance: map['horizonDistance'] as double?,
      hiddenHeight: map['hiddenHeight'] as double?,
      cutoffElevation: map['cutoffElevation'] as double?,
      totalDistance: map['totalDistance'] as double?,
      visibleDistance: map['visibleDistance'] as double?,
      visibleTargetHeight: map['visibleTargetHeight'] as double?,
      apparentVisibleHeight: map['apparentVisibleHeight'] as double?,
      perspectiveScaledHeight: map['perspectiveScaledHeight'] as double?,
      inputDistance: map['inputDistance'] as double?,
      h1: map['h1'] as double?,
      dipAngle: map['dipAngle'] as double?,
    );
  }
}
