import 'dart:convert';

import '../core/constants/range_limits.dart';

/// One versioned input snapshot. No results or example metadata are persisted.
/// Storage callbacks keep browser access behind a small, testable boundary.
class CustomScenarioStore {
  static const storageKey = 'beyondHorizonCalc.customScenario.v1';
  final String? Function() read;
  final void Function(String) write;
  final void Function() remove;

  const CustomScenarioStore({
    required this.read,
    required this.write,
    required this.remove,
  });

  Map<String, Object>? load() {
    try {
      final raw = read();
      if (raw == null) return null;
      final decoded = jsonDecode(raw);
      if (decoded is! Map<String, dynamic>) return null;
      final value = Map<String, Object>.from(decoded);
      return _isValid(value) ? value : null;
    } catch (_) {
      // Blocked storage, corrupt JSON and old schemas must not prevent use.
      return null;
    }
  }

  bool save(Map<String, Object> scenario) {
    if (!_isValid(scenario)) return false;
    try {
      final encoded = jsonEncode(scenario);
      write(encoded);
      return read() == encoded;
    } catch (_) {
      return false;
    }
  }

  bool clear() {
    try {
      remove();
      return read() == null;
    } catch (_) {
      return false;
    }
  }

  static bool _isValid(Map<String, Object> value) {
    const fields = [
      'observerHeight',
      'surfaceElevation',
      'distance',
      'refractionFactor',
      'targetHeight',
      'targetBaseElevation',
    ];
    if (value.length != 10 ||
        value['version'] != 1 ||
        value['isMetric'] is! bool ||
        value['surfaceAboveSeaLevel'] is! bool ||
        !['elevation', 'structure'].contains(value['targetInputType'])) {
      return false;
    }
    for (final field in fields) {
      if (value[field] is! String) return false;
    }
    double? number(String key) => double.tryParse(value[key] as String);
    final metric = value['isMetric'] as bool;
    final heightScale = metric ? 1.0 : 3.28084;
    final distanceScale = metric ? 1.0 : 0.621371;
    bool inRange(String key, double max, {bool positive = false}) {
      final n = number(key);
      return n != null && n.isFinite && (positive ? n > 0 : n >= 0) && n <= max;
    }

    if (!inRange('observerHeight', RangeLimits.maxObserverHeight * heightScale,
            positive: true) ||
        !inRange('distance', RangeLimits.maxDistance * distanceScale,
            positive: true) ||
        !inRange('surfaceElevation', number('observerHeight')!) ||
        !inRange('refractionFactor', 1.25, positive: true)) {
      return false;
    }
    if (value['surfaceAboveSeaLevel'] == false &&
        number('surfaceElevation') != 0) {
      return false;
    }
    if (value['targetHeight'] != '' &&
        !inRange('targetHeight', RangeLimits.maxTargetHeight * heightScale)) {
      return false;
    }
    // Inactive base text is retained exactly, but is not used by the engine.
    if (value['targetInputType'] == 'structure' &&
        value['targetHeight'] != '' &&
        !inRange(
            'targetBaseElevation', RangeLimits.maxTargetHeight * heightScale)) {
      return false;
    }
    return true;
  }
}
