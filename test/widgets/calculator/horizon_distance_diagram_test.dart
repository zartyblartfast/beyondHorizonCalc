import 'dart:io';
import 'package:flutter/services.dart';
import 'package:xml/xml.dart';
import 'package:BeyondHorizonCalc/services/curvature_calculator.dart';
import 'package:BeyondHorizonCalc/widgets/calculator/diagram/diagram_label_service.dart';
import 'package:BeyondHorizonCalc/widgets/calculator/diagram/horizon_diagram_view_model.dart';
import 'package:BeyondHorizonCalc/services/models/calculation_result.dart';
import 'package:BeyondHorizonCalc/widgets/calculator/diagram_display.dart';
import 'package:BeyondHorizonCalc/widgets/calculator/results_display.dart';
import 'package:BeyondHorizonCalc/models/line_of_sight_preset.dart';
import 'package:BeyondHorizonCalc/widgets/calculator/share_result_dialog.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets(
      'share preserves separate AC and AZ without false near visibility',
      (tester) async {
    final result = CurvatureCalculator.calculate(
        observerHeight: 100,
        distance: 10,
        refractionFactor: 1,
        isMetric: true,
        targetHeight: 20);
    await tester.pumpWidget(MaterialApp(
        home: Scaffold(
            body: ShareResultDialog(
                scenarioName: 'Near',
                observerHeight: '100',
                surfaceElevation: '0',
                distance: '10',
                refractionFactor: '1',
                targetHeight: '20',
                targetBaseElevation: '0',
                targetInputType: TargetInputType.elevation,
                result: result,
                isMetric: true))));
    expect(find.text('Horizon-line distance (D0 / AC)'), findsOneWidget);
    expect(find.text('Direct geometric distance (AZ)'), findsOneWidget);
    expect(find.text('Hidden height'), findsNothing);
    expect(find.text('Visible height'), findsNothing);
    expect(find.byType(SvgPicture), findsNothing);
    expect(tester.takeException(), isNull);
  });
  TestWidgetsFlutterBinding.ensureInitialized();
  test('generated active SVG brackets attach to A and C, not Z', () async {
    rootBundle
        .clear(); // Drop asset futures created by prior widget FakeAsync zones.
    for (final entry in {1: null, 2: 10.0, 4: 1000.0}.entries) {
      final raw =
          await rootBundle.loadString('assets/svg/BTH_${entry.key}.svg');
      final result = CurvatureCalculator.calculate(
          observerHeight: 10,
          distance: 100,
          targetHeight: entry.value,
          refractionFactor: 1,
          isMetric: true);
      final svg = DiagramLabelService().updateLabels(
          raw,
          HorizonDiagramViewModel(
              result: result, targetHeight: entry.value, isMetric: true));
      final doc = XmlDocument.parse(svg);
      XmlElement byId(String id) => doc.descendants
          .whereType<XmlElement>()
          .singleWhere((e) => e.getAttribute('id') == id);
      final tangent = RegExp(r'[-+]?(?:\d*\.)?\d+(?:e[-+]?\d+)?')
          .allMatches(byId('path5').getAttribute('d')!)
          .map((m) => double.parse(m[0]!))
          .toList();
      final cx = tangent[0], cy = tangent[1];
      final ax = cx + tangent[2], ay = cy + tangent[3];
      final bracket = byId('path16');
      final nums = RegExp(r'[-+]?(?:\d*\.)?\d+')
          .allMatches(bracket.getAttribute('d')!)
          .map((m) => double.parse(m[0]!))
          .toList();
      expect(nums, hasLength(4));
      expect(nums[0], closeTo(ax, 1e-8));
      expect(nums[2], closeTo(cx, 1e-8));
      expect(nums[1], nums[3]);
      if (entry.key == 4) {
        // D must remain clear of both the C extension and upper AC bracket.
        final dLabel = byId('text9-4');
        expect(double.parse(dLabel.getAttribute('x')!), lessThan(cx - 120));
        expect(
            nums[1], lessThan(double.parse(dLabel.getAttribute('y')!) - 110));
      }
      for (final p in [('A', ax, ay, nums[0]), ('C', cx, cy, nums[2])]) {
        final ext = byId('d0-extension-${p.$1}');
        expect(double.parse(ext.getAttribute('x1')!), closeTo(p.$2, 1e-8));
        expect(double.parse(ext.getAttribute('y1')!), closeTo(p.$3, 1e-8));
        expect(double.parse(ext.getAttribute('x2')!), p.$4);
        expect(double.parse(ext.getAttribute('y2')!), nums[1]);
      }
      // Labels must survive actual generation with correct IDs and values.
      expect(byId('LoS_Distance_d0').innerText,
          '${result.horizonLineDistance!.toStringAsFixed(1)} km');
      for (final id in [
        'h1',
        'h2',
        'd1',
        'd2',
        'L0',
        'text7',
        'text8',
        'text9'
      ]) {
        expect(byId(id).name.local, 'text');
      }
      final output = Platform.environment['BHC_STAGE_A_SVG_OUTPUT'];
      if (output != null)
        File('$output/BTH_${entry.key}.svg').writeAsStringSync(svg);
    }
  });
  testWidgets('legacy near metadata and A=B retain safe graphic suppression',
      (tester) async {
    for (final position in [
      HorizonPosition.before,
      HorizonPosition.at,
      HorizonPosition.beyond
    ]) {
      final result = CalculationResult(
          horizonPosition: position,
          h1: position == HorizonPosition.beyond ? 0 : 100);
      await tester.pumpWidget(MaterialApp(
          home: Scaffold(
              body: Column(children: [
        ResultsDisplay(result: result, isMetric: true),
        DiagramDisplay(result: result, isMetric: true),
      ]))));
      expect(find.byType(SvgPicture), findsNothing);
      expect(
          find.textContaining(position == HorizonPosition.beyond
              ? 'A = B'
              : 'datum metadata is missing'),
          position == HorizonPosition.beyond
              ? findsOneWidget
              : findsNWidgets(2));
      if (position != HorizonPosition.beyond) {
        expect(find.text('Horizon cutoff elevation (XC)'), findsNothing);
        expect(find.textContaining('Visibility and schematic unavailable'),
            findsNWidgets(2));
      }
      expect(tester.takeException(), isNull);
    }
  });
}
