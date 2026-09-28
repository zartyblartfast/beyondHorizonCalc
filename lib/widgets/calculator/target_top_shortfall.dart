import '../../services/models/calculation_result.dart';

const targetTopShortfallLabel = 'Target top below horizon line (CZ)';

/// Shared page/share presentation of the calculator's radial shortfall.
String? formatTargetTopShortfall(CalculationResult result, bool isMetric) {
  final shortfall = result.targetTopShortfall;
  if (shortfall == null || shortfall <= 0) return null;
  final value = shortfall * (isMetric ? 1000 : 3280.84);
  final rounded = value.toStringAsFixed(1);
  return '${rounded == '0.0' ? '< 0.1' : rounded} ${isMetric ? 'm' : 'ft'}';
}
