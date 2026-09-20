import 'dart:convert';

import 'package:BeyondHorizonCalc/services/custom_scenario_store.dart';
import 'package:flutter_test/flutter_test.dart';

Map<String, Object> scenario() => {
      'version': 1,
      'isMetric': false,
      'targetInputType': 'structure',
      'surfaceAboveSeaLevel': true,
      'observerHeight': '300',
      'surfaceElevation': '20',
      'distance': '25',
      'refractionFactor': '1.07',
      'targetHeight': '100',
      'targetBaseElevation': '50',
    };

void main() {
  test('malformed, incompatible and unsafe snapshots are ignored', () {
    for (final raw in [
      '{',
      '[]',
      'null',
      '{}',
      jsonEncode(scenario()..['version'] = 2),
      jsonEncode(scenario()..['isMetric'] = 'false'),
      jsonEncode(scenario()..['targetInputType'] = 'unknown'),
      jsonEncode(scenario()..remove('distance')),
      jsonEncode(scenario()..['observerHeight'] = 'NaN'),
      jsonEncode(scenario()..['distance'] = 'Infinity'),
      jsonEncode(scenario()..['distance'] = '0'),
      jsonEncode(scenario()..['surfaceElevation'] = '301'),
      jsonEncode(scenario()..['observerHeight'] = '999999'),
      jsonEncode(scenario()..['refractionFactor'] = '0'),
      jsonEncode(scenario()..['surfaceAboveSeaLevel'] = false),
      jsonEncode(scenario()..['result'] = 123),
    ]) {
      final store = CustomScenarioStore(
        read: () => raw,
        write: (_) {},
        remove: () {},
      );
      expect(store.load(), isNull, reason: raw);
    }
  });

  test('unavailable storage does not break load, save or clear', () {
    final store = CustomScenarioStore(
      read: () => throw StateError('blocked'),
      write: (_) => throw StateError('quota'),
      remove: () => throw StateError('blocked'),
    );
    expect(store.load(), isNull);
    expect(store.save(scenario()), isFalse);
    expect(store.clear(), isFalse);
  });

  test('stores one input-only record and reads it back exactly', () {
    String? stored;
    final store = CustomScenarioStore(
      read: () => stored,
      write: (value) => stored = value,
      remove: () => stored = null,
    );
    expect(store.load(), isNull);
    expect(store.save(scenario()), isTrue);
    expect(store.load(), scenario());
    expect(jsonDecode(stored!), scenario());
    final replacement = scenario()..['distance'] = '30';
    expect(store.save(replacement), isTrue);
    expect(store.load(), replacement);
    expect(store.clear(), isTrue);
    expect(stored, isNull);
  });
}
