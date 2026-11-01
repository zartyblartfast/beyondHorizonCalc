import 'dart:math' as math;
import 'package:flutter_test/flutter_test.dart';
import 'package:BeyondHorizonCalc/services/scenario_comparison.dart';
import 'package:BeyondHorizonCalc/services/curvature_calculator.dart';

void main() {
  const ordinary = ComparisonInputs(
      observerElevation: 30,
      surfaceElevation: 0,
      distance: 30,
      refractionFactor: 1.07,
      isMetric: true,
      targetTop: 100);
  test(
      'regular ranges descend, omit off-step end, and include decimal endpoint',
      () {
    List<double> values(double a, double b, double step) =>
        ScenarioComparison.generate(
                inputs: ordinary,
                variable: ComparisonVariable.distance,
                start: a,
                end: b,
                increment: step)
            .rows
            .map((r) => r.value)
            .toList();
    expect(values(10, 1, 4), [10, 6, 2]);
    expect(values(1, 10, 4), [1, 5, 9]);
    expect(values(0.1, 0.3, 0.1), hasLength(3));
    expect(values(10, 10, 2), [10]);
  });
  test('invalid, nonfinite, excessive, and below-surface ranges are rejected',
      () {
    for (final range in <List<double>>[
      [1, 3, 0],
      [1, 3, -1],
      [double.nan, 3, 1],
      [1, double.infinity, 1],
      [1, 3, double.infinity],
      [0, 10, 1],
      [1, 601, 1],
      [1, 10, 0.0001],
    ]) {
      expect(
          () => ScenarioComparison.generate(
              inputs: ordinary,
              variable: ComparisonVariable.distance,
              start: range[0],
              end: range[1],
              increment: range[2]),
          throwsFormatException);
    }
    const lake = ComparisonInputs(
        observerElevation: 110,
        surfaceElevation: 100,
        distance: 30,
        refractionFactor: 1.2,
        isMetric: true);
    expect(
        () => ScenarioComparison.generate(
            inputs: lake,
            variable: ComparisonVariable.elevation,
            start: 90,
            end: 110,
            increment: 10),
        throwsFormatException);
  });
  test(
      'distance rows keep running after fully visible and export all with context',
      () {
    final table = ScenarioComparison.generate(
        inputs: ordinary,
        variable: ComparisonVariable.distance,
        start: 1,
        end: 5,
        increment: 1);
    expect(table.rows, hasLength(5));
    expect(table.status(table.rows.last), 'Fully visible');
    final csv = table.toCsv();
    expect(csv, contains('Target base: 0.0 m AMSL'));
    expect(csv, contains('Target top: 100.0 m AMSL'));
    expect(csv, contains('Refraction factor: 1.07'));
    expect(csv, contains('Distance to horizon:'));
    expect(csv, contains('beyondhorizoncalc.com'));
    expect(table.headers.where((h) => h.contains('horizon')), isEmpty);
    expect(csv.split('\r\n').where((line) => line.contains('Fully visible')),
        hasLength(5));
  });
  test(
      'imperial rows match real engine; missing target uses cutoff not hidden span',
      () {
    const inputs = ComparisonInputs(
        observerElevation: 100,
        surfaceElevation: 0,
        distance: 20,
        refractionFactor: 1.25,
        isMetric: false);
    final table = ScenarioComparison.generate(
        inputs: inputs,
        variable: ComparisonVariable.distance,
        start: 1,
        end: 31,
        increment: 10);
    expect(table.headers, contains('Cutoff elevation (ft AMSL)'));
    expect(table.cells(table.rows.first), contains('N/A'));
    expect(table.status(table.rows.first), contains('No target top'));
    for (final row in table.rows) {
      final expected = CurvatureCalculator.calculate(
          observerHeight: 100,
          distance: row.value,
          refractionFactor: 1.25,
          isMetric: false);
      expect(row.result.toMap(), expected.toMap());
    }
    expect(
        table.cells(table.rows.last)[1],
        inputs
            .heightFromKm(table.rows.last.result.cutoffElevation!)
            .toString());
  });
  test('below-surface target visibility is withheld, not claimed fully visible',
      () {
    const lake = ComparisonInputs(
        observerElevation: 110,
        surfaceElevation: 100,
        distance: 1,
        refractionFactor: 1.2,
        isMetric: true,
        targetTop: 200);
    final table = ScenarioComparison.generate(
        inputs: lake,
        variable: ComparisonVariable.distance,
        start: 1,
        end: 2,
        increment: 1);
    expect(table.status(table.rows.first), 'Unsupported below-surface target');
    expect(
        table.cells(table.rows.first).where((c) => c == 'N/A'), hasLength(2));
  });
  test('crossing the horizon preserves near-target protection per row', () {
    const radius = 6371000 * 1.2;
    final horizon = radius * math.acos(radius / (radius + 64)) / 1000;
    const inputs = ComparisonInputs(
        observerElevation: 1350,
        surfaceElevation: 1286,
        distance: 80.5,
        refractionFactor: 1.2,
        isMetric: true,
        targetTop: 1523);
    final table = ScenarioComparison.generate(
        inputs: inputs,
        variable: ComparisonVariable.distance,
        start: horizon - 1,
        end: horizon + 1,
        increment: 1);
    expect(table.rows, hasLength(3));
    for (final row in table.rows.take(2)) {
      expect(table.status(row), 'Unsupported below-surface target');
      expect(table.cells(row).where((c) => c == 'N/A'), hasLength(2));
    }
    expect(table.status(table.rows.last), 'Partially visible');
    expect(table.cells(table.rows.last), isNot(contains('N/A')));
  });
  for (final metric in [true, false]) {
    for (final variable in ComparisonVariable.values) {
      test(
          'elevated surface supports beyond-horizon ${variable.name}, metric=$metric',
          () {
        final heightScale = metric ? 1.0 : 1 / 0.3048;
        final distanceScale = metric ? 1.0 : 1 / 1.60934;
        final inputs = ComparisonInputs(
            observerElevation: 1350 * heightScale,
            surfaceElevation: 1286 * heightScale,
            distance: 80.5 * distanceScale,
            refractionFactor: 1.2,
            isMetric: metric,
            targetTop: 1523 * heightScale);
        final elevation = variable == ComparisonVariable.elevation;
        final table = ScenarioComparison.generate(
            inputs: inputs,
            variable: variable,
            start: elevation ? 1350 * heightScale : 80.5 * distanceScale,
            end: elevation ? 1400 * heightScale : 100.5 * distanceScale,
            increment: elevation ? 10 * heightScale : 10 * distanceScale);
        expect(table.rows, hasLength(elevation ? 6 : 3));
        expect(table.status(table.rows.first), 'Partially visible');
        expect(table.rows.first.result.visibleTargetHeight! * 1000,
            closeTo(78.57, 0.005));
        for (final row in table.rows) {
          final expected = CurvatureCalculator.calculate(
              observerHeight: elevation ? row.value : inputs.observerElevation,
              interveningSurfaceElevation: inputs.surfaceElevation,
              distance: elevation ? inputs.distance : row.value,
              refractionFactor: inputs.refractionFactor,
              isMetric: metric,
              targetHeight: inputs.targetTop);
          expect(row.result.toMap(), expected.toMap());
          final cells = table.cells(row, rounded: true);
          expect(cells, isNot(contains('N/A')));
          expect(
              cells,
              contains(inputs
                  .heightFromKm(expected.hiddenHeight!)
                  .toStringAsFixed(2)));
          expect(
              cells,
              contains(inputs
                  .heightFromKm(expected.visibleTargetHeight!)
                  .toStringAsFixed(2)));
          expect(table.toCsv(),
              contains(table.cells(row).map((c) => '"$c"').join(',')));
        }
        if (!elevation) expect(table.status(table.rows.last), 'Fully hidden');
        expect(
            table.toCsv(), isNot(contains('Unsupported below-surface target')));
      });
    }
  }
  test('elevation rows reuse engine and surface horizon with fixed inputs', () {
    const inputs = ComparisonInputs(
        observerElevation: 110,
        surfaceElevation: 100,
        distance: 30,
        refractionFactor: 1.2,
        isMetric: true,
        targetBase: 100,
        targetTop: 200);
    final table = ScenarioComparison.generate(
        inputs: inputs,
        variable: ComparisonVariable.elevation,
        start: 110,
        end: 160,
        increment: 10);
    expect(table.rows.length, 6);
    for (final row in table.rows) {
      final expected = CurvatureCalculator.calculate(
          observerHeight: row.value,
          interveningSurfaceElevation: 100,
          distance: 30,
          refractionFactor: 1.2,
          isMetric: true,
          targetBaseElevation: 100,
          targetHeight: 200);
      expect(row.result.toMap(), expected.toMap());
      const radius = 6371000 * 1.2;
      expect(
          row.horizonDistanceKm,
          closeTo(
              radius * math.acos(radius / (radius + row.value - 100)) / 1000,
              1e-10));
    }
    expect(inputs.observerElevation, 110);
  });
}
