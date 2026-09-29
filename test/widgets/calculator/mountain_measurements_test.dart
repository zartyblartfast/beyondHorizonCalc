import 'package:BeyondHorizonCalc/services/models/calculation_result.dart';
import 'package:BeyondHorizonCalc/widgets/calculator/diagram/mountain_group_view_model.dart';
import 'package:BeyondHorizonCalc/services/curvature_calculator.dart';
import 'package:BeyondHorizonCalc/widgets/calculator/target_top_shortfall.dart';
import 'package:flutter/foundation.dart';
import 'dart:convert';
import 'dart:io';
import 'package:flutter/services.dart';
import 'package:BeyondHorizonCalc/widgets/calculator/diagram/label_group_handler.dart';
import 'package:BeyondHorizonCalc/widgets/calculator/diagram/mountain_diagram_view_model.dart';
import 'package:BeyondHorizonCalc/widgets/calculator/diagram/diagram_label_service.dart';
import 'package:xml/xml.dart';
import 'package:flutter_test/flutter_test.dart';

XmlElement element(String svg, String id) => XmlDocument.parse(svg)
    .descendants
    .whereType<XmlElement>()
    .singleWhere((e) => e.getAttribute('id') == id);

Future<String> render(CalculationResult result, double? target,
    {bool metric = true}) async {
  await LabelGroupHandler.initialize();
  final config =
      jsonDecode(await rootBundle.loadString('assets/info/diagram_spec.json'))
          as Map<String, dynamic>;
  final raw =
      await rootBundle.loadString('assets/svg/BTH_viewBox_diagram2.svg');
  final model = MountainDiagramViewModel(
      result: result,
      targetHeight: target,
      isMetric: metric,
      diagramSpec: config);
  return model
      .updateDynamicElements(DiagramLabelService().updateLabels(raw, model));
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  final originalDebugPrint = debugPrint;
  tearDown(() => debugPrint = originalDebugPrint);
  setUp(() {
    debugPrint = (String? message, {int? wrapWidth}) {};
  });
  for (final metric in [true, false]) {
    for (final surface in [0.0, 1000.0]) {
      test('real engine XC = XZ + CZ metric=$metric surface=$surface',
          () async {
        final units = metric ? 1.0 : 1 / 0.3048;
        final result = CurvatureCalculator.calculate(
            observerHeight: 2000 * units,
            distance: metric ? 500 : 500000 / 1609.34,
            refractionFactor: 1,
            isMetric: metric,
            targetHeight: 5193 * units,
            interveningSurfaceElevation: surface * units);
        expect(result.targetTopShortfall, greaterThan(0));
        expect(result.cutoffElevation!,
            closeTo(5.193 + result.targetTopShortfall!, 1e-8));
        final svg = await render(result, 5193 * units, metric: metric);
        expect(element(svg, 'CZ_Label').innerText,
            'CZ: ${formatTargetTopShortfall(result, metric)}');
        expect(element(svg, '5_2_Hidden_Height_Height').innerText,
            'XC: ${(result.cutoffElevation! * (metric ? 1000 : 3280.84)).toStringAsFixed(1)} ${metric ? 'm' : 'ft'}');
        final c = double.parse(element(svg, 'C').getAttribute('y')!) + 10;
        final z = double.parse(
            element(svg, 'CZ_Arrow').getAttribute('d')!.split(' V ').last);
        final baseY = c + result.cutoffElevation! * (600 / 18);
        expect(baseY - z, closeTo(5.193 * (600 / 18), 1e-5));
        expect(z - c, closeTo(result.targetTopShortfall! * (600 / 18), 1e-5));
        expect(element(svg, '1_2_Visible_Height_Height').getAttribute('style'),
            contains('display:none'));
        final output = Platform.environment['BHC_PNG_OUTPUT_DIR'];
        if (output != null) {
          File('$output/mountain-$metric-${surface.toInt()}.svg')
              .writeAsStringSync(svg);
        }
      });
    }
  }
  for (final scenario in ['tiny', 'boundary', 'above', 'no-target']) {
    test('CZ visibility and h3 preservation: $scenario', () async {
      final cutoff = CurvatureCalculator.calculate(
              observerHeight: 2000,
              distance: 500,
              refractionFactor: 1,
              isMetric: true)
          .cutoffElevation!;
      final target = switch (scenario) {
        'tiny' => cutoff * 1000 - 0.01,
        'boundary' => cutoff * 1000,
        'above' => cutoff * 1000 + 2000,
        _ => null,
      };
      final result = CurvatureCalculator.calculate(
          observerHeight: 2000,
          distance: 500,
          refractionFactor: 1,
          isMetric: true,
          targetHeight: target);
      final svg = await render(result, target);
      if (scenario == 'tiny') {
        expect(element(svg, 'CZ_Label').innerText, 'CZ: < 0.1 m');
        expect(element(svg, 'CZ_Leader'), isNotNull);
        final z = double.parse(
            element(svg, 'CZ_Arrow').getAttribute('d')!.split(' V ').last);
        expect(double.parse(element(svg, 'CZ_Label').getAttribute('y')!),
            greaterThan(z));
      } else {
        expect(svg, isNot(contains('id="CZ_Label"')));
        expect(svg, isNot(contains('id="CZ_Arrow"')));
      }
      if (scenario == 'above') {
        expect(element(svg, 'C').getAttribute('x'), '270');
        expect(element(svg, '1_2_Visible_Height_Height').innerText,
            'h3: 2000.0 m');
        expect(element(svg, '1_2_Visible_Height_Height').getAttribute('style'),
            isNot(contains('display:none')));
      }
      final output = Platform.environment['BHC_PNG_OUTPUT_DIR'];
      if (output != null) {
        File('$output/mountain-$scenario.svg').writeAsStringSync(svg);
      }
    });
  }

  test('fully hidden target has CZ from C to Z and an explicit C label',
      () async {
    final svg = await render(
        const CalculationResult(
            h1: 2000,
            hiddenHeight: 5.193,
            cutoffElevation: 8,
            targetTopShortfall: 2.807),
        5193);
    expect(element(svg, 'CZ_Label').innerText, 'CZ: 2807.0 m');
    expect(element(svg, 'C').innerText, 'C');
    final c = double.parse(element(svg, 'C').getAttribute('y')!) + 10;
    final path = element(svg, 'CZ_Arrow').getAttribute('d')!;
    expect(path, startsWith('M 145.0,$c V '));
    expect(double.parse(path.split(' V ').last),
        closeTo(c + 2.807 * (600 / 18), 1e-9));
  });
  test('updated XC arrow retains its identity and spans C to sea level X',
      () async {
    final svg = await render(
        const CalculationResult(
            h1: 2000,
            hiddenHeight: 5.193,
            cutoffElevation: 8,
            targetTopShortfall: 2.807),
        5193);
    final c = double.parse(element(svg, 'C').getAttribute('y')!) + 10;
    expect(element(svg, '5_1_Hidden_Height_Top_arrowhead').getAttribute('d'),
        startsWith('M 240.0,$c '));
    expect(element(svg, '5_3_Hidden_Height_Bottom_arrowhead').getAttribute('d'),
        startsWith('M 240.0,${c + 8 * (600 / 18)} '));
    expect(
        element(svg, 'C_Point_Line').getAttribute('d'), 'M -275,$c L 250,$c');
  });
  test('XC labels the sea-level cutoff, not capped hidden target height', () {
    final model = MountainGroupViewModel(
      result: const CalculationResult(hiddenHeight: 5.193, cutoffElevation: 8),
      targetHeight: 5193,
      isMetric: true,
      config: {},
    );
    expect(model.getLabelValues()['5_2_Hidden_Height_Height'], 'XC: 8000.0 m');
    expect(model.getLabelValues()['3_2_Z_Height'], 'XZ: 5193.0 m');
  });
}
