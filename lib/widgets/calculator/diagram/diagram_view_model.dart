import '../../../services/models/calculation_result.dart';

/// Base class for diagram view models that handle data and calculations for SVG diagrams
abstract class DiagramViewModel {
  final CalculationResult? result;
  final double? targetHeight;
  final bool isMetric;
  final String? presetName;

  DiagramViewModel({
    required this.result,
    this.targetHeight,
    required this.isMetric,
    this.presetName,
  });

  /// Converts kilometers to the current unit system (meters or feet)
  double convertFromKm(double km) {
    return isMetric ? km * 1000 : km * 3280.84;
  }

  /// Formats a number with appropriate units for display
  String formatDistance(double? value) {
    if (value == null) return '';
    return isMetric 
        ? '${value.toStringAsFixed(1)} km'
        : '${(value * 0.621371).toStringAsFixed(1)} mi';
  }

  /// Formats a height value with appropriate units for display
  String formatHeight(double? value) {
    if (value == null) return '';
    return isMetric 
        ? '${value.toStringAsFixed(1)} m'
        : '${value.toStringAsFixed(1)} ft';
  }

  /// Gets the hidden height in current units (meters or feet)
  double? get h2InUnits {
    if (result?.hiddenHeight == null) return null;
    return convertFromKm(result!.hiddenHeight!);
  }

  /// Determines the visibility state based on target height comparison
  String getVisibilityState() {
    if (targetHeight == null || targetHeight == 0 || h2InUnits == null) {
      return '';
    }

    if (targetHeight! < h2InUnits!) {
      return 'Hidden';
    } else {
      return 'Partially Visible';  // If target height > h2, it's always partially visible
    }
  }

  /// Gets the earth radius text with appropriate units
  String getRadiusText() {
    return isMetric ? 'R = 6,378 km' : 'R = 3,963 mi';
  }

  /// Gets all label values for the diagram
  Map<String, String> getLabelValues();
}
