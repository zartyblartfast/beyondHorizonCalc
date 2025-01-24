import 'package:flutter/foundation.dart';
import '../../../services/models/calculation_result.dart';
import 'diagram_view_model.dart';
import 'svg_element_updater.dart';

/// Handles positioning and scaling for the Mountain group elements in the mountain diagram
class MountainGroupViewModel extends DiagramViewModel {
  // Configuration from diagram_spec.json
  final Map<String, dynamic> config;

  // Coordinate system constants - matching observer group
  static const double _viewboxScale = 600 / 18; // Scale factor: 600 viewbox units = 18km

  MountainGroupViewModel({
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
    // Mountain group has no labels to update
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

  /// Updates all Mountain group elements in the SVG
  String updateMountainGroup(String svgContent, double observerLevel) {
    var updatedSvg = svgContent;
    
    // Get hidden height (h2/XC) in kilometers from calculation result
    final double h2InKm = result?.hiddenHeight ?? 0.0;
    final double h2Viewbox = h2InKm * _viewboxScale;
    
    // Position Distant_Obj_Sea_Level below C_Point_Line by h2/XC distance
    final double seaLevelY = observerLevel + h2Viewbox;
    
    if (kDebugMode) {
      debugPrint('\nMountain Group Validation:');
      debugPrint('1. Input Values:');
      debugPrint('  - Observer Height (h1): ${result?.h1 ?? 0.0} ${isMetric ? 'm' : 'ft'}');
      debugPrint('  - Hidden Height (h2/XC): ${h2InKm} km');
      debugPrint('  - Target Height (XZ): ${targetHeight ?? 0.0} ${isMetric ? 'm' : 'ft'}');
      
      debugPrint('\n2. Viewbox Scaling:');
      debugPrint('  - Scale factor: $_viewboxScale viewbox units per km');
      debugPrint('  - h2/XC in viewbox units: $h2Viewbox');
      
      debugPrint('\n3. Vertical Positions:');
      debugPrint('  - C_Point_Line at: $observerLevel');
      debugPrint('  - Sea Level Line at: $seaLevelY');
      debugPrint('  - Vertical drop from C_Point_Line to Sea Level: ${seaLevelY - observerLevel}');
    }

    // Update Distant_Obj_Sea_Level line
    updatedSvg = SvgElementUpdater.updatePathElement(
      updatedSvg,
      'Distant_Obj_Sea_Level',
      {
        'd': 'M -200,$seaLevelY L 200,$seaLevelY',
        'style': 'fill:#808080;fill-opacity:0;stroke:#808080;stroke-width:3.28827;stroke-dasharray:none;stroke-opacity:1',
      },
    );

    // Get target height (XZ) and convert to kilometers
    final double xzInKm = isMetric ? (targetHeight ?? 0.0) / 1000.0 : (targetHeight ?? 0.0) / 3280.84;
    final double xzViewbox = xzInKm * _viewboxScale;
    
    // Position mountain peak above its base by target height
    final double mountainBaseY = seaLevelY;
    final double mountainPeakY = mountainBaseY - xzViewbox;
    
    if (kDebugMode) {
      debugPrint('\n4. Mountain Geometry:');
      debugPrint('  - XZ in kilometers: $xzInKm');
      debugPrint('  - XZ in viewbox units: $xzViewbox');
      debugPrint('  - Mountain base at: $mountainBaseY');
      debugPrint('  - Mountain peak at: $mountainPeakY');
      debugPrint('  - Mountain height in viewbox units: ${mountainBaseY - mountainPeakY}');
      
      debugPrint('\n5. Geometric Validation:');
      debugPrint('  - Base below C_Point_Line by: ${mountainBaseY - observerLevel}');
      debugPrint('  - Peak below C_Point_Line by: ${mountainPeakY - observerLevel}');
    }

    // Update Mountain triangle with fixed width base (-90 to +90)
    updatedSvg = SvgElementUpdater.updatePathElement(
      updatedSvg,
      'Mountain',
      {
        'd': 'M -90,$mountainBaseY L 90,$mountainBaseY L 0,$mountainPeakY Z',
        'style': 'display:inline;fill:#4d4d4d;fill-rule:evenodd;stroke-width:0.378085',
      },
    );

    // Update Z_Point_Line to align with mountain peak
    updatedSvg = SvgElementUpdater.updatePathElement(
      updatedSvg,
      'Z_Point_Line',
      {
        'd': 'M 200,$mountainPeakY L 0,$mountainPeakY',
        'style': 'fill:#1a1a1a;fill-opacity:0;stroke:#808080;stroke-width:2.12098;stroke-dasharray:4.24196, 2.12098;stroke-dashoffset:0;stroke-opacity:1',
      },
    );

    // Update Z label to align with Z_Point_Line
    updatedSvg = SvgElementUpdater.updateTextElement(
      updatedSvg,
      'Z',
      {
        'x': '210',
        'y': '${mountainPeakY + 10}',  // Offset by ~1/3 of font size to center vertically
        'dominant-baseline': 'middle',  // Helps with vertical centering
      },
    );

    // Update X label to align with Distant_Obj_Sea_Level
    updatedSvg = SvgElementUpdater.updateTextElement(
      updatedSvg,
      'X',
      {
        'x': '210',
        'y': '${seaLevelY + 10}',  // Use same vertical centering offset as Z
        'dominant-baseline': 'middle',
      },
    );

    if (kDebugMode) {
      debugPrint('\n6. Z_Point_Line and Label:');
      debugPrint('  - Line and label aligned at y: $mountainPeakY');
      debugPrint('  - Z label x position: 210');
    }

    return updatedSvg;
  }
}
