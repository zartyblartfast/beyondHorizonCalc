import 'package:flutter/foundation.dart';
import '../../../services/models/calculation_result.dart';
import 'diagram_view_model.dart';
import 'svg_element_updater.dart';

/// Handles positioning and scaling for the Observer group elements in the mountain diagram
class ObserverGroupViewModel extends DiagramViewModel {
  // Configuration from diagram_spec.json
  final Map<String, dynamic> config;

  // Coordinate system constants
  late final double _seaLevel;
  late final double _viewboxScale;

  ObserverGroupViewModel({
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
    _seaLevel = _getConfigDouble(['coordinateMapping', 'groups', 'observer', 'seaLevel', 'y']) ?? 500.0;
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

  @override
  Map<String, String> getLabelValues() {
    final observerHeight = result?.h1;
    final Map<String, String> labels = {
      'Observer_Height_Label': observerHeight != null ? formatHeight(observerHeight) : '',
      'Visible_Label': 'Visible',
      'Hidden_Label': 'Hidden\nBeyond\nHorizon',
      'L0': 'Distance (L0): ${formatDistance(result?.inputDistance)}',
    };
    
    if (observerHeight != null) {
      labels['2_2_C_Height'] = 'h1: ${formatHeight(observerHeight)}';
    }
    
    return labels;
  }

  /// Gets the scaled observer height in viewbox units
  double _getScaledObserverHeight() {
    final double observerHeight = result?.h1 ?? 0.0;
    if (kDebugMode) {
      debugPrint('Observer height (m/ft): $observerHeight');
    }
    
    // Convert to km for scaling if using metric
    final heightInKm = isMetric ? observerHeight / 1000.0 : observerHeight / 3280.84;
    if (kDebugMode) {
      debugPrint('Observer height (km): $heightInKm');
    }
    
    // Scale height to viewbox coordinates
    final double scaledHeight = heightInKm * _viewboxScale;
    if (kDebugMode) {
      debugPrint('Scaled height (viewbox units): $scaledHeight');
    }
    
    return scaledHeight;
  }

  /// Gets the current observer level in viewbox coordinates
  double getObserverLevel() {
    final double scaledHeight = _getScaledObserverHeight();
    return _seaLevel - scaledHeight;
  }

  /// Updates the observer label group elements that move with the dot
  String _updateObserverLabelGroup(String svgContent, double observerLevel) {
    var updatedSvg = svgContent;
    
    // Get label group config
    final labelGroup = config['coordinateMapping']?['groups']?['observer']?['labelGroup'];
    if (labelGroup == null) return updatedSvg;

    // Track positions for relative positioning
    final Map<String, Map<String, double>> elementPositions = {};

    // Update each element based on its base point
    for (final element in labelGroup['elements'] ?? []) {
      final id = element['id'];
      final basePoint = element['position']?['basePoint'];
      final offset = element['position']?['offset'];
      
      if (id == null || basePoint == null || offset == null) continue;

      // Calculate position based on base point
      double baseX = 0;
      double baseY = observerLevel;

      // If base point is not dot, get its position from previous element
      if (basePoint != 'dot' && elementPositions.containsKey(basePoint)) {
        baseX = elementPositions[basePoint]!['x']!;
        baseY = elementPositions[basePoint]!['y']!;
      }

      // Apply offset to base position
      final x = baseX + (offset['x']?.toDouble() ?? 0);
      final y = baseY + (offset['y']?.toDouble() ?? 0);

      // Store position for other elements to reference
      elementPositions[id] = {'x': x, 'y': y};

      // Update element based on its type
      switch (element['type']) {
        case 'path':
          // For the arrow, preserve all original attributes and just update position
          final pathD = 'M $x,$y c 20.589574,-19.50955 23.908472,-20.00519 37.348535,-26.01275 10.832606,-4.84205 33.996744,-7.68557 33.996744,-7.68557';
          updatedSvg = SvgElementUpdater.updatePathElement(
            updatedSvg,
            id,
            {
              'd': pathD,
              'style': 'fill:none;stroke:#ff0000;stroke-width:1.55855;stroke-dasharray:none;stroke-opacity:1;marker-start:url(#DartArrow)',
              'sodipodi:nodetypes': 'csc',
            },
          );
          break;

        case 'text':
          if (kDebugMode) {
            print('Updating text element $id at x: $x, y: $y');
          }
          // Use simpler text format without tspans
          final style = id == '4_2_observer_A' 
            ? 'font-style:normal;font-variant:normal;font-weight:bold;font-stretch:normal;font-size:14.1023px;font-family:Calibri, Calibri_MSFontService, sans-serif;-inkscape-font-specification:\'Calibri, Calibri_MSFontService, sans-serif, Bold\';font-variant-ligatures:normal;font-variant-caps:normal;font-variant-numeric:normal;font-variant-east-asian:normal;text-align:start;writing-mode:lr-tb;direction:ltr;text-anchor:start;opacity:0.836237;fill:#ff0000;fill-opacity:1;stroke:#ff0000;stroke-width:0.26064;stroke-dasharray:none'
            : 'font-style:normal;font-variant:normal;font-weight:bold;font-stretch:normal;font-size:16px;font-family:Calibri;-inkscape-font-specification:\'Calibri, Bold\';font-variant-ligatures:normal;font-variant-caps:normal;font-variant-numeric:normal;font-variant-east-asian:normal;fill:#ff0000';
          
          final text = id == '4_2_observer_A' ? 'Observer (A)' : 'Line of Sight (ABC)';
          
          updatedSvg = SvgElementUpdater.updateTextElement(
            updatedSvg,
            id,
            {
              'x': '$x',
              'y': '$y',
              'style': style,
              'text': text,
              'text-anchor': 'middle', // Update text element to use text-anchor for centering
            },
          );
          break;
      }
    }

    return updatedSvg;
  }

  /// Updates the SVG content with current values
  @override
  String updateSvg(String svgContent) {
    var updatedSvg = svgContent;
    
    final double scaledHeight = _getScaledObserverHeight();
    final double observerLevel = _seaLevel - scaledHeight;
    
    // Update observer height line
    updatedSvg = SvgElementUpdater.updatePathElement(
      updatedSvg,
      'Observer_Height_Above_Sea_Level',
      {
        'd': 'M 0,$observerLevel L 0,$_seaLevel',
      },
    );

    // Calculate the height of the vertical line
    final double lineHeight = (_seaLevel - observerLevel).abs();
    
    // Define minimum space needed for h1_label (font size plus padding)
    final double minRequiredSpace = 28.6667; // 18.6667 + 10
    
    // Update h1_label position and visibility based on available space
    final double h1Y = (observerLevel + _seaLevel) / 2; // Calculate midpoint
    updatedSvg = SvgElementUpdater.updateTextElement(
      updatedSvg,
      'h1_label',
      {
        'x': '7.3378983', // Keep existing x coordinate
        'y': '$h1Y',
      },
    );

    // Hide Test_Dot
    updatedSvg = SvgElementUpdater.updateEllipseElement(
      updatedSvg,
      'Test_Dot',
      {
        'visibility': 'hidden',
      },
    );

    // Update observer sea level line
    updatedSvg = SvgElementUpdater.updatePathElement(
      updatedSvg,
      'Observer_SL_Line',
      {
        'd': 'M -275,$_seaLevel L 200,$_seaLevel',
      },
    );

    // Update observer dot
    updatedSvg = SvgElementUpdater.updateCircleElement(
      updatedSvg,
      'dot',
      {
        'cx': '0',
        'cy': '$observerLevel',
      },
    );

    // Update observer label group elements
    updatedSvg = _updateObserverLabelGroup(updatedSvg, observerLevel);

    // Update curvature point line
    updatedSvg = SvgElementUpdater.updatePathElement(
      updatedSvg,
      'C_Point_Line',
      {
        'd': 'M -275,$observerLevel L 200,$observerLevel',
      },
    );

    // Update Beyond_Horizon_Hidden rectangle
    const double diagramBottom = 1000.0; // Bottom of viewBox
    final double hiddenRectHeight = diagramBottom - observerLevel;
    
    if (kDebugMode) {
      debugPrint('Updating Beyond_Horizon_Hidden:');
      debugPrint('  Top (y): $observerLevel');
      debugPrint('  Height: $hiddenRectHeight');
    }
    
    updatedSvg = SvgElementUpdater.updateRectElement(
      updatedSvg,
      'Beyond_Horizon_Hidden',
      {
        'x': '-200',
        'y': '$observerLevel',
        'width': '400',
        'height': '$hiddenRectHeight',
        'style': 'opacity:0.836237;fill:#bdbdbd;fill-opacity:0.980315;fill-rule:evenodd;stroke-width:0.558508',
      },
    );

    // Update A, B, C point labels - vertically centered on C_Point_Line
    final pointLabelBaseAttributes = {
      'style': 'font-style:normal;font-variant:normal;font-weight:bold;font-stretch:normal;font-size:28.7614px;font-family:Calibri, Calibri_MSFontService, sans-serif;-inkscape-font-specification:\'Calibri, Calibri_MSFontService, sans-serif, Bold\';font-variant-ligatures:normal;font-variant-caps:normal;font-variant-numeric:normal;font-variant-east-asian:normal;fill:#ff0000;stroke-width:0.261479',
    };

    // Point label positions relative to C_Point_Line
    final pointLabels = {
      'A': -85,
      'B': -65,
      'C': -47,
    };

    pointLabels.forEach((label, xPos) {
      updatedSvg = SvgElementUpdater.updateTextElement(
        updatedSvg,
        label,
        {
          'x': '$xPos',
          'y': '$observerLevel',
        },
      );
    });

    // Update visibility labels - positioned relative to C_Point_Line
    final visibilityLabelStyle = 'font-weight:bold;font-size:16px;font-family:Calibri;fill:#800080';
    
    // Label positions relative to C_Point_Line
    final visibilityLabels = {
      'label_visible_new': -10, // 10 units above C_Point_Line
      'label_hidden_new': 10,   // 10 units below C_Point_Line
      'label_beyond_new': 30,   // 30 units below C_Point_Line
      'label_horizon_new': 50,  // 50 units below C_Point_Line
    };

    visibilityLabels.forEach((labelId, yOffset) {
      updatedSvg = SvgElementUpdater.updateTextElement(
        updatedSvg,
        labelId,
        {
          'x': '-190',
          'y': '${observerLevel + yOffset}',
          'style': visibilityLabelStyle,
        },
      );
    });

    // Constants for C-height marker
    const double C_HEIGHT_LABEL_HEIGHT = 12.0877;
    const double C_HEIGHT_LABEL_PADDING = 5.0;
    const double C_HEIGHT_MIN_ARROW_LENGTH = 10.0;
    const double C_HEIGHT_TOTAL_REQUIRED_HEIGHT = C_HEIGHT_LABEL_HEIGHT + (2 * C_HEIGHT_LABEL_PADDING) + (2 * C_HEIGHT_MIN_ARROW_LENGTH);

    // Check if there's enough space to display the C-height marker
    bool hasSufficientSpaceForCHeight(double h1) {
      return h1 >= C_HEIGHT_TOTAL_REQUIRED_HEIGHT;
    }

    // Calculate positions for C-height marker elements
    Map<String, double> calculateCHeightPositions(double h1) {
      final double scaledHeight = _getScaledObserverHeight();
      final double observerLevel = _seaLevel - scaledHeight;  // Top of line
      final double seaLevel = _seaLevel;  // Bottom of line
      
      // Check if there's enough space
      if ((seaLevel - observerLevel) < C_HEIGHT_TOTAL_REQUIRED_HEIGHT) {
        return {
          'visible': 0.0,
        };
      }
      
      // Calculate positions relative to the observer height line
      final double labelY = observerLevel + ((seaLevel - observerLevel) / 2.0) + (C_HEIGHT_LABEL_HEIGHT / 4.0);  // Midpoint of line plus half of text height
      final double topArrowEnd = labelY - (C_HEIGHT_LABEL_HEIGHT) - C_HEIGHT_LABEL_PADDING;
      final double bottomArrowStart = labelY + C_HEIGHT_LABEL_PADDING;
      
      return {
        'visible': 1.0,
        'labelY': labelY,
        'topArrowEnd': topArrowEnd,
        'bottomArrowStart': bottomArrowStart,
        'startY': observerLevel,  // Top of line
        'endY': seaLevel,  // Bottom of line
      };
    }

    // Update C-height marker elements
    final observerHeight = result?.h1;
    if (observerHeight != null) {
      final cHeightPositions = calculateCHeightPositions(observerHeight);
      if (cHeightPositions['visible'] == 1.0) {
        const xCoord = -251.08543; // Use exact same x-coordinate for all elements
        
        // Update label with proper centering
        updatedSvg = SvgElementUpdater.updateTextElement(
          updatedSvg,
          '2_2_C_Height',
          {
            'x': '$xCoord',
            'y': '${cHeightPositions['labelY']}',
            'style': 'text-anchor:middle;fill:#552200',
            'visibility': 'visible',
          },
        );
        
        // Update top arrow
        updatedSvg = SvgElementUpdater.updatePathElement(
          updatedSvg,
          '2_1_C_Top_arrow',
          {
            'd': 'M $xCoord,${cHeightPositions['startY']} V ${cHeightPositions['topArrowEnd']}',
            'stroke': '#000000',
            'stroke-width': '1.99598',
            'stroke-dasharray': 'none',
            'stroke-dashoffset': '0',
            'stroke-opacity': '1',
            'visibility': 'visible',
          },
        );
        
        // Update top arrowhead
        updatedSvg = SvgElementUpdater.updatePathElement(
          updatedSvg,
          '2_1_C_Top_arrowhead',
          {
            'd': 'M $xCoord,${cHeightPositions['startY']} l -5,10 l 10,0 z',
            'fill': '#000000',
            'stroke': 'none',
            'fill-opacity': '1',
            'visibility': 'visible',
          },
        );
        
        // Update bottom arrow
        updatedSvg = SvgElementUpdater.updatePathElement(
          updatedSvg,
          '2_3_C_Bottom_arrow',
          {
            'd': 'M $xCoord,${cHeightPositions['bottomArrowStart']} V ${cHeightPositions['endY']}',
            'stroke': '#000000',
            'stroke-width': '2.07704',
            'stroke-dasharray': 'none',
            'stroke-dashoffset': '0',
            'stroke-opacity': '1',
            'visibility': 'visible',
          },
        );

        // Update bottom arrowhead
        updatedSvg = SvgElementUpdater.updatePathElement(
          updatedSvg,
          '2_3_C_Bottom_arrowhead',
          {
            'd': 'M $xCoord,${cHeightPositions['endY']} l -5,-10 l 10,0 z',
            'fill': '#000000',
            'stroke': 'none',
            'fill-opacity': '1',
            'visibility': 'visible',
          },
        );
      } else {
        // Hide all elements if insufficient space
        for (final id in ['2_2_C_Height', '2_1_C_Top_arrow', '2_1_C_Top_arrowhead', '2_3_C_Bottom_arrow', '2_3_C_Bottom_arrowhead']) {
          updatedSvg = SvgElementUpdater.updatePathElement(
            updatedSvg,
            id,
            {'visibility': 'hidden'},
          );
        }
      }
    }

    return updatedSvg;
  }
}
