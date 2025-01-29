import 'package:flutter/foundation.dart';

/// Helper class to update SVG elements while preserving other attributes
class SvgElementUpdater {
  /// Updates line element attributes while preserving style and other attributes
  static String updateLineElement(String svgContent, String elementId, Map<String, dynamic> attributes) {
    // Find the line element with the given ID or inkscape:label
    final RegExp elementPattern = RegExp(
      r'(<line[^>]*?(?:id|inkscape:label)="' + elementId + r'"[^>]*?)(/>|>)',
      multiLine: true,
      dotAll: true,
    );
    
    if (kDebugMode) {
      debugPrint('Searching for line element with pattern: ${elementPattern.pattern}');
      
      // Find element with this ID or label
      final idPattern = RegExp('(?:id|inkscape:label)="$elementId"');
      final idMatch = idPattern.firstMatch(svgContent);
      if (idMatch != null) {
        // Get surrounding context
        final start = idMatch.start - 50;
        final end = idMatch.end + 50;
        debugPrint('Found element in context: ${svgContent.substring(start < 0 ? 0 : start, end > svgContent.length ? svgContent.length : end)}');
      }
    }

    // Update attributes while preserving others
    return svgContent.replaceFirstMapped(elementPattern, (match) {
      var element = match.group(1) ?? '';
      final closing = match.group(2) ?? '/>';
      
      if (kDebugMode) {
        debugPrint('Found line element: $element');
      }
      
      attributes.forEach((key, value) {
        final attributePattern = RegExp('$key="[^"]*"');
        if (element.contains(attributePattern)) {
          element = element.replaceAll(attributePattern, '$key="$value"');
        } else {
          element = element + ' $key="$value"';
        }
      });
      
      if (kDebugMode) {
        debugPrint('Updated line element: $element$closing');
      }
      return element + closing;
    });
  }

  /// Updates path element attributes while preserving style and other attributes
  static String updatePathElement(String svgContent, String elementId, Map<String, dynamic> attributes) {
    // Find the path element with the given ID or inkscape:label
    final RegExp elementPattern = RegExp(
      r'(<path[^>]*?(?:id|inkscape:label)="' + elementId + r'"[^>]*?)(/>|>)',
      multiLine: true,
      dotAll: true,
    );
    
    if (kDebugMode) {
      debugPrint('Searching for path element with pattern: ${elementPattern.pattern}');
      
      // Find element with this ID or label
      final idPattern = RegExp('(?:id|inkscape:label)="$elementId"');
      final idMatch = idPattern.firstMatch(svgContent);
      if (idMatch != null) {
        // Get surrounding context
        final start = idMatch.start - 50;
        final end = idMatch.end + 50;
        debugPrint('Found element in context: ${svgContent.substring(start < 0 ? 0 : start, end > svgContent.length ? svgContent.length : end)}');
      }
    }

    // Update attributes while preserving others
    return svgContent.replaceFirstMapped(elementPattern, (match) {
      var element = match.group(1) ?? '';
      final closing = match.group(2) ?? '/>';
      
      if (kDebugMode) {
        debugPrint('Found path element: $element');
      }
      
      attributes.forEach((key, value) {
        final attributePattern = RegExp('$key="[^"]*"');
        if (element.contains(attributePattern)) {
          element = element.replaceAll(attributePattern, '$key="$value"');
        } else {
          element = element + ' $key="$value"';
        }
      });
      
      if (kDebugMode) {
        debugPrint('Updated path element: $element$closing');
      }
      return element + closing;
    });
  }

  /// Updates ellipse element attributes while preserving style and other attributes
  static String updateEllipseElement(String svgContent, String elementId, Map<String, dynamic> attributes) {
    // Find the ellipse element with the given ID or inkscape:label
    final RegExp elementPattern = RegExp(
      r'(<ellipse[^>]*?(?:id|inkscape:label)="' + elementId + r'"[^>]*?)(/>|>)',
      multiLine: true,
      dotAll: true,
    );

    // Update attributes while preserving others
    return svgContent.replaceFirstMapped(elementPattern, (match) {
      var element = match.group(1) ?? '';
      final closing = match.group(2) ?? '/>';
      
      attributes.forEach((key, value) {
        final attributePattern = RegExp('$key="[^"]*"');
        if (element.contains(attributePattern)) {
          element = element.replaceAll(attributePattern, '$key="$value"');
        } else {
          element = element + ' $key="$value"';
        }
      });
      
      return element + closing;
    });
  }

  /// Updates circle element attributes while preserving style and other attributes
  static String updateCircleElement(String svgContent, String elementId, Map<String, dynamic> attributes) {
    // Find the circle element with the given ID or inkscape:label
    final RegExp elementPattern = RegExp(
      r'(<circle[^>]*?(?:id|inkscape:label)="' + elementId + r'"[^>]*?)(/>|>)',
      multiLine: true,
      dotAll: true,
    );
    
    if (kDebugMode) {
      debugPrint('Searching for circle element with pattern: ${elementPattern.pattern}');
      
      // Find element with this ID or label
      final idPattern = RegExp('(?:id|inkscape:label)="$elementId"');
      final idMatch = idPattern.firstMatch(svgContent);
      if (idMatch != null) {
        // Get surrounding context
        final start = idMatch.start - 50;
        final end = idMatch.end + 50;
        debugPrint('Found element in context: ${svgContent.substring(start < 0 ? 0 : start, end > svgContent.length ? svgContent.length : end)}');
      }
    }

    // Update attributes while preserving others
    return svgContent.replaceFirstMapped(elementPattern, (match) {
      var element = match.group(1) ?? '';
      final closing = match.group(2) ?? '/>';
      
      if (kDebugMode) {
        debugPrint('Found circle element: $element');
      }
      
      attributes.forEach((key, value) {
        final attributePattern = RegExp('$key="[^"]*"');
        if (element.contains(attributePattern)) {
          element = element.replaceAll(attributePattern, '$key="$value"');
        } else {
          element = element + ' $key="$value"';
        }
      });
      
      if (kDebugMode) {
        debugPrint('Updated circle element: $element$closing');
      }
      return element + closing;
    });
  }

  /// Updates text element attributes while preserving style and other attributes
  static String updateTextElement(String svgContent, String elementId, Map<String, dynamic> attributes) {
    // Find the text element with the given ID or inkscape:label
    final RegExp elementPattern = RegExp(
      r'(<text[^>]*?(?:id|inkscape:label)="' + elementId + r'"[^>]*?>)(.*?)(</text>)',
      multiLine: true,
      dotAll: true,
    );

    // Update attributes while preserving others
    return svgContent.replaceFirstMapped(elementPattern, (match) {
      var element = match.group(1) ?? '';
      var content = match.group(2) ?? '';
      final closing = match.group(3) ?? '</text>';

      // Update content if provided
      if (attributes.containsKey('content')) {
        content = attributes['content'];
        attributes.remove('content');
      }
      
      // Extract style-related attributes
      final styleAttributes = <String, String>{};
      final standardAttributes = <String, String>{};
      
      attributes.forEach((key, value) {
        // These attributes should be part of the style string
        if (['text-anchor', 'dominant-baseline', 'font-style', 'font-variant', 
             'font-weight', 'font-stretch', 'font-size', 'font-family', 
             'text-align', 'fill'].contains(key)) {
          styleAttributes[key] = value.toString();
        } else {
          standardAttributes[key] = value.toString();
        }
      });

      // Update style attribute
      if (styleAttributes.isNotEmpty) {
        final stylePattern = RegExp(r'style="[^"]*"');
        final styleString = styleAttributes.entries
            .map((e) => '${e.key}:${e.value}')
            .join(';');
            
        if (element.contains(stylePattern)) {
          // Extract existing style
          final match = stylePattern.firstMatch(element);
          if (match != null) {
            final existingStyle = element.substring(match.start + 7, match.end - 1);
            // Merge existing style with new style
            final mergedStyle = _mergeStyles(existingStyle, styleString);
            element = element.replaceAll(stylePattern, 'style="$mergedStyle"');
          }
        } else {
          element = element + ' style="$styleString"';
        }
      }
      
      // Update remaining standard attributes
      standardAttributes.forEach((key, value) {
        final attributePattern = RegExp('$key="[^"]*"');
        if (element.contains(attributePattern)) {
          element = element.replaceAll(attributePattern, '$key="$value"');
        } else {
          element = element + ' $key="$value"';
        }
      });
      
      return element + content + closing;
    });
  }

  /// Merges two style strings, with new styles taking precedence
  static String _mergeStyles(String existingStyle, String newStyle) {
    final styles = <String, String>{};
    
    // Parse existing styles
    for (final style in existingStyle.split(';')) {
      if (style.trim().isNotEmpty) {
        final parts = style.split(':');
        if (parts.length == 2) {
          styles[parts[0].trim()] = parts[1].trim();
        }
      }
    }
    
    // Parse and merge new styles
    for (final style in newStyle.split(';')) {
      if (style.trim().isNotEmpty) {
        final parts = style.split(':');
        if (parts.length == 2) {
          styles[parts[0].trim()] = parts[1].trim();
        }
      }
    }
    
    // Combine all styles
    return styles.entries
        .map((e) => '${e.key}:${e.value}')
        .join(';');
  }

  /// Updates rect element attributes while preserving style and other attributes
  static String updateRectElement(String svgContent, String elementId, Map<String, dynamic> attributes) {
    // Find the rect element with the given ID or inkscape:label
    final RegExp elementPattern = RegExp(
      r'(<rect[^>]*?(?:id|inkscape:label)="' + elementId + r'"[^>]*?>)',
      multiLine: true,
      dotAll: true,
    );
    
    if (kDebugMode) {
      debugPrint('Searching for rect element with pattern: ${elementPattern.pattern}');
    }

    // Update attributes while preserving others
    return svgContent.replaceFirstMapped(elementPattern, (match) {
      var element = match.group(1) ?? '';
      
      if (kDebugMode) {
        debugPrint('Found rect element: $element');
      }
      
      // Update rect element attributes
      attributes.forEach((key, value) {
        final attributePattern = RegExp('$key="[^"]*"');
        if (element.contains(attributePattern)) {
          element = element.replaceAll(attributePattern, '$key="$value"');
        } else {
          element = element.substring(0, element.length - 1) + ' $key="$value">';
        }
      });
      
      if (kDebugMode) {
        debugPrint('Updated rect element: $element');
      }
      return element;
    });
  }

  /// Helper method to merge two style strings, preserving existing styles unless overridden
  static String _mergeStyles(String existingStyle, String newStyle) {
    final styles = <String, String>{};
    
    // Parse existing styles
    for (final style in existingStyle.split(';')) {
      if (style.trim().isNotEmpty) {
        final parts = style.split(':');
        if (parts.length == 2) {
          styles[parts[0].trim()] = parts[1].trim();
        }
      }
    }
    
    // Parse and merge new styles
    for (final style in newStyle.split(';')) {
      if (style.trim().isNotEmpty) {
        final parts = style.split(':');
        if (parts.length == 2) {
          styles[parts[0].trim()] = parts[1].trim();
        }
      }
    }
    
    // Combine all styles
    return styles.entries
        .map((e) => '${e.key}:${e.value}')
        .join(';');
  }

  /// Helper method to extract and combine style attributes
  static Map<String, String> _extractStyleAttributes(Map<String, dynamic> attributes) {
    final styleAttributes = <String, String>{};
    final toRemove = <String>[];

    attributes.forEach((key, value) {
      if ([
        'text-anchor',
        'dominant-baseline',
        'font-style',
        'font-variant',
        'font-weight',
        'font-stretch',
        'font-size',
        'font-family',
        'text-align',
        'fill',
        'fill-opacity',
        'stroke',
        'stroke-width',
        'stroke-opacity'
      ].contains(key)) {
        styleAttributes[key] = value.toString();
        toRemove.add(key);
      }
    });

    // Remove the style attributes from the original map
    toRemove.forEach(attributes.remove);

    return styleAttributes;
  }

  /// Safely updates an element's style attribute by merging with existing styles
  static String _updateElementStyle(String element, String newStyleString) {
    final stylePattern = RegExp(r'style="[^"]*"');
    final match = stylePattern.firstMatch(element);
    
    if (match != null) {
      final existingStyle = element.substring(match.start + 7, match.end - 1);
      final mergedStyle = _mergeStyles(existingStyle, newStyleString);
      return element.replaceAll(stylePattern, 'style="$mergedStyle"');
    } else {
      return element + ' style="$newStyleString"';
    }
  }

  /// Hides an SVG element by setting its display style to 'none'
  static String hideElement(String svgContent, String elementId) {
    // Find any SVG element with the given ID or inkscape:label
    final RegExp elementPattern = RegExp(
      r'(<[^>]*?(?:id|inkscape:label)="' + elementId + r'"[^>]*?)(/>|>)',
      multiLine: true,
      dotAll: true,
    );

    // Update style to hide element
    return svgContent.replaceFirstMapped(elementPattern, (match) {
      var element = match.group(1) ?? '';
      final closing = match.group(2) ?? '/>';
      
      element = _updateElementStyle(element, 'display:none');
      
      return element + closing;
    });
  }

  /// Shows a previously hidden SVG element by removing display:none
  static String showElement(String svgContent, String elementId) {
    // Find any SVG element with the given ID or inkscape:label
    final RegExp elementPattern = RegExp(
      r'(<[^>]*?(?:id|inkscape:label)="' + elementId + r'"[^>]*?)(/>|>)',
      multiLine: true,
      dotAll: true,
    );

    // Update style to show element
    return svgContent.replaceFirstMapped(elementPattern, (match) {
      var element = match.group(1) ?? '';
      final closing = match.group(2) ?? '/>';
      
      final stylePattern = RegExp(r'style="[^"]*"');
      final match = stylePattern.firstMatch(element);
      
      if (match != null) {
        final existingStyle = element.substring(match.start + 7, match.end - 1);
        final styles = existingStyle.split(';')
            .where((s) => !s.trim().startsWith('display:'))
            .join(';');
        element = element.replaceAll(stylePattern, 'style="$styles"');
      }
      
      return element + closing;
    });
  }

  /// New method for updating text elements with proper style handling
  /// This method will be used in the next phase, keeping existing updateTextElement unchanged
  static String updateTextElementWithStyle(String svgContent, String elementId, Map<String, dynamic> attributes) {
    // Find the text element with the given ID or inkscape:label
    final RegExp elementPattern = RegExp(
      r'(<text[^>]*?(?:id|inkscape:label)="' + elementId + r'"[^>]*?>)(.*?)(</text>)',
      multiLine: true,
      dotAll: true,
    );

    // Update attributes while preserving others
    return svgContent.replaceFirstMapped(elementPattern, (match) {
      var element = match.group(1) ?? '';
      var content = match.group(2) ?? '';
      final closing = match.group(3) ?? '</text>';

      // Extract content if provided
      if (attributes.containsKey('content')) {
        content = attributes['content'];
        attributes.remove('content');
      }
      
      // Extract and combine style attributes
      final styleAttributes = _extractStyleAttributes(attributes);
      if (styleAttributes.isNotEmpty) {
        final styleString = styleAttributes.entries
            .map((e) => '${e.key}:${e.value}')
            .join(';');
        element = _updateElementStyle(element, styleString);
      }
      
      // Update remaining standard attributes
      attributes.forEach((key, value) {
        final attributePattern = RegExp('$key="[^"]*"');
        if (element.contains(attributePattern)) {
          element = element.replaceAll(attributePattern, '$key="$value"');
        } else {
          element = element + ' $key="$value"';
        }
      });
      
      return element + content + closing;
    });
  }
}
