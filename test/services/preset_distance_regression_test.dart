// Baseline-only capture/regression. Never writes the expected fixture.
import 'dart:convert';
import 'dart:io';
import 'dart:math' as math;
import 'package:flutter_test/flutter_test.dart';
import 'package:BeyondHorizonCalc/models/line_of_sight_preset.dart';
import 'package:BeyondHorizonCalc/services/curvature_calculator.dart';

const dormantDistanceFields = [
  'surfaceDistance',
  'observerToTargetBaseDistance',
  'observerToTargetTopDistance',
  'horizonLineDistance',
  'observerToHorizonDistance',
  'horizonToTargetRadialDistance'
];

// Protect only the already-active physical quantities. New metadata and
// descriptive result fields are additive, not legacy regression failures.
const protectedBaselineFields = [
  'horizonDistance',
  'hiddenHeight',
  'cutoffElevation',
  'targetTopShortfall',
  'totalDistance',
  'visibleDistance',
  'visibleTargetHeight',
  'apparentVisibleHeight',
  'perspectiveScaledHeight',
  'inputDistance',
  'h1',
  'dipAngle',
];

List<Map<String, dynamic>> capturePresets() {
  final raw = (jsonDecode(File('assets/info/presets.json').readAsStringSync())
      as Map)['presets'] as List;
  return List.generate(raw.length, (i) {
    final p = LineOfSightPreset.fromJson(Map<String, dynamic>.from(raw[i]));
    Map<String, dynamic> run(bool uiRounded) {
      double val(double v, int digits) =>
          uiRounded ? double.parse(v.toStringAsFixed(digits)) : v;
      final entered = p.targetHeight == null ? null : val(p.targetHeight!, 1);
      final base =
          entered != null && p.targetInputType == TargetInputType.structure
              ? val(p.targetBaseElevation, 1)
              : 0.0;
      final top = entered == null ? null : entered + base;
      final h = val(p.observerHeight, 1),
          s = val(p.distance, 1),
          k = val(p.refractionFactor, 2);
      final inputs = {
        'observerHeight': h,
        'interveningSurfaceElevation': 0.0,
        'distance': s,
        'refractionFactor': k,
        'targetHeight': top,
        'targetBaseElevation': base,
        'isMetric': true
      };
      final result = CurvatureCalculator.calculate(
              observerHeight: h,
              distance: s,
              refractionFactor: k,
              targetHeight: top,
              targetBaseElevation: base,
              isMetric: true)
          .toMap();
      final radius = CurvatureCalculator.EARTH_RADIUS_METERS * k;
      final arc = radius * math.acos(radius / (radius + h));
      final delta = s * 1000 - arc;
      final active = Map<String, dynamic>.from(result)
        ..removeWhere((k, v) => !protectedBaselineFields.contains(k));
      return {
        'effectiveInputs': inputs,
        'enteredTargetHeight': entered,
        'horizonSurfaceDistanceMeters': arc,
        'classification': delta.abs() <= 1e-6
            ? 'at'
            : delta < 0
                ? 'before'
                : 'beyond',
        'activeResults': active,
        'dormantExplicitFields': Map.fromEntries(
            result.entries.where((e) => dormantDistanceFields.contains(e.key))),
        'allResults': result
      };
    }

    return {
      'sourceIndex': i,
      'name': p.name,
      'isHidden': p.isHidden,
      'sourceRecord': raw[i],
      'deserializedPreset': p.toJson(),
      'sourcePrecision': run(false),
      'metricUiRounded': run(true)
    };
  });
}

void main() {
  test('every preset preserves protected baseline fields and exact inputs', () {
    final actual = capturePresets();
    final output = Platform.environment['BHC_BASELINE_CAPTURE_OUTPUT'];
    if (output != null) {
      expect(
          output
              .replaceAll('\\', '/')
              .endsWith('test/fixtures/horizon_distance/preset_baseline.json'),
          isFalse,
          reason: 'Capture may not overwrite the immutable expected fixture');
      File(output).writeAsStringSync(
          const JsonEncoder.withIndent('  ').convert(actual));
    }
    final expected = jsonDecode(
        File('test/fixtures/horizon_distance/preset_baseline.json')
            .readAsStringSync()) as List;
    expect(actual.length, expected.length);
    expect(actual.map((e) => e['sourceIndex']).toSet().length, actual.length);
    for (var i = 0; i < actual.length; i++) {
      for (final key in [
        'sourceIndex',
        'name',
        'isHidden',
        'sourceRecord',
        'deserializedPreset'
      ]) {
        expect(actual[i][key], expected[i][key], reason: 'record $i $key');
      }
      for (final mode in ['sourcePrecision', 'metricUiRounded']) {
        for (final key in [
          'effectiveInputs',
          'enteredTargetHeight',
          'horizonSurfaceDistanceMeters',
          'classification',
          'activeResults'
        ]) {
          expect(actual[i][mode][key], expected[i][mode][key],
              reason: 'record $i $mode $key');
        }
      }
    }
  });
}
