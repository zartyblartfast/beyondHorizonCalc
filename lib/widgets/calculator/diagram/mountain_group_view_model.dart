import 'package:flutter/foundation.dart';
import '../../../services/models/calculation_result.dart';
import 'diagram_view_model.dart';
import 'svg_element_updater.dart';
import 'label_group_handler.dart';

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

    // Constants for Z-height elements
    const double labelHeight = 12.0877;
    const double labelPadding = 5.0;
    const double arrowMinLength = 10.0;
    const double xCoordinate = 325.0;
    const double arrowheadHeight = 10.0;
    
    // Z-height measurement group elements
    const zHeightElements = [
      '3_1_Z_Height_Top_arrowhead',
      '3_1_Z_Height_Top_arrow',
      '3_2_Z_Height',
      '3_3_Z_Height_Bottom_arrow',
      '3_3_Z_Height_Bottom_arrowhead'
    ];

    // Check if we have enough space - note that Y increases downward in SVG
    // so mountainPeakY will be larger than mountainBaseY
    final bool hasEnoughSpace = (mountainPeakY - mountainBaseY).abs() >= 50.0;  // Minimum space needed
    
    if (!hasEnoughSpace) {
      // Hide all Z-height elements if there's not enough space
      for (final elementId in zHeightElements) {
        updatedSvg = SvgElementUpdater.hideElement(updatedSvg, elementId);
      }
      
      if (kDebugMode) {
        debugPrint('Z-height elements hidden due to insufficient space');
        debugPrint('Mountain height: ${(mountainPeakY - mountainBaseY).abs()}');
        debugPrint('Required height: 50.0');
      }
    } else {
      // Show all Z-height elements first
      for (final elementId in zHeightElements) {
        updatedSvg = SvgElementUpdater.showElement(updatedSvg, elementId);
      }

      // Fixed x-coordinate at 325 for all elements
      const xCoord = 325.0;
    
      // Update top arrowhead at Z_Point_Line (mountain top)
      updatedSvg = SvgElementUpdater.updatePathElement(
        updatedSvg,
        '3_1_Z_Height_Top_arrowhead',
        {
          'd': 'M $xCoord,$mountainPeakY l -5,10 h 10 z',
          'fill': '#000000',
          'fill-opacity': '1',
          'stroke': 'none',
        },
      );

      // Update top arrow
      updatedSvg = SvgElementUpdater.updatePathElement(
        updatedSvg,
        '3_1_Z_Height_Top_arrow',
        {
          'd': 'M $xCoord,${mountainPeakY + 10} V ${mountainPeakY + ((mountainBaseY - mountainPeakY) / 2) - 10}',
          'stroke': '#000000',
          'stroke-width': '2.43608',
          'stroke-dasharray': 'none',
          'stroke-dashoffset': '0',
          'stroke-opacity': '1',
        },
      );

      // Update Z-height label
      final String heightText = isMetric ? 
        '${(targetHeight ?? 0.0).toStringAsFixed(1)}m' :
        '${(targetHeight ?? 0.0).toStringAsFixed(1)}ft';
      
      updatedSvg = LabelGroupHandler.updateTextElement(
        updatedSvg,
        '3_2_Z_Height',
        {
          'x': '$xCoord',
          'y': '${mountainPeakY + ((mountainBaseY - mountainPeakY) / 2)}',
          'text-anchor': 'middle',
          'dominant-baseline': 'middle',
          'font-style': 'normal',
          'font-variant': 'normal',
          'font-weight': 'bold',
          'font-stretch': 'normal',
          'font-size': '12.0877px',
          'font-family': 'Calibri',
          'text-align': 'start',
          'fill': '#552200',
          'content': heightText,
        },
        'heightMeasurement',
      );

      // Update bottom arrow
      updatedSvg = SvgElementUpdater.updatePathElement(
        updatedSvg,
        '3_3_Z_Height_Bottom_arrow',
        {
          'd': 'M $xCoord,${mountainPeakY + ((mountainBaseY - mountainPeakY) / 2) + 10} V ${mountainBaseY - 10}',
          'stroke': '#000000',
          'stroke-width': '2.46886',
          'stroke-dasharray': 'none',
          'stroke-dashoffset': '0',
          'stroke-opacity': '1',
        },
      );

      // Update bottom arrowhead at Distant_Obj_Sea_Level (mountain base)
      updatedSvg = SvgElementUpdater.updatePathElement(
        updatedSvg,
        '3_3_Z_Height_Bottom_arrowhead',
        {
          'd': 'M $xCoord,$mountainBaseY l -5,-10 h 10 z',
          'fill': '#000000',
          'fill-opacity': '1',
          'stroke': 'none',
        },
      );
    }

    if (kDebugMode) {
      debugPrint('\n6. Z_Point_Line and Label:');
      debugPrint('  - Line and label aligned at y: $mountainPeakY');
      debugPrint('  - Z label x position: 210');
      debugPrint('\n7. Z-height Elements:');
      debugPrint('  - Has enough space: $hasEnoughSpace');
    }

    return updatedSvg;
  }
}
