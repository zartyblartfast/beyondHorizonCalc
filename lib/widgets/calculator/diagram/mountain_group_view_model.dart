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

  // Constants for Z-height marker
  static const double Z_HEIGHT_LABEL_HEIGHT = 12.0877;
  static const double Z_HEIGHT_LABEL_PADDING = 5.0;
  static const double Z_HEIGHT_MIN_ARROW_LENGTH = 10.0;
  static const double Z_HEIGHT_TOTAL_REQUIRED_HEIGHT = Z_HEIGHT_LABEL_HEIGHT + (2 * Z_HEIGHT_LABEL_PADDING) + (2 * Z_HEIGHT_MIN_ARROW_LENGTH);

  // Constants for V-height marker
  static const double V_HEIGHT_LABEL_HEIGHT = 12.0877;
  static const double V_HEIGHT_LABEL_PADDING = 5.0;
  static const double V_HEIGHT_MIN_ARROW_LENGTH = 10.0;
  static const double V_HEIGHT_X_COORD = 240.0;
  static const double V_HEIGHT_TOTAL_REQUIRED_HEIGHT = V_HEIGHT_LABEL_HEIGHT + (2 * V_HEIGHT_LABEL_PADDING) + (2 * V_HEIGHT_MIN_ARROW_LENGTH);

  // Constants for H-height marker
  static const double H_HEIGHT_LABEL_HEIGHT = 12.0877;
  static const double H_HEIGHT_LABEL_PADDING = 5.0;
  static const double H_HEIGHT_MIN_ARROW_LENGTH = 10.0;
  static const double H_HEIGHT_X_COORD = V_HEIGHT_X_COORD;
  static const double H_HEIGHT_TOTAL_REQUIRED_HEIGHT = H_HEIGHT_LABEL_HEIGHT + (2 * H_HEIGHT_LABEL_PADDING) + (2 * H_HEIGHT_MIN_ARROW_LENGTH);

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
    final Map<String, String> labels = {};
    
    // Use target height directly since it's already in the correct units
    if (targetHeight != null) {
      final prefix = _getConfigString(['labels', 'points', '3_2_Z_Height', 'prefix']) ?? 'XZ: ';
      labels['3_2_Z_Height'] = '$prefix${formatHeight(targetHeight!)}';
      
      if (kDebugMode) {
        debugPrint('Z-Height label updated:');
        debugPrint('  - Target Height: $targetHeight');
        debugPrint('  - Prefix: $prefix');
        debugPrint('  - Final label: ${labels['3_2_Z_Height']}');
      }
    }

    // Add Visible Height (h3) label
    if (result?.visibleTargetHeight != null) {
      final prefix = _getConfigString(['labels', 'points', '1_2_Visible_Height_Height', 'prefix']) ?? 'h3: ';
      // Convert from km to current units (meters or feet)
      final heightInUnits = convertFromKm(result!.visibleTargetHeight!);
      labels['1_2_Visible_Height_Height'] = '$prefix${formatHeight(heightInUnits)}';
      
      if (kDebugMode) {
        debugPrint('V-Height label updated:');
        debugPrint('  - Visible Height: ${result!.visibleTargetHeight}');
        debugPrint('  - Height in Units: $heightInUnits');
        debugPrint('  - Prefix: $prefix');
        debugPrint('  - Final label: ${labels['1_2_Visible_Height_Height']}');
      }
    }

    // Add Hidden Height (h2) label
    if (result?.hiddenHeight != null) {
      final prefix = _getConfigString(['labels', 'points', '5_2_Hidden_Height_Height', 'prefix']) ?? 'h2: ';
      // Convert from km to current units (meters or feet)
      final heightInUnits = convertFromKm(result!.hiddenHeight!);
      labels['5_2_Hidden_Height_Height'] = '$prefix${formatHeight(heightInUnits)}';
      
      if (kDebugMode) {
        debugPrint('H-Height label updated:');
        debugPrint('  - Hidden Height: ${result!.hiddenHeight}');
        debugPrint('  - Height in Units: $heightInUnits');
        debugPrint('  - Prefix: $prefix');
        debugPrint('  - Final label: ${labels['5_2_Hidden_Height_Height']}');
      }
    }

    return labels;
  }

  /// Gets a string value from nested config path with fallback
  String? _getConfigString(List<String> path) {
    dynamic value = config;
    for (final key in path) {
      value = value is Map ? value[key] : null;
      if (value == null) return null;
    }
    return value is String ? value : null;
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
    
    // Run validation first
    validateZHeight();
    
    if (kDebugMode) {
      debugPrint('\nMountain Group Validation:');
      debugPrint('1. Input Values:');
      debugPrint('  - Observer Height (h1): ${result?.h1 ?? 0.0} ${isMetric ? 'm' : 'ft'}');
      debugPrint('  - Hidden Height (h2/XC): ${result?.hiddenHeight ?? 0.0} km');
      debugPrint('  - Target Height (XZ): ${targetHeight ?? 0.0} ${isMetric ? 'm' : 'ft'}');
    }
    
    // Get hidden height (h2/XC) in kilometers from calculation result
    final double h2InKm = result?.hiddenHeight ?? 0.0;
    final double h2Viewbox = h2InKm * _viewboxScale;
    
    // Position Distant_Obj_Sea_Level below C_Point_Line by h2/XC distance
    final double seaLevelY = observerLevel + h2Viewbox;
    
    if (kDebugMode) {
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
        'd': 'M -200,$seaLevelY L 350,$seaLevelY',
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

    // Calculate V-Height positions between Z_Point_Line and C_Point_Line
    final vHeightPositions = calculateVHeightPositions(mountainPeakY, observerLevel);
    final vHeightElements = [
      '1_1_Visible_Height_Top_arrowhead',
      '1_1_Visible_Height_Top_arrow',
      '1_2_Visible_Height_Height',
      '1_3_Visible_Height_Bottom_arrow',
      '1_3_Visible_Height_Bottom_arrowhead'
    ];

    if (vHeightPositions['visible'] == 0.0) {
      // Hide V-height elements if there's not enough space
      for (final elementId in vHeightElements) {
        updatedSvg = SvgElementUpdater.hideElement(updatedSvg, elementId);
      }

      if (kDebugMode) {
        debugPrint('V-height elements hidden due to insufficient space');
      }
    } else {
      // Show and position all V-height elements
      for (final elementId in vHeightElements) {
        updatedSvg = SvgElementUpdater.showElement(updatedSvg, elementId);
      }

      // Update V-height arrows and label
      final positions = vHeightPositions;
      
      // Update top arrow
      updatedSvg = SvgElementUpdater.updatePathElement(
        updatedSvg,
        '1_1_Visible_Height_Top_arrow',
        {
          'd': 'M ${V_HEIGHT_X_COORD},${positions['startY']} V ${positions['topArrowEnd']}',
          'style': 'fill:none;stroke:#000000;stroke-width:1.99598',
        },
      );

      // Update bottom arrow
      updatedSvg = SvgElementUpdater.updatePathElement(
        updatedSvg,
        '1_3_Visible_Height_Bottom_arrow',
        {
          'd': 'M ${V_HEIGHT_X_COORD},${positions['bottomArrowStart']} V ${positions['endY']}',
          'style': 'fill:none;stroke:#000000;stroke-width:1.99598',
        },
      );

      // Update arrowheads using same pattern as Z_Height
      updatedSvg = SvgElementUpdater.updatePathElement(
        updatedSvg,
        '1_1_Visible_Height_Top_arrowhead',
        {
          'd': 'M ${V_HEIGHT_X_COORD},${positions['startY']} l -5,10 h 10 z',
          'style': 'fill:#000000;stroke:none;fill-opacity:1',
        },
      );

      updatedSvg = SvgElementUpdater.updatePathElement(
        updatedSvg,
        '1_3_Visible_Height_Bottom_arrowhead',
        {
          'd': 'M ${V_HEIGHT_X_COORD},${positions['endY']} l -5,-10 h 10 z',
          'style': 'fill:#000000;stroke:none;fill-opacity:1',
        },
      );

      // Update label position
      updatedSvg = LabelGroupHandler.updateTextElement(
        updatedSvg,
        '1_2_Visible_Height_Height',
        {
          'x': '$V_HEIGHT_X_COORD',
          'y': '${positions['labelY']}',
        },
        'heightMeasurement',
      );

      if (kDebugMode) {
        debugPrint('\nV-Height Positions:');
        debugPrint('  - Top Arrow Y: ${positions['startY']}');
        debugPrint('  - Label Y: ${positions['labelY']}');
        debugPrint('  - Bottom Arrow Y: ${positions['endY']}');
      }
    }

    // Get Distant_Obj_Sea_Level and C_Point_Line Y-coordinates
    final double distantObjY = seaLevelY;  // Distant_Obj_Sea_Level aligns with sea level
    final double cPointY = observerLevel;  // C_Point_Line aligns with observer level

    // Calculate H-Height positions between Distant_Obj_Sea_Level and C_Point_Line
    final hHeightPositions = calculateHHeightPositions(distantObjY, cPointY);
    final hHeightElements = [
      '5_1_Hidden_Height_Top_arrowhead',
      '5_1_Hidden_Height_Top_arrow',
      '5_2_Hidden_Height_Height',
      '5_3_Hidden_Height_Bottom_arrow',
      '5_3_Hidden_Height_Bottom_arrowhead'
    ];

    if (hHeightPositions['visible'] == 0.0) {
      // Hide H-height elements if there's not enough space
      for (final elementId in hHeightElements) {
        updatedSvg = SvgElementUpdater.hideElement(updatedSvg, elementId);
      }

      if (kDebugMode) {
        debugPrint('H-height elements hidden due to insufficient space');
      }
    } else {
      // Show and position all H-height elements
      for (final elementId in hHeightElements) {
        updatedSvg = SvgElementUpdater.showElement(updatedSvg, elementId);
      }

      // Update H-height arrows and label
      final positions = hHeightPositions;
      
      // Update top arrow
      updatedSvg = SvgElementUpdater.updatePathElement(
        updatedSvg,
        '5_1_Hidden_Height_Top_arrow',
        {
          'd': 'M ${H_HEIGHT_X_COORD},${positions['startY']} V ${positions['topArrowEnd']}',
          'style': 'fill:none;stroke:#000000;stroke-width:1.99598',
        },
      );

      // Update bottom arrow
      updatedSvg = SvgElementUpdater.updatePathElement(
        updatedSvg,
        '5_3_Hidden_Height_Bottom_arrow',
        {
          'd': 'M ${H_HEIGHT_X_COORD},${positions['bottomArrowStart']} V ${positions['endY']}',
          'style': 'fill:none;stroke:#000000;stroke-width:1.99598',
        },
      );

      // Update arrowheads
      updatedSvg = SvgElementUpdater.updatePathElement(
        updatedSvg,
        '5_1_Hidden_Height_Top_arrowhead',
        {
          'd': 'M ${H_HEIGHT_X_COORD},${positions['startY']} l -5,10 h 10 z',
          'style': 'fill:#000000;stroke:none;fill-opacity:1',
        },
      );

      updatedSvg = SvgElementUpdater.updatePathElement(
        updatedSvg,
        '5_3_Hidden_Height_Bottom_arrowhead',
        {
          'd': 'M ${H_HEIGHT_X_COORD},${positions['endY']} l -5,-10 h 10 z',
          'style': 'fill:#000000;stroke:none;fill-opacity:1',
        },
      );

      // Update label position
      updatedSvg = LabelGroupHandler.updateTextElement(
        updatedSvg,
        '5_2_Hidden_Height_Height',
        {
          'x': H_HEIGHT_X_COORD.toString(),
          'y': positions['labelY'].toString(),
        },
        'heightMeasurement',
      );
    }

    // Update Z_Point_Line to align with mountain peak
    updatedSvg = SvgElementUpdater.updatePathElement(
      updatedSvg,
      'Z_Point_Line',
      {
        'd': 'M 350,$mountainPeakY L 0,$mountainPeakY',
        'style': 'fill:#1a1a1a;fill-opacity:0;stroke:#808080;stroke-width:2.12098;stroke-dasharray:4.24196, 2.12098;stroke-dashoffset:0;stroke-opacity:1',
      },
    );

    // Update Z and X labels using LabelGroupHandler for consistent styling
    updatedSvg = LabelGroupHandler.updateTextElement(
      updatedSvg,
      'Z',
      {
        'x': '210',
        'y': '${mountainPeakY - 10}',
        'dominant-baseline': 'middle',
        'style': 'font-weight: bold',
      },
      'heightMeasurement',
    );

    updatedSvg = LabelGroupHandler.updateTextElement(
      updatedSvg,
      'X',
      {
        'x': '210',
        'y': '${seaLevelY + 20}',
        'dominant-baseline': 'middle',
        'style': 'font-weight: bold',
      },
      'heightMeasurement',
    );

    // Fixed x-coordinate for all Z-height elements
    const xCoord = 325.0;

    // Calculate Z-Height positions
    final zHeightPositions = calculateZHeightPositions(mountainPeakY, mountainBaseY);
    final zHeightElements = [
      '3_1_Z_Height_Top_arrow',
      '3_1_Z_Height_Top_arrowhead',
      '3_2_Z_Height',
      '3_3_Z_Height_Bottom_arrow',
      '3_3_Z_Height_Bottom_arrowhead'
    ];

    if (zHeightPositions['visible'] == 0.0) {
      // Hide Z-height elements if there's not enough space
      for (final elementId in zHeightElements) {
        updatedSvg = SvgElementUpdater.hideElement(updatedSvg, elementId);
      }

      if (kDebugMode) {
        debugPrint('Z-height elements hidden due to insufficient space');
      }
    } else {
      // Show all Z-height elements
      for (final elementId in zHeightElements) {
        updatedSvg = SvgElementUpdater.showElement(updatedSvg, elementId);
      }

      // Update Z-height label with proper centering using LabelGroupHandler
      updatedSvg = LabelGroupHandler.updateTextElement(
        updatedSvg,
        '3_2_Z_Height',
        {
          'x': '$xCoord',
          'y': '${zHeightPositions['labelY']}',
        },
        'heightMeasurement'  // Use same group as C-Height for consistent styling
      );

      // Update top arrow
      updatedSvg = SvgElementUpdater.updatePathElement(
        updatedSvg,
        '3_1_Z_Height_Top_arrow',
        {
          'd': 'M $xCoord,${zHeightPositions['startY']} V ${zHeightPositions['topArrowEnd']}',
          'stroke': '#000000',
          'stroke-width': '1.99598',
          'stroke-dasharray': 'none',
          'stroke-dashoffset': '0',
          'stroke-opacity': '1',
        },
      );

      // Update top arrowhead
      updatedSvg = SvgElementUpdater.updatePathElement(
        updatedSvg,
        '3_1_Z_Height_Top_arrowhead',
        {
          'd': 'M $xCoord,${zHeightPositions['startY']} l -5,10 h 10 z',
          'fill': '#000000',
          'fill-opacity': '1',
          'stroke': 'none',
        },
      );

      // Update bottom arrow
      updatedSvg = SvgElementUpdater.updatePathElement(
        updatedSvg,
        '3_3_Z_Height_Bottom_arrow',
        {
          'd': 'M $xCoord,${zHeightPositions['bottomArrowStart']} V ${zHeightPositions['endY']}',
          'stroke': '#000000',
          'stroke-width': '2.07704',
          'stroke-dasharray': 'none',
          'stroke-dashoffset': '0',
          'stroke-opacity': '1',
        },
      );

      // Update bottom arrowhead
      updatedSvg = SvgElementUpdater.updatePathElement(
        updatedSvg,
        '3_3_Z_Height_Bottom_arrowhead',
        {
          'd': 'M $xCoord,${zHeightPositions['endY']} l -5,-10 h 10 z',
          'fill': '#000000',
          'fill-opacity': '1',
          'stroke': 'none',
        },
      );
    }

    if (kDebugMode) {
      debugPrint('\n6. Z-height Element Positions:');
      debugPrint('  - X coordinate: $xCoord');
      debugPrint('  - Top elements at: ${zHeightPositions['startY']}');
      debugPrint('  - Label at: ${zHeightPositions['labelY']}');
      debugPrint('  - Bottom elements at: ${zHeightPositions['endY']}');
    }

    return updatedSvg;
  }

  /// Validates Z-height configuration and calculations
  bool validateZHeight() {
    if (kDebugMode) {
      debugPrint('\nZ-Height Validation:');
      
      // 1. Configuration Validation
      debugPrint('\n1. Configuration Check:');
      final prefix = _getConfigString(['labels', 'points', '3_2_Z_Height', 'prefix']);
      debugPrint('  - Label prefix: ${prefix ?? "Not found"}');
      
      // 2. Position Validation
      debugPrint('\n2. Position Check:');
      if (result?.hiddenHeight == null) {
        debugPrint('  - Error: Missing hidden height');
        return false;
      }
      if (targetHeight == null) {
        debugPrint('  - Error: Missing target height');
        return false;
      }
      
      // 3. Visibility Rule Validation
      debugPrint('\n3. Visibility Rules:');
      final h2InKm = result?.hiddenHeight ?? 0.0;
      final h2Viewbox = h2InKm * _viewboxScale;
      final xzInKm = isMetric ? (targetHeight ?? 0.0) / 1000.0 : (targetHeight ?? 0.0) / 3280.84;
      final xzViewbox = xzInKm * _viewboxScale;
      
      debugPrint('  - Hidden height (h2): $h2Viewbox viewbox units');
      debugPrint('  - Target height (XZ): $xzViewbox viewbox units');
      debugPrint('  - Total height: ${h2Viewbox + xzViewbox} viewbox units');
      
      if (h2Viewbox <= 0) {
        debugPrint('  - Warning: Zero or negative hidden height');
      }
      if (xzViewbox <= 0) {
        debugPrint('  - Warning: Zero or negative target height');
      }
      
      // 4. Label Value Validation
      debugPrint('\n4. Label Values:');
      final labelValues = getLabelValues();
      debugPrint('  - Z-height label: ${labelValues['3_2_Z_Height'] ?? "Not set"}');
      
      return true;
    }
    return true;
  }

  /// Checks if there's enough space between two points for Z-height display
  bool hasSufficientSpace(double? topY, double? bottomY) {
    if (topY == null || bottomY == null) {
      if (kDebugMode) {
        debugPrint('hasSufficientSpace - Missing reference points');
      }
      return false;
    }
    
    final space = (bottomY - topY).abs();
    const minSpace = 50.0;  // Minimum space needed for Z-height display
    
    if (kDebugMode) {
      debugPrint('hasSufficientSpace - Available space: $space');
      debugPrint('hasSufficientSpace - Required space: $minSpace');
    }
    
    return space >= minSpace;
  }

  /// Updates visibility of multiple SVG elements
  void updateVisibility(String svgContent, List<String> elements, bool isVisible) {
    for (final elementId in elements) {
      svgContent = isVisible
        ? SvgElementUpdater.showElement(svgContent, elementId)
        : SvgElementUpdater.hideElement(svgContent, elementId);
    }
  }

  /// Calculate positions for V-height marker elements
  Map<String, double> calculateVHeightPositions(double topY, double bottomY) {
    if (kDebugMode) {
      debugPrint('calculateVHeightPositions - Starting calculation');
      debugPrint('  - Z_Point_Line Y: $topY');
      debugPrint('  - C_Point_Line Y: $bottomY');
    }

    // First check if mountain is hidden (Z_Point_Line >= C_Point_Line)
    if (topY >= bottomY) {
      if (kDebugMode) {
        debugPrint('calculateVHeightPositions - Mountain is hidden (Z_Point_Line >= C_Point_Line), hiding V-height');
      }
      return {'visible': 0.0};
    }
    
    // Then check if there's enough space
    if (!hasSufficientSpace(topY, bottomY)) {
      if (kDebugMode) {
        debugPrint('calculateVHeightPositions - Insufficient space, hiding V-height');
      }
      return {'visible': 0.0};
    }
    
    final double totalHeight = bottomY - topY;
    final double labelY = topY + (totalHeight / 2.0) + (V_HEIGHT_LABEL_HEIGHT / 4.0);
    final double topArrowEnd = labelY - V_HEIGHT_LABEL_HEIGHT - V_HEIGHT_LABEL_PADDING;
    final double bottomArrowStart = labelY + V_HEIGHT_LABEL_PADDING;
    
    if (kDebugMode) {
      debugPrint('calculateVHeightPositions - V-height marker is visible');
      debugPrint('  - Label Y: $labelY');
      debugPrint('  - Top Arrow End: $topArrowEnd');
      debugPrint('  - Bottom Arrow Start: $bottomArrowStart');
    }

    return {
      'visible': 1.0,
      'startY': topY,
      'topArrowEnd': topArrowEnd,
      'labelY': labelY,
      'bottomArrowStart': bottomArrowStart,
      'endY': bottomY
    };
  }

  /// Calculate positions for H-height marker elements
  Map<String, double> calculateHHeightPositions(double distantObjY, double cPointY) {
    if (kDebugMode) {
      debugPrint('calculateHHeightPositions - Starting calculation');
      debugPrint('  - Distant_Obj_Sea_Level Y: $distantObjY');
      debugPrint('  - C_Point_Line Y: $cPointY');
    }

    if (!hasSufficientSpace(distantObjY, cPointY)) {
      return {'visible': 0.0};
    }
    
    // Note: In viewBox coordinates, Y increases downward (0 to 1000)
    // So cPointY will be less than distantObjY
    final double totalHeight = distantObjY - cPointY;  // Reversed order due to coordinate system
    final double labelY = cPointY + (totalHeight / 2.0) + (H_HEIGHT_LABEL_HEIGHT / 4.0);
    final double topArrowEnd = labelY - H_HEIGHT_LABEL_HEIGHT - H_HEIGHT_LABEL_PADDING;
    final double bottomArrowStart = labelY + H_HEIGHT_LABEL_PADDING;
    
    return {
      'visible': 1.0,
      'startY': cPointY,           // Top arrow starts at C_Point_Line (higher in viewBox)
      'topArrowEnd': topArrowEnd,
      'labelY': labelY,
      'bottomArrowStart': bottomArrowStart,
      'endY': distantObjY         // Bottom arrow ends at Distant_Obj_Sea_Level (lower in viewBox)
    };
  }

  /// Calculate positions for Z-height marker elements
  Map<String, double> calculateZHeightPositions(double peakY, double baseY) {
    if (kDebugMode) {
      debugPrint('calculateZHeightPositions - Starting calculation');
    }

    final double totalHeight = baseY - peakY;
    
    if (kDebugMode) {
      debugPrint('calculateZHeightPositions - Mountain Peak Y: $peakY');
      debugPrint('calculateZHeightPositions - Mountain Base Y: $baseY');
      debugPrint('calculateZHeightPositions - Total available space: $totalHeight');
      debugPrint('calculateZHeightPositions - Required space: $Z_HEIGHT_TOTAL_REQUIRED_HEIGHT');
    }

    // Check if there's enough space, following C-Height pattern
    if (totalHeight < Z_HEIGHT_TOTAL_REQUIRED_HEIGHT) {
      if (kDebugMode) {
        debugPrint('calculateZHeightPositions - Insufficient space, hiding Z-height marker');
      }
      return {
        'visible': 0.0,
      };
    }

    // Calculate positions relative to the mountain height line, matching C-Height's approach
    final double labelY = peakY + (totalHeight / 2.0) + (Z_HEIGHT_LABEL_HEIGHT / 4.0);
    final double topArrowEnd = labelY - Z_HEIGHT_LABEL_HEIGHT - Z_HEIGHT_LABEL_PADDING;
    final double bottomArrowStart = labelY + Z_HEIGHT_LABEL_PADDING;

    if (kDebugMode) {
      debugPrint('calculateZHeightPositions - Z-height marker is visible');
    }

    return {
      'visible': 1.0,
      'labelY': labelY,
      'topArrowEnd': topArrowEnd,
      'bottomArrowStart': bottomArrowStart,
      'startY': peakY,
      'endY': baseY,
    };
  }
}
