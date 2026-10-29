import 'dart:math' as math;
import 'curvature_calculator.dart';
import 'models/calculation_result.dart';

enum ComparisonVariable { elevation, distance }

/// Immutable snapshot in the calculator's active input units. Target top is
/// normalized from either input method exactly once, before opening the dialog.
class ComparisonInputs {
  final double observerElevation, surfaceElevation, distance, refractionFactor;
  final double targetBase;
  final double? targetTop;
  final bool isMetric;
  const ComparisonInputs(
      {required this.observerElevation,
      required this.surfaceElevation,
      required this.distance,
      required this.refractionFactor,
      required this.isMetric,
      this.targetBase = 0,
      this.targetTop});
  String get heightUnit => isMetric ? 'm' : 'ft';
  String get distanceUnit => isMetric ? 'km' : 'mi';
  double heightFromKm(double km) => km * 1000 / (isMetric ? 1 : 0.3048);
  double distanceFromKm(double km) => km / (isMetric ? 1 : 1.60934);
}

class ComparisonRow {
  final double value;
  final CalculationResult result;
  final double horizonDistanceKm;
  const ComparisonRow(this.value, this.result, this.horizonDistanceKm);
}

class ScenarioComparison {
  static const maxRows = 1000;
  static const maxPngRows = 40;
  static const modelNote =
      'Surface distances; elevations above mean sea level (AMSL). '
      'Physical target heights. Curvature-only visibility; terrain and weather are not assessed. '
      'Status changes are sampled, not exact thresholds.';
  bool get variesElevation => variable == ComparisonVariable.elevation;
  String get variableLabel => variesElevation
      ? 'Observer eye-level elevation'
      : 'Target surface distance';
  String get variableUnit =>
      variesElevation ? '${inputs.heightUnit} AMSL' : inputs.distanceUnit;
  String get rangeLabel =>
      '$variableLabel: $start to $end $variableUnit; increment $increment ${variesElevation ? inputs.heightUnit : inputs.distanceUnit}; ${rows.length} rows';
  List<String> get heldConstant => [
        if (variesElevation)
          'Target surface distance: ${inputs.distance} ${inputs.distanceUnit}'
        else ...[
          'Observer eye-level elevation: ${inputs.observerElevation} ${inputs.heightUnit} AMSL',
          'Distance to horizon: ${inputs.distanceFromKm(rows.first.horizonDistanceKm)} ${inputs.distanceUnit} (surface)',
        ],
        'Target base: ${inputs.targetBase} ${inputs.heightUnit} AMSL',
        'Target top: ${inputs.targetTop == null ? 'not supplied' : '${inputs.targetTop} ${inputs.heightUnit} AMSL'}',
        'Horizon-forming surface: ${inputs.surfaceElevation} ${inputs.heightUnit} AMSL',
        'Refraction factor: ${inputs.refractionFactor}',
      ];
  bool _unsupported(ComparisonRow row) =>
      inputs.targetTop != null &&
      ((row.result.targetBaseAboveSurfaceKm ?? 0) < 0 ||
          (row.result.targetTopAboveSurfaceKm ?? 0) < 0);
  String status(ComparisonRow row) {
    if (inputs.targetTop == null) {
      return row.result.horizonPosition == HorizonPosition.beyond
          ? 'No target top — cutoff only'
          : 'No target top — before/at horizon';
    }
    if (_unsupported(row)) return 'Unsupported below-surface target';
    if (inputs.targetTop! <= inputs.targetBase) {
      return 'No positive target span';
    }
    if (row.result.visibleTargetHeight! <= 0) return 'Fully hidden';
    if (row.result.hiddenHeight! <= 0) return 'Fully visible';
    return 'Partially visible';
  }

  List<String> get headers => [
        '${variesElevation ? 'Eye elevation' : 'Target surface distance'} ($variableUnit)',
        if (variesElevation) 'Distance to horizon (${inputs.distanceUnit})',
        if (inputs.targetTop == null)
          'Cutoff elevation (${inputs.heightUnit} AMSL)'
        else ...[
          'Hidden target height (${inputs.heightUnit})',
          'Visible target height (${inputs.heightUnit})'
        ],
        'Visibility',
      ];
  List<String> cells(ComparisonRow row, {bool rounded = false}) {
    String number(double v) => rounded ? v.toStringAsFixed(2) : v.toString();
    String height(double? km) =>
        km == null ? 'N/A' : number(inputs.heightFromKm(km));
    return [
      number(row.value),
      if (variesElevation) number(inputs.distanceFromKm(row.horizonDistanceKm)),
      if (inputs.targetTop == null)
        height(row.result.horizonPosition == HorizonPosition.beyond
            ? row.result.cutoffElevation
            : null)
      else ...[
        height(_unsupported(row) ? null : row.result.hiddenHeight),
        height(_unsupported(row) ? null : row.result.visibleTargetHeight),
      ],
      status(row),
    ];
  }

  String toCsv() {
    String line(List<String> fields) =>
        fields.map((f) => '"${f.replaceAll('"', '""')}"').join(',');
    return [
      line(['Beyond Horizon Calculator — comparison']),
      line([rangeLabel]),
      for (final fact in heldConstant) line([fact]),
      line([modelNote]),
      line(['beyondhorizoncalc.com']),
      line(headers),
      for (final row in rows) line(cells(row)),
    ].join('\r\n');
  }

  final ComparisonInputs inputs;
  final ComparisonVariable variable;
  final double start, end, increment;
  final List<ComparisonRow> rows;
  const ScenarioComparison._(this.inputs, this.variable, this.start, this.end,
      this.increment, this.rows);

  static ScenarioComparison generate(
      {required ComparisonInputs inputs,
      required ComparisonVariable variable,
      required double start,
      required double end,
      required double increment}) {
    if (![
      start,
      end,
      increment,
      inputs.observerElevation,
      inputs.surfaceElevation,
      inputs.distance,
      inputs.refractionFactor,
      inputs.targetBase,
      if (inputs.targetTop != null) inputs.targetTop!
    ].every((v) => v.isFinite)) {
      throw const FormatException('All values must be finite numbers.');
    }
    if (increment <= 0) {
      throw const FormatException('Increment must be greater than zero.');
    }
    final maxEye = inputs.isMetric ? 9000.0 : 9000 * 3.28084;
    final maxDistance = inputs.isMetric ? 600.0 : 600 * 0.621371;
    void validateEye(double v) {
      if (v <= 0 || v > maxEye || v < inputs.surfaceElevation) {
        throw FormatException(
            'Eye elevation must be above 0, at or above the surface, and at most $maxEye ${inputs.heightUnit} AMSL.');
      }
    }

    void validateDistance(double v) {
      if (v <= 0 || v > maxDistance) {
        throw FormatException(
            'Surface distance must be above 0 and at most $maxDistance ${inputs.distanceUnit}.');
      }
    }

    validateEye(inputs.observerElevation);
    validateDistance(inputs.distance);
    if (inputs.surfaceElevation < 0 ||
        inputs.refractionFactor < 1 ||
        inputs.refractionFactor > 2 ||
        inputs.targetBase < 0 ||
        inputs.targetBase > maxEye ||
        (inputs.targetTop != null &&
            (inputs.targetTop! < inputs.targetBase ||
                inputs.targetTop! - inputs.targetBase > maxEye))) {
      throw const FormatException(
          'Current calculator settings are outside the supported domain.');
    }
    for (final endpoint in [start, end]) {
      if (variable == ComparisonVariable.elevation) {
        validateEye(endpoint);
      } else {
        validateDistance(endpoint);
      }
    }
    final steps = (end - start).abs() / increment;
    if (!steps.isFinite || steps >= maxRows) {
      throw const FormatException(
          'Maximum 1000 rows. Increase the increment or shorten the range.');
    }
    // Only absorb floating-point division round-off, never append an off-step end.
    final count = (steps + 1e-12 * math.max(1, steps)).floor() + 1;
    if (count > maxRows || (start != end && start + increment == start)) {
      throw const FormatException(
          'Range has too many rows or increment is too small.');
    }
    final rows = <ComparisonRow>[];
    for (var i = 0; i < count; i++) {
      final value = start + (end < start ? -1 : 1) * i * increment;
      final eye = variable == ComparisonVariable.elevation
          ? value
          : inputs.observerElevation;
      final distance =
          variable == ComparisonVariable.distance ? value : inputs.distance;
      final result = CurvatureCalculator.calculate(
          observerHeight: eye,
          interveningSurfaceElevation: inputs.surfaceElevation,
          distance: distance,
          refractionFactor: inputs.refractionFactor,
          isMetric: inputs.isMetric,
          targetBaseElevation: inputs.targetBase,
          targetHeight: inputs.targetTop);
      final radius =
          CurvatureCalculator.EARTH_RADIUS_METERS * inputs.refractionFactor;
      final height =
          (eye - inputs.surfaceElevation) * (inputs.isMetric ? 1 : 0.3048);
      rows.add(ComparisonRow(value, result,
          radius * math.acos(radius / (radius + height)) / 1000));
    }
    return ScenarioComparison._(
        inputs, variable, start, end, increment, List.unmodifiable(rows));
  }
}
