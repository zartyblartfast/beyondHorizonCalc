import '../../services/models/calculation_result.dart';

/// Shared page/export policy; classification comes only from the engine.
class HorizonPresentation {
  static bool isNear(CalculationResult r) =>
      r.horizonPosition == HorizonPosition.before ||
      r.horizonPosition == HorizonPosition.at;
  static String? limitation(CalculationResult r) {
    if ([
      r.observerAboveSurfaceKm,
      r.targetBaseAboveSurfaceKm,
      r.targetTopAboveSurfaceKm
    ].any((v) => v != null && v < 0)) {
      return 'Visibility and schematic withheld: an endpoint is below the horizon-forming surface. This datum case is not supported by the illustration; legacy calculations are unchanged.';
    }
    if (r.observerAboveSurfaceKm == null ||
        r.targetBaseAboveSurfaceKm == null ||
        r.tangentRadialHeightKm == null) {
      return 'Visibility and schematic unavailable: datum metadata is missing from this legacy result.';
    }
    return null;
  }

  static String status(CalculationResult r) {
    final position =
        "Target is ${r.horizonPosition == HorizonPosition.at ? 'at' : 'before'} the observer's horizon. ";
    if (limitation(r) case final message?) return '$position$message';
    if (r.targetTopAboveSurfaceKm == null) {
      return '${position}No target top supplied; no visibility percentage.';
    }
    if (r.targetTopAboveSurfaceKm! <= r.targetBaseAboveSurfaceKm!) {
      return '${position}No positive target span; no visibility percentage.';
    }
    return '${position}100% visible (curvature only). Terrain and other obstructions are not modelled.';
  }
}
