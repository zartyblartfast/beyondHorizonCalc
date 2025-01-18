class CalculationResult {
  final double? horizonDistance;    // in kilometers
  final double? hiddenHeight;       // in kilometers
  final double? totalDistance;      // in kilometers
  final double? visibleDistance;    // in kilometers
  final double? visibleTargetHeight;// in kilometers
  final double? apparentVisibleHeight; // in kilometers
  final double? perspectiveScaledHeight; // in kilometers

  const CalculationResult({
    this.horizonDistance = 0,
    this.hiddenHeight = 0,
    this.totalDistance = 0,
    this.visibleDistance = 0,
    this.visibleTargetHeight = 0,
    this.apparentVisibleHeight = 0,
    this.perspectiveScaledHeight = 0,
  });

  // Convert to Map for backward compatibility with existing code
  Map<String, dynamic> toMap() {
    return {
      'horizonDistance': horizonDistance,
      'hiddenHeight': hiddenHeight,
      'totalDistance': totalDistance,
      'visibleDistance': visibleDistance,
      'visibleTargetHeight': visibleTargetHeight,
      'apparentVisibleHeight': apparentVisibleHeight,
      'perspectiveScaledHeight': perspectiveScaledHeight,
    };
  }

  // Create from Map for backward compatibility
  factory CalculationResult.fromMap(Map<String, dynamic> map) {
    return CalculationResult(
      horizonDistance: map['horizonDistance'] as double?,
      hiddenHeight: map['hiddenHeight'] as double?,
      totalDistance: map['totalDistance'] as double?,
      visibleDistance: map['visibleDistance'] as double?,
      visibleTargetHeight: map['visibleTargetHeight'] as double?,
      apparentVisibleHeight: map['apparentVisibleHeight'] as double?,
      perspectiveScaledHeight: map['perspectiveScaledHeight'] as double?,
    );
  }
}
