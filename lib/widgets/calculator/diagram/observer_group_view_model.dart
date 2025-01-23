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
    return {
      'Observer_Height_Label': observerHeight != null ? formatHeight(observerHeight) : '',
      'Visible_Label': 'Visible',
      'Hidden_Label': 'Hidden\nBeyond\nHorizon',
    };
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

  /// Updates all Observer group elements in the SVG
  String updateObserverGroup(String svgContent) {
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

    // Update observer sea level line
    updatedSvg = SvgElementUpdater.updatePathElement(
      updatedSvg,
      'Observer_SL_Line',
      {
        'd': 'M -200,$_seaLevel L 200,$_seaLevel',
      },
    );

    // Update observer dot
    updatedSvg = SvgElementUpdater.updateEllipseElement(
      updatedSvg,
      'dot',
      {
        'cx': '0',
        'cy': observerLevel,
      },
    );

    // Update curvature point line
    updatedSvg = SvgElementUpdater.updatePathElement(
      updatedSvg,
      'C_Point_Line',
      {
        'd': 'M -200,$observerLevel L 200,$observerLevel',
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
    const pointLabelStyle = 'font-family:Calibri, Calibri_MSFontService, sans-serif;font-weight:700;font-size:28.7614px;stroke-width:0.261479';
    const pointLabelBaseAttributes = {
      'style': pointLabelStyle,
      'fill': '#ff0000',
      'dominant-baseline': 'middle', // Center text vertically
    };
    
    // Point label positions relative to C_Point_Line
    final pointLabels = {
      'A': -85.0,
      'B': -65.0,
      'C': -45.0,
    };
    
    // Update all point labels
    pointLabels.forEach((label, xPos) {
      if (kDebugMode) {
        debugPrint('Updating $label label at x=$xPos, y=$observerLevel');
      }
      
      updatedSvg = SvgElementUpdater.updateTextElement(
        updatedSvg,
        label,
        {
          ...pointLabelBaseAttributes,
          'x': '$xPos',
          'y': '$observerLevel',
        },
      );
    });

    // Update visibility labels - positioned relative to C_Point_Line
    const double visibleLabelOffset = 15; // Offset for visible label
    const double hiddenLabelOffset = 25; // Increased offset for hidden label
    
    if (kDebugMode) {
      debugPrint('Updating Visible_Label at y=${observerLevel - visibleLabelOffset}');
    }
    
    updatedSvg = SvgElementUpdater.updateTextElement(
      updatedSvg,
      'Visible_Label',
      {
        'x': '-190',
        'y': '${observerLevel - visibleLabelOffset}',
        'style': 'font-style:normal;font-variant:normal;font-weight:bold;font-stretch:normal;font-size:16px;font-family:Calibri, Calibri_MSFontService, sans-serif;-inkscape-font-specification:\'Calibri, Calibri_MSFontService, sans-serif, Bold\';font-variant-ligatures:normal;font-variant-caps:normal;font-variant-numeric:normal;font-variant-east-asian:normal;fill:#800080;stroke-width:0.261479',
      },
    );

    if (kDebugMode) {
      debugPrint('Updating Hidden_Label at y=${observerLevel + hiddenLabelOffset}');
    }
    
    updatedSvg = SvgElementUpdater.updateTextElement(
      updatedSvg,
      'Hidden_Label',
      {
        'x': '-190',
        'y': '${observerLevel + hiddenLabelOffset}',
        'style': 'font-style:normal;font-variant:normal;font-weight:bold;font-stretch:normal;font-size:16px;font-family:Calibri, Calibri_MSFontService, sans-serif;-inkscape-font-specification:\'Calibri, Calibri_MSFontService, sans-serif, Bold\';font-variant-ligatures:normal;font-variant-caps:normal;font-variant-numeric:normal;font-variant-east-asian:normal;fill:#800080;stroke-width:0.261479',
      },
    );

    // Update Beyond_Label with same offset + 20 units
    updatedSvg = SvgElementUpdater.updateTextElement(
      updatedSvg,
      'Beyond_Label',
      {
        'x': '-190',
        'y': '${observerLevel + hiddenLabelOffset + 20}',
        'style': 'font-style:normal;font-variant:normal;font-weight:bold;font-stretch:normal;font-size:16px;font-family:Calibri, Calibri_MSFontService, sans-serif;-inkscape-font-specification:\'Calibri, Calibri_MSFontService, sans-serif, Bold\';font-variant-ligatures:normal;font-variant-caps:normal;font-variant-numeric:normal;font-variant-east-asian:normal;fill:#800080;stroke-width:0.261479',
      },
    );

    // Update Horizon_Label with same offset + 40 units
    updatedSvg = SvgElementUpdater.updateTextElement(
      updatedSvg,
      'Horizon_Label',
      {
        'x': '-190',
        'y': '${observerLevel + hiddenLabelOffset + 40}',
        'style': 'font-style:normal;font-variant:normal;font-weight:bold;font-stretch:normal;font-size:16px;font-family:Calibri, Calibri_MSFontService, sans-serif;-inkscape-font-specification:\'Calibri, Calibri_MSFontService, sans-serif, Bold\';font-variant-ligatures:normal;font-variant-caps:normal;font-variant-numeric:normal;font-variant-east-asian:normal;fill:#800080;stroke-width:0.261479',
      },
    );

    return updatedSvg;
  }
}
