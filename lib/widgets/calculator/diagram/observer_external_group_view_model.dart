import 'package:flutter/foundation.dart';
import '../../../services/models/calculation_result.dart';
import 'diagram_view_model.dart';
import 'svg_element_updater.dart';
import 'label_group_handler.dart';

/// Handles positioning and scaling for the External Observer group elements in the mountain diagram
class ObserverExternalGroupViewModel extends DiagramViewModel {
  // Configuration from diagram_spec.json
  final Map<String, dynamic> config;
  
  // Coordinate system constants
  late final double _seaLevel;
  late final double _viewboxScale;
  
  // Fixed x-coordinate for all external elements
  static const double _xCoord = -250.0;
  static const double _labelXOffset = -251.08543;  // Centered x position for label

  // Fixed length for external arrows
  static const double EXTERNAL_ARROW_LENGTH = 50.0;
  static const double ARROWHEAD_SIZE = 5.0;  // Size of arrowhead

  // External area positioning
  static const double EXTERNAL_BASE_Y = 100.0;  // Base Y position for external elements
  static const double EXTERNAL_SCALE = 0.1;     // Scale factor for external measurements

  // Define external elements in correct SVG layering order
  static const externalElements = [
    '2e_1_C_Height',           // 1. Label anchored to Top_arrow
    '2e_1_C_Top_arrow',        // 2. Anchored to Top_arrowhead
    '2e_1_C_Top_arrowhead',    // 3. Anchored to C_Point_Line
    '2e_3_C_Bottom_arrowhead', // 4. Anchored to Observer_SL_Line
    '2e_3_C_Bottom_arrow'      // 5. Anchored to Bottom_arrowhead
  ];

  // Constants for C-height marker
  static const double C_HEIGHT_LABEL_HEIGHT = 12.0877;
  static const double C_HEIGHT_LABEL_PADDING = 5.0;
  static const double C_HEIGHT_MIN_ARROW_LENGTH = 10.0;
  static const double C_HEIGHT_TOTAL_REQUIRED_HEIGHT = 
      C_HEIGHT_LABEL_HEIGHT + (2 * C_HEIGHT_LABEL_PADDING) + (2 * C_HEIGHT_MIN_ARROW_LENGTH);

  ObserverExternalGroupViewModel({
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
  ) {
    // Initialize from config with fallback values
    _seaLevel = _getConfigDouble(['coordinateMapping', 'groups', 'observer', 'seaLevel', 'y']) ?? 474.0;
    _viewboxScale = 500 / 18; // Scale factor: 500 viewbox units = 18km
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

  /// Gets a string value from nested config path with fallback
  String? _getConfigString(List<String> path) {
    dynamic value = config;
    for (final key in path) {
      value = value is Map ? value[key] : null;
      if (value == null) return null;
    }
    return value is String ? value : null;
  }

  /// Gets the current observer level in viewbox coordinates
  double getObserverLevel() {
    final double scaledHeight = _getScaledObserverHeight();
    return _seaLevel - scaledHeight;
  }

  /// Gets the scaled observer height in viewbox units
  double _getScaledObserverHeight() {
    final observerHeight = result?.h1;
    if (observerHeight == null) {
      print('[ExternalCHeight] _getScaledObserverHeight - No observer height available');
      return 0.0;
    }
    final scaled = observerHeight * EXTERNAL_SCALE;  // Use external scale
    print('[ExternalCHeight] _getScaledObserverHeight - Height: $observerHeight, Scaled: $scaled');
    return scaled;
  }

  /// Checks if there's enough space for the internal C-height marker
  bool hasInternalSufficientSpace(double h1) {
    final cPointY = _getCPointLineY();  // Y coordinate of C_Point_Line
    final observerSLY = _getObserverSLLineY();  // Y coordinate of Observer_SL_Line
    final availableSpace = (observerSLY - cPointY).abs();  // Space between the lines in viewbox coordinates
    final hasSpace = availableSpace >= C_HEIGHT_TOTAL_REQUIRED_HEIGHT;
    print('[ExternalCHeight] hasInternalSufficientSpace - C_Point_Line Y: $cPointY, Observer_SL_Line Y: $observerSLY, Available Space: $availableSpace, Required: $C_HEIGHT_TOTAL_REQUIRED_HEIGHT, HasSpace: $hasSpace');
    return hasSpace;
  }

  /// Gets Y coordinate of C_Point_Line from the diagram
  double _getCPointLineY() {
    final scaledHeight = _getScaledObserverHeight();
    return _seaLevel - scaledHeight;  // This is where C_Point_Line is
  }

  /// Gets Y coordinate of Observer_SL_Line
  double _getObserverSLLineY() {
    return _seaLevel;  // This is where Observer_SL_Line is
  }

  /// Formats the height label with prefix and units
  String formatHeightLabel(double? height) {
    if (height == null) return '';
    final value = isMetric ? height : height * 3.28084;
    final unit = isMetric ? 'm' : 'ft';
    return 'h1: ${value.toStringAsFixed(1)}$unit';
  }

  /// Calculates positions for C-height marker elements
  Map<String, double> calculateCHeightPositions(double h1) {
    print('[ExternalCHeight] calculateCHeightPositions - Starting with height: $h1');

    // Critical check: Only show external when internal DOESN'T have space
    if (hasInternalSufficientSpace(h1)) {
      print('[ExternalCHeight] calculateCHeightPositions - External hidden (internal has space)');
      return {'visible': 0.0};
    }

    final cPointY = _getCPointLineY();  // Y coordinate of C_Point_Line
    final observerSLY = _getObserverSLLineY();  // Y coordinate of Observer_SL_Line
    
    print('[ExternalCHeight] calculateCHeightPositions - C_Point_Line Y: $cPointY, Observer_SL_Line Y: $observerSLY');
    
    // Position elements relative to the datum lines with fixed offsets
    final double topArrowheadY = cPointY;  // Anchored exactly to C_Point_Line
    final double topArrowY = topArrowheadY - EXTERNAL_ARROW_LENGTH;  // Fixed length above C_Point_Line
    final double labelY = topArrowY - C_HEIGHT_LABEL_HEIGHT/2;  // Centered above top arrow

    final double bottomArrowheadY = observerSLY;  // Anchored exactly to Observer_SL_Line
    final double bottomArrowY = bottomArrowheadY + EXTERNAL_ARROW_LENGTH;  // Fixed length below Observer_SL_Line
    
    print('[ExternalCHeight] calculateCHeightPositions - Positions:');
    print('  Label Y: $labelY');
    print('  Top Arrow Y: $topArrowY');
    print('  Top Arrowhead Y: $topArrowheadY');
    print('  Bottom Arrowhead Y: $bottomArrowheadY');
    print('  Bottom Arrow Y: $bottomArrowY');
    
    return {
      'visible': 1.0,
      'labelY': labelY,
      'topArrowY': topArrowY,
      'topArrowheadY': topArrowheadY,
      'bottomArrowheadY': bottomArrowheadY,
      'bottomArrowY': bottomArrowY
    };
  }

  /// Updates the SVG content without showing external C-Height elements
  String updateSvgWithoutCHeight(String svgContent) {
    var updatedSvg = svgContent;
    
    // Hide all external C-Height elements
    for (final elementId in externalElements) {
      updatedSvg = SvgElementUpdater.hideElement(updatedSvg, elementId);
    }
    
    return updatedSvg;
  }

  /// Updates the SVG content
  String updateSvg(String svgContent) {
    var updatedSvg = svgContent;
    final observerHeight = result?.h1;

    print('[ExternalCHeight] updateSvg - Starting update with height: $observerHeight');

    // Case 1: No height data
    if (observerHeight == null) {
      print('[ExternalCHeight] updateSvg - No height data, hiding elements');
      for (final elementId in externalElements) {
        updatedSvg = SvgElementUpdater.hideElement(updatedSvg, elementId);
      }
      return updatedSvg;
    }

    final positions = calculateCHeightPositions(observerHeight);
    print('[ExternalCHeight] updateSvg - Positions calculated: $positions');
    
    // Case 2: Should be hidden (internal has space or other reason)
    if (positions['visible'] == 0.0) {
      print('[ExternalCHeight] updateSvg - Visibility is 0, hiding elements');
      for (final elementId in externalElements) {
        updatedSvg = SvgElementUpdater.hideElement(updatedSvg, elementId);
      }
      return updatedSvg;
    }

    print('[ExternalCHeight] updateSvg - Updating visible elements');

    // Update label with correct formatting and position
    updatedSvg = SvgElementUpdater.updateTextElement(
      updatedSvg,
      '2e_1_C_Height',
      {
        'x': '$_labelXOffset',
        'y': '${positions['labelY']}',
        'text-anchor': 'middle',
        'dominant-baseline': 'middle',
        'content': formatHeightLabel(observerHeight),
        'style': 'visibility: visible'  // Move visibility into style attribute
      }
    );

    // Update top arrow
    updatedSvg = SvgElementUpdater.updatePathElement(
      updatedSvg,
      '2e_1_C_Top_arrow',
      {
        'd': 'M $_xCoord,${positions['topArrowY']} V ${positions['topArrowheadY']}',
        'visibility': 'visible',
        'stroke': '#000000',
        'stroke-width': '1.99598'
      }
    );

    // Update top arrowhead
    updatedSvg = SvgElementUpdater.updatePathElement(
      updatedSvg,
      '2e_1_C_Top_arrowhead',
      {
        'd': 'M $_xCoord,${positions['topArrowheadY']} l -$ARROWHEAD_SIZE,-${ARROWHEAD_SIZE*2} l ${ARROWHEAD_SIZE*2},0 z',
        'visibility': 'visible',
        'fill': '#000000',
        'stroke': 'none'
      }
    );

    // Update bottom arrow
    updatedSvg = SvgElementUpdater.updatePathElement(
      updatedSvg,
      '2e_3_C_Bottom_arrow',
      {
        'd': 'M $_xCoord,${positions['bottomArrowY']} V ${positions['bottomArrowheadY']}',
        'visibility': 'visible',
        'stroke': '#000000',
        'stroke-width': '1.99598'
      }
    );

    // Update bottom arrowhead
    updatedSvg = SvgElementUpdater.updatePathElement(
      updatedSvg,
      '2e_3_C_Bottom_arrowhead',
      {
        'd': 'M $_xCoord,${positions['bottomArrowheadY']} l -$ARROWHEAD_SIZE,${ARROWHEAD_SIZE*2} l ${ARROWHEAD_SIZE*2},0 z',
        'visibility': 'visible',
        'fill': '#000000',
        'stroke': 'none'
      }
    );

    return updatedSvg;
  }

  /// Gets all label values for the external observer group
  @override
  Map<String, String> getLabelValues() {
    // External C-Height uses same label as internal, so no additional labels needed
    return {};
  }
}
