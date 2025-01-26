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
      final originalContent = match.group(2) ?? '';
      final closing = match.group(3) ?? '</text>';
      
      // Only update position attributes, preserve everything else
      if (attributes.containsKey('x')) {
        final xPattern = RegExp(r'x="[^"]*"');
        if (element.contains(xPattern)) {
          element = element.replaceAll(xPattern, 'x="${attributes['x']}"');
        } else {
          element = element + ' x="${attributes['x']}"';
        }
      }
      
      if (attributes.containsKey('y')) {
        final yPattern = RegExp(r'y="[^"]*"');
        if (element.contains(yPattern)) {
          element = element.replaceAll(yPattern, 'y="${attributes['y']}"');
        } else {
          element = element + ' y="${attributes['y']}"';
        }
      }
      
      return element + originalContent + closing;
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
