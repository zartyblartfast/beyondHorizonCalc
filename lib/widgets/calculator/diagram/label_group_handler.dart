import 'dart:convert';
import 'package:flutter/services.dart';
import 'svg_element_updater.dart';

/// Handles consistent styling and positioning of label groups in the SVG diagram
class LabelGroupHandler {
  /// Cache for diagram_spec.json content
  static Map<String, dynamic>? _specCache;
  
  /// Initialize the handler by loading configuration
  static Future<void> initialize() async {
    if (_specCache == null) {
      final specString = await rootBundle.loadString('assets/info/diagram_spec.json');
      _specCache = json.decode(specString);
    }
  }

  /// Gets the label styling for a specific group from diagram_spec.json
  static String getLabelStyle(String groupName) {
    if (_specCache == null) {
      throw StateError('LabelGroupHandler not initialized. Call initialize() first.');
    }
    return _specCache!['labelGroups']?[groupName]?['styling']?['label']?['style'] ?? '';
  }

  /// Updates a text element with consistent styling from configuration
  static String updateTextElement(
    String svgContent,
    String elementId,
    Map<String, dynamic> attributes,
    String groupName,
  ) {
    // Get style from configuration
    final configStyle = getLabelStyle(groupName);
    
    // Merge configuration style with any provided style
    final style = attributes['style'] ?? '';
    final mergedStyle = style.isEmpty ? configStyle : '$style;$configStyle';
    
    // Update attributes with merged style
    final updatedAttributes = Map<String, dynamic>.from(attributes);
    updatedAttributes['style'] = mergedStyle;
    
    // Remove standalone text attributes that should be in style
    updatedAttributes.remove('text-anchor');
    updatedAttributes.remove('dominant-baseline');
    
    return SvgElementUpdater.updateTextElementWithStyle(
      svgContent,
      elementId,
      updatedAttributes,
    );
  }
}
