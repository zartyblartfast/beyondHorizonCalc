import 'dart:convert';
import 'dart:io';

import 'package:BeyondHorizonCalc/models/line_of_sight_preset.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  test('Elbrus is visible with sea-level defaults and Shkhara stays first',
      () async {
    final presets = await LineOfSightPreset.loadPresets();
    expect(presets.first.name, 'Karagöl Area to Shkhara - World Record');
    final matches =
        presets.where((p) => p.name == 'Karagöl Dağı to Mount Elbrus');
    expect(matches, hasLength(1));
    final preset = matches.single;
    expect(preset.observerHeight, 3107);
    expect(preset.targetHeight, 5642);
    expect(preset.distance, 474.1);
    expect(preset.refractionFactor, 1.07);
    expect(preset.interveningSurfaceElevation, 0);
    expect(preset.targetInputType, TargetInputType.elevation);
    final data =
        jsonDecode(File('assets/info/presets.json').readAsStringSync());
    expect(data['presets'], hasLength(193));
    final raw =
        (data['presets'] as List).singleWhere((p) => p['name'] == preset.name);
    expect(raw['details']['notes'], contains('20 May 2025'));
    expect(raw['details']['attribution'], contains('Richard Jezik'));
    for (var i = 1; i <= 4; i++) {
      expect(raw['details']['imageURL_$i'], isNull);
    }
  });
}
