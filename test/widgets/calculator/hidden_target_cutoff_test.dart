import 'package:BeyondHorizonCalc/services/curvature_calculator.dart';
import 'package:BeyondHorizonCalc/widgets/calculator/results_display.dart';
import 'package:BeyondHorizonCalc/widgets/calculator/diagram/horizon_diagram_view_model.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  for (final metric in [true, false]) {
    for (final top in [null, 100.0, 1000.0]) {
      test('cross-section h2 is geometric cutoff top=$top metric=$metric', () {
        final result = CurvatureCalculator.calculate(
          observerHeight: 2,
          distance: 100,
          refractionFactor: 1,
          isMetric: true,
          targetHeight: top,
        );
        final factor = metric ? 1000.0 : 3280.84;
        final labels = HorizonDiagramViewModel(
          result: result,
          isMetric: metric,
          targetHeight: top == null ? null : top * factor / 1000,
        ).getLabelValues();
        expect(result.cutoffElevation! * 1000, closeTo(707.6349889, 0.000001));
        expect(labels['h2'],
            '${(result.cutoffElevation! * factor).toStringAsFixed(1)} ${metric ? 'm' : 'ft'}');
        if (top != null) {
          expect(labels['HiddenHeight'],
              'Hidden Height = ${(result.hiddenHeight! * factor).toStringAsFixed(1)} ${metric ? 'm' : 'ft'}');
        }
      });

      testWidgets(
          'page distinguishes target span from cutoff top=$top metric=$metric',
          (tester) async {
        final result = CurvatureCalculator.calculate(
          observerHeight: 2,
          distance: 100,
          refractionFactor: 1,
          isMetric: true,
          targetHeight: top,
        );
        await tester.pumpWidget(MaterialApp(
            home: Scaffold(
                body: ResultsDisplay(
          result: result,
          isMetric: metric,
          targetHeight: top == null ? null : top * (metric ? 1 : 3.28084),
        ))));
        final label = top == null
            ? 'Horizon cutoff elevation (XC)'
            : 'Hidden target height';
        expect(find.text(label), findsOneWidget);
        expect(find.text('Hidden Height (h2, XC)'), findsNothing);
        final value =
            (top == null ? result.cutoffElevation! : result.hiddenHeight!) *
                (metric ? 1000 : 3280.84);
        expect(
            find.text(
                '${value.toStringAsFixed(1)} ${metric ? 'm' : 'ft'}${top == null ? ' AMSL' : ''}'),
            findsOneWidget);
        expect(tester.takeException(), isNull);
      });
    }
  }
}
