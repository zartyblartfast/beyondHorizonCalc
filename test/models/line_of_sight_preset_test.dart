import 'package:BeyondHorizonCalc/models/line_of_sight_preset.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
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
