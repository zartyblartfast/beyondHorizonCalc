import 'package:flutter/foundation.dart';
import '../../../services/models/calculation_result.dart';
import 'diagram_view_model.dart';
import 'svg_element_updater.dart';

/// Handles positioning and scaling for the Sky group elements in the mountain diagram
class SkyGroupViewModel extends DiagramViewModel {
  // Configuration from diagram_spec.json
  final Map<String, dynamic> config;

  SkyGroupViewModel({
    required CalculationResult? result,
    double? targetHeight,
    required bool isMetric,
    String? presetName,
    required this.config,
  }) : super(
    result: result,
    targetHeight: targetHeight,
    isMetric: isMetric,
    presetName: presetName,
  );

  @override
  Map<String, String> getLabelValues() {
    // Sky group has no labels to update
    return {};
  }

  /// Gets a double value from nested config path with fallback
  double? _getConfigDouble(List<String> path) {
    dynamic value = config;
    for (final key in path) {
      value = value is Map ? value[key] : null;
      if (value == null) return null;
    }
    return value is num ? value.toDouble() : null;
  }

  /// Updates all Sky group elements in the SVG
  String updateSkyGroup(String svgContent, double observerLevel) {
    var updatedSvg = svgContent;
    
    // Sky rectangle should extend from top of diagram (y=0) to C_Point_Line
    const double skyTop = 0.0;
    final double skyHeight = observerLevel - skyTop;
    
    if (kDebugMode) {
      debugPrint('Updating Sky rectangle:');
      debugPrint('  Top (y): $skyTop');
      debugPrint('  Height: $skyHeight');
    }
    
    updatedSvg = SvgElementUpdater.updateRectElement(
      updatedSvg,
      'Sky',
      {
        'x': '-200',
        'y': '$skyTop',
        'width': '400',
        'height': '$skyHeight',
        'style': 'opacity:0.74;fill:url(#linearGradient1);fill-opacity:1;fill-rule:evenodd;stroke-width:0.270778',
      },
    );

    return updatedSvg;
  }
}
