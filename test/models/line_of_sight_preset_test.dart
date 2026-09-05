import 'dart:convert';
import 'dart:io';

import 'package:BeyondHorizonCalc/models/line_of_sight_preset.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('includes the Karagöl Area to Shkhara world-record preset', () {
    final asset = File('assets/info/presets.json');
    final json = jsonDecode(asset.readAsStringSync()) as Map<String, dynamic>;
    final presets = json['presets'] as List<dynamic>;
    final firstVisiblePreset = presets.cast<Map<String, dynamic>>().firstWhere(
          (preset) => preset['isHidden'] != true,
        );
    final preset = presets.cast<Map<String, dynamic>>().singleWhere(
          (preset) => preset['name'] == 'Karagöl Area to Shkhara - World Record',
        );

    expect(firstVisiblePreset['name'], 'Karagöl Area to Shkhara - World Record');
    expect(preset['isHidden'], isFalse);
    expect(preset['observerHeight'], 3035);
    expect(preset['distance'], 493.07);
    expect(preset['refractionFactor'], 1.20);
    expect(preset['targetHeight'], 5193);
  });

  test('includes Finestrelles to Pic Gaspard below Barre des Ecrins', () {
    final asset = File('assets/info/presets.json');
    final json = jsonDecode(asset.readAsStringSync()) as Map<String, dynamic>;
    final presets = (json['presets'] as List<dynamic>)
        .cast<Map<String, dynamic>>();
    final barreIndex = presets.indexWhere(
      (preset) => preset['name'] == 'Finestrelles to Barre des Ecrins',
    );
    final gaspardIndex = presets.indexWhere(
      (preset) => preset['name'] == 'Finestrelles to Pic Gaspard',
    );
    final preset = presets[gaspardIndex];

    expect(preset['isHidden'], isFalse);
    expect(preset['observerHeight'], 2828);
    expect(preset['distance'], 443);
    expect(preset['refractionFactor'], 1.20);
    expect(preset['targetHeight'], 3883);
    expect(gaspardIndex, barreIndex + 1);
  });

  test('parses a structure target with a base elevation', () {
    final preset = LineOfSightPreset.fromJson({
      'name': 'Hilltop Tower',
      'description': 'A tower on elevated ground',
      'observerHeight': 102,
      'distance': 50,
      'refractionFactor': 1.07,
      'targetHeight': 100,
      'targetInputType': 'structure',
      'targetBaseElevation': 100,
    });

    expect(preset.targetInputType, TargetInputType.structure);
    expect(preset.targetHeight, 100);
    expect(preset.targetBaseElevation, 100);
  });

  test('defaults existing mountain presets to elevation input', () {
    final preset = LineOfSightPreset.fromJson({
      'name': 'Mountain',
      'description': 'Existing preset format',
      'observerHeight': 1000,
      'distance': 50,
      'refractionFactor': 1.07,
      'targetHeight': 2000,
    });

    expect(preset.targetInputType, TargetInputType.elevation);
    expect(preset.targetBaseElevation, 0);
  });
}
