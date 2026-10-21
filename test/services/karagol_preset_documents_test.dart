import 'dart:convert';
import 'dart:io';

import 'package:BeyondHorizonCalc/services/curvature_calculator.dart';
import 'package:BeyondHorizonCalc/services/preset_info_service.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  test('guide distinguishes Elbrus and uses engine-verified results', () {
    final html = File('web/guide/index.html').readAsStringSync();
    expect(html, contains('Karagöl Dağı to Mount Elbrus'));
    expect(html, contains('20 May 2025'));
    expect(html, contains('474.1 km'));
    expect(html, contains('493.07 km'));
    expect(html, contains('Sağrak Gölü'));
    expect(
        html,
        contains(
            'href="https://trac.org.tr/tr/blog/haberler/3107m-karagol-daginda-rekor-denemesi-yapildi-745"'));
    final result = CurvatureCalculator.calculate(
      observerHeight: 3107,
      targetHeight: 5642,
      distance: 474.1,
      refractionFactor: 1.07,
      isMetric: true,
    );
    expect(result.visibleTargetHeight! * 1000, closeTo(357.891164, 0.00001));
    expect(
        html,
        contains(
            '${(result.visibleTargetHeight! * 1000).toStringAsFixed(1)} m'));
    expect(html, contains('${result.horizonDistance!.toStringAsFixed(2)} km'));
    expect(html, contains('1.03082'));
    for (final factor in [1.0, 1.03, 1.03081, 1.03082, 1.07]) {
      final value = CurvatureCalculator.calculate(
        observerHeight: 3107,
        targetHeight: 5642,
        distance: 474.1,
        refractionFactor: factor,
        isMetric: true,
      );
      expect(value.visibleTargetHeight! > 0, factor >= 1.03082);
    }
  });
  for (final report in [false, true]) {
    test(
        'preset ${report ? "report" : "help"} explains sourced Elbrus with engine output',
        () async {
      final html = await (report
          ? PresetInfoService.generatePresetReport()
          : PresetInfoService.generatePresetsInfo());
      expect(html, contains('Karagöl Dağı to Mount Elbrus'));
      expect(
          html,
          contains(
              'href="https://trac.org.tr/tr/blog/haberler/3107m-karagol-daginda-rekor-denemesi-yapildi-745"'));
      expect(html, contains('20 May 2025'));
      expect(html, contains('effective Earth radius multiplier'));
      expect(html, contains('not measured atmospheric conditions'));
      expect(html, contains('sea-level horizon datum'));
      expect(html, contains('Sağrak Gölü'));
      expect(html, contains('493.07 km'));
      expect(html, contains('1.20'));
      final raw =
          jsonDecode(File('assets/info/presets.json').readAsStringSync());
      for (final p
          in (raw['presets'] as List).where((p) => p['isHidden'] != true)) {
        final result = CurvatureCalculator.calculate(
          observerHeight: (p['observerHeight'] as num).toDouble(),
          targetHeight: (p['targetHeight'] as num).toDouble(),
          distance: (p['distance'] as num).toDouble(),
          refractionFactor: (p['refractionFactor'] as num).toDouble(),
          isMetric: true,
        );
        expect(
            html,
            contains(
                'Hidden Height: ~${(result.hiddenHeight! * 1000).round()}m'),
            reason: p['name']);
      }
    });
  }
}
