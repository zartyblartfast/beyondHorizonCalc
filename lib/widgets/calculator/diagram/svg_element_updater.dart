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

  /// Updates text element attributes while preserving style and other attributes
  static String updateTextElement(String svgContent, String elementId, Map<String, dynamic> attributes) {
    // Find the text element with the given ID or inkscape:label
    final RegExp elementPattern = RegExp(
      r'(<text[^>]*?(?:id|inkscape:label)="' + elementId + r'"[^>]*?>)(.*?</text>)',
      multiLine: true,
      dotAll: true,
    );
    
    if (kDebugMode) {
      debugPrint('Searching for text element with pattern: ${elementPattern.pattern}');
      debugPrint('Attributes to update: $attributes');
    }

    // Update attributes while preserving others and text content
    return svgContent.replaceFirstMapped(elementPattern, (match) {
      var element = match.group(1) ?? '';
      var textContent = match.group(2) ?? '';
      
      if (kDebugMode) {
        debugPrint('Found text element: $element');
        debugPrint('Text content: $textContent');
      }
      
      // Remove any transform attributes that might affect positioning
      element = element.replaceAll(RegExp(r'transform="[^"]*"'), '');
      
      // Update text element attributes
      attributes.forEach((key, value) {
        if (key != 'y' || !textContent.contains('<tspan')) { // Only update y if not using tspans
          final attributePattern = RegExp('$key="[^"]*"');
          if (element.contains(attributePattern)) {
            element = element.replaceAll(attributePattern, '$key="$value"');
          } else {
            element = element.substring(0, element.length - 1) + ' $key="$value">';
          }
        }
      });

      // Update tspan positions if tspans exist
      if (textContent.contains('<tspan')) {
        // Find all tspans and update their positions
        final tspanPattern = RegExp(r'(<tspan[^>]*?)(?:x|y)="[^"]*"([^>]*?>)');
        
        if (attributes.containsKey('tspan')) {
          final tspanAttrs = attributes['tspan'] as Map<String, dynamic>;
          textContent = textContent.replaceAllMapped(tspanPattern, (tspanMatch) {
            var tspanElement = tspanMatch.group(1) ?? '';
            final closing = tspanMatch.group(2) ?? '>';
            
            tspanAttrs.forEach((key, value) {
              final attributePattern = RegExp('$key="[^"]*"');
              if (tspanElement.contains(attributePattern)) {
                tspanElement = tspanElement.replaceAll(attributePattern, '$key="$value"');
              } else {
                tspanElement = '$tspanElement $key="$value"';
              }
            });
            
            return '$tspanElement$closing';
          });
        }
      }
      
      if (kDebugMode) {
        debugPrint('Updated text element: $element$textContent');
      }
      return element + textContent;
    });
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
}
