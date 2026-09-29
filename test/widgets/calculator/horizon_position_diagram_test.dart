import 'dart:io';
import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:xml/xml.dart';
import 'package:BeyondHorizonCalc/services/curvature_calculator.dart';
import 'package:BeyondHorizonCalc/services/models/calculation_result.dart';
import 'package:BeyondHorizonCalc/widgets/calculator/diagram_display.dart';

Future<XmlDocument> render(WidgetTester tester, CalculationResult result,
    {double? top = 20, bool compact = true}) async {
  rootBundle.clear();
  await tester.pumpWidget(MaterialApp(
      home: Scaffold(
          body: SingleChildScrollView(
              child: DiagramDisplay(
                  result: result,
                  targetHeight: top,
                  isMetric: true,
                  compact: compact)))));
  await tester.runAsync(() async {
    await Future<void>.delayed(const Duration(milliseconds: 150));
  });
  await tester.pump();
  expect(find.byType(SvgPicture), findsOneWidget);
  final picture = tester.widget<SvgPicture>(find.byType(SvgPicture));
  final svg = (picture.bytesLoader as SvgStringLoader).provideSvg(null);
  final output = Platform.environment['BHC_STAGE_B_SVG_OUTPUT'];
  if (output != null) {
    File(
        '$output/${result.horizonPosition!.name}-${top ?? 'no-top'}-$compact.svg')
      ..parent.createSync(recursive: true)
      ..writeAsStringSync(svg);
  }
  return XmlDocument.parse(svg);
}

XmlElement element(XmlDocument doc, String id) => doc.descendants
    .whereType<XmlElement>()
    .singleWhere((e) => e.getAttribute('id') == id);
double coordinate(XmlDocument doc, String id, String attr) =>
    double.parse(element(doc, id).getAttribute(attr)!);
void main() {
  testWidgets('clamped below-surface observer is not falsely labelled A=B',
      (tester) async {
    final result = CurvatureCalculator.calculate(
        observerHeight: 90,
        interveningSurfaceElevation: 100,
        distance: 10,
        refractionFactor: 1,
        isMetric: true);
    await tester.pumpWidget(
        MaterialApp(home: DiagramDisplay(result: result, isMetric: true)));
    expect(find.textContaining('below the horizon-forming surface'),
        findsOneWidget);
    expect(find.textContaining('A = B'), findsNothing);
    expect(find.byType(SvgPicture), findsNothing);
  });
  testWidgets(
      'zero-height target lies at X and does not invent a physical span',
      (tester) async {
    final result = CurvatureCalculator.calculate(
        observerHeight: 100,
        distance: 10,
        targetHeight: 0,
        refractionFactor: 1,
        isMetric: true);
    final doc = await render(tester, result, top: 0);
    expect(coordinate(doc, 'point-Z', 'cx'), coordinate(doc, 'point-X', 'cx'));
    expect(coordinate(doc, 'point-Z', 'cy'), coordinate(doc, 'point-X', 'cy'));
  });
  testWidgets(
      'observer on surface explicitly identifies A=B without three-point graphic',
      (tester) async {
    final result = CurvatureCalculator.calculate(
        observerHeight: 0,
        distance: 10,
        targetHeight: 20,
        refractionFactor: 1,
        isMetric: true);
    for (final compact in [true, false]) {
      await tester.pumpWidget(MaterialApp(
          home: DiagramDisplay(
              result: result,
              targetHeight: 20,
              isMetric: true,
              compact: compact)));
      expect(find.textContaining('A = B'), findsOneWidget);
      expect(find.textContaining('D1 = 0; D0 = D2'), findsOneWidget);
      expect(find.byType(SvgPicture), findsNothing);
    }
  });
  testWidgets(
      'exact boundary coalesces C B X and zero BC without separated markers',
      (tester) async {
    final distance = 6371 * math.acos(6371000 / 6371100);
    for (final top in [20.0, null]) {
      final result = CurvatureCalculator.calculate(
          observerHeight: 100,
          targetHeight: top,
          distance: distance,
          refractionFactor: 1,
          isMetric: true);
      final doc = await render(tester, result, top: top, compact: false);
      expect(doc.rootElement.getAttribute('id'), 'at-horizon');
      for (final axis in ['cx', 'cy']) {
        expect(
            coordinate(doc, 'point-C', axis), coordinate(doc, 'point-B', axis));
        expect(
            coordinate(doc, 'point-X', axis), coordinate(doc, 'point-B', axis));
      }
      expect(doc.toXmlString(), contains('C = B = X'));
      final jointLabel = doc.descendants.whereType<XmlElement>().singleWhere(
          (e) => e.name.local == 'text' && e.innerText == 'C = B = X');
      expect(double.parse(jointLabel.getAttribute('x')!),
          greaterThan(coordinate(doc, 'd1-extension-B', 'x1') + 5));
      expect(doc.toXmlString(), contains('D0 = D1; D2 = 0'));
      expect(coordinate(doc, 'd0-bracket', 'x2'),
          coordinate(doc, 'point-B', 'cx'));
      expect(coordinate(doc, 'd2-bracket', 'x1'),
          coordinate(doc, 'd2-bracket', 'x2'));
    }
  });
  testWidgets('missing top omits Z target and AZ from schematic',
      (tester) async {
    final result = CurvatureCalculator.calculate(
        observerHeight: 100, distance: 10, refractionFactor: 1, isMetric: true);
    final doc = await render(tester, result, top: null);
    expect(
        doc.descendants.whereType<XmlElement>().where((e) =>
            ['point-Z', 'target-top', 'az'].contains(e.getAttribute('id'))),
        isEmpty);
  });
  testWidgets(
      'target Z follows below on above C without hidden split and AZ attaches',
      (tester) async {
    final seed = CurvatureCalculator.calculate(
        observerHeight: 100, distance: 10, refractionFactor: 1, isMetric: true);
    final cHeight = seed.tangentRadialHeightKm! * 1000;
    for (final delta in [-10.0, 0.0, 10.0]) {
      final top = cHeight + delta;
      final result = CurvatureCalculator.calculate(
          observerHeight: 100,
          targetHeight: top,
          distance: 10,
          refractionFactor: 1,
          isMetric: true);
      final doc = await render(tester, result, top: top);
      final zy = coordinate(doc, 'point-Z', 'cy'),
          cy = coordinate(doc, 'point-C', 'cy');
      expect(zy.compareTo(cy), -delta.sign.toInt());
      for (final axis in ['x', 'y']) {
        expect(coordinate(doc, 'az', '${axis}1'),
            coordinate(doc, 'point-A', 'c$axis'));
        expect(coordinate(doc, 'az', '${axis}2'),
            coordinate(doc, 'point-Z', 'c$axis'));
        expect(coordinate(doc, 'target', '${axis}1'),
            coordinate(doc, 'point-X', 'c$axis'));
        expect(coordinate(doc, 'target', '${axis}2'),
            coordinate(doc, 'point-Z', 'c$axis'));
      }
      expect(doc.toXmlString(), isNot(contains('hidden')));
      // Binary image payloads can contain arbitrary label-like base64 tokens.
      expect(doc.findAllElements('text').map((e) => e.innerText).join(' '),
          isNot(contains('h3')));
    }
  });
  testWidgets(
      'before selects A-C-B schematic in main and compact with attached AC bracket',
      (tester) async {
    final result = CurvatureCalculator.calculate(
        observerHeight: 100,
        targetHeight: 20,
        distance: 10,
        refractionFactor: 1,
        isMetric: true);
    for (final compact in [true, false]) {
      final doc = await render(tester, result, compact: compact);
      expect(doc.rootElement.getAttribute('id'), 'before-horizon');
      final a = coordinate(doc, 'point-A', 'cx');
      final c = coordinate(doc, 'point-C', 'cx');
      final b = coordinate(doc, 'point-B', 'cx');
      expect(a, lessThan(c));
      expect(c, lessThan(b));
      for (final id in ['A', 'C']) {
        expect(coordinate(doc, 'd0-extension-$id', 'x1'),
            coordinate(doc, 'point-$id', 'cx'));
        expect(coordinate(doc, 'd0-extension-$id', 'y1'),
            coordinate(doc, 'point-$id', 'cy'));
      }
      expect(coordinate(doc, 'd0-bracket', 'x1'), a);
      expect(coordinate(doc, 'd0-bracket', 'x2'), c);
      expect(doc.toXmlString(), contains('D0 = D1 - D2'));
      expect(doc.toXmlString(), contains('Schematic - not to scale'));
      expect(doc.findAllElements('text').map((e) => e.innerText).join(' '),
          isNot(contains('CZ')));
      expect(find.textContaining('Vertical illustration is not applicable'),
          compact ? findsNothing : findsOneWidget);
      expect(tester.takeException(), isNull);
    }
  });
}
