# Z-Height Implementation Guide

## Overview

This document details the implementation of the Z-Height measurement group (3_*) for measuring the total height of the target mountain. Implementation follows patterns established by the C-Height reference implementation.

## Related Documentation
- [1_measurement_groups_guide.md](1_measurement_groups_guide.md) - Main guide
- [1_1_measurement_config_guide.md](1_1_measurement_config_guide.md) - Configuration patterns
- [1_2_measurement_implementation_guide.md](1_2_measurement_implementation_guide.md) - Implementation details

## Components

The Z-Height measurement consists of five elements:
1. Top arrowhead (3_1_Z_Top_arrowhead)
2. Top arrow (3_1_Z_Top_arrow)
3. Height label (3_2_Z_Height)
4. Bottom arrow (3_3_Z_Bottom_arrow)
5. Bottom arrowhead (3_3_Z_Bottom_arrowhead)

## SVG Element Specifications

### Text Label (3_2_Z_Height)
```css
style="font-style:normal;
       font-variant:normal;
       font-weight:bold;
       font-stretch:normal;
       font-size:12.0877px;
       font-family:Calibri;
       text-align:start;
       fill:#552200"
```

### Top Arrow (3_1_Z_Top_arrow)
```css
stroke="#000000"
stroke-width="1.99598"
stroke-dasharray="none"
stroke-dashoffset="0"
stroke-opacity="1"
```

### Top Arrowhead (3_1_Z_Top_arrowhead)
```css
style="fill:#000000;
       stroke:none;
       fill-opacity:1"
```

## Implementation Details

### Constants
```dart
const double Z_HEIGHT_LABEL_HEIGHT = 12.0877;  // Match C-Height
const double Z_HEIGHT_LABEL_PADDING = 5.0;     // Match C-Height
const double Z_HEIGHT_MIN_ARROW_LENGTH = 10.0; // Match C-Height
const double Z_HEIGHT_TOTAL_REQUIRED_HEIGHT = 
    Z_HEIGHT_LABEL_HEIGHT + 
    (2 * Z_HEIGHT_LABEL_PADDING) + 
    (2 * Z_HEIGHT_MIN_ARROW_LENGTH);
```

### Label Value Handling
```dart
Map<String, String> getZHeightLabelValues() {
  final targetHeight = this.targetHeight;
  if (targetHeight == null) return {};
  
  final prefix = _getConfigString(['labels', 'points', '3_2_Z_Height', 'prefix']) ?? 'XZ: ';
  return {
    '3_2_Z_Height': '$prefix${formatHeight(targetHeight)}'
  };
}
```

### Position Management
```dart
Map<String, double> calculateZHeightPositions() {
  if (kDebugMode) {
    debugPrint('calculateZHeightPositions - Starting calculation');
  }

  final zPointY = getPointY('Z_Point_Line');
  final seaLevelY = getPointY('Distant_Obj_Sea_Level');
  
  if (kDebugMode) {
    debugPrint('calculateZHeightPositions - Z Point Y: $zPointY');
    debugPrint('calculateZHeightPositions - Sea Level Y: $seaLevelY');
    debugPrint('calculateZHeightPositions - Total available space: ${seaLevelY - zPointY}');
    debugPrint('calculateZHeightPositions - Required space: $Z_HEIGHT_TOTAL_REQUIRED_HEIGHT');
  }

  // Check if there's enough space
  if (!hasSufficientSpace(zPointY, seaLevelY)) {
    if (kDebugMode) {
      debugPrint('calculateZHeightPositions - Insufficient space, hiding Z-height marker');
    }
    return {'visible': 0.0};
  }

  // Calculate positions relative to the reference points
  final double labelY = zPointY + ((seaLevelY - zPointY) / 2.0) + (Z_HEIGHT_LABEL_HEIGHT / 4.0);
  final double topArrowEnd = labelY - Z_HEIGHT_LABEL_HEIGHT - Z_HEIGHT_LABEL_PADDING;
  final double bottomArrowStart = labelY + Z_HEIGHT_LABEL_PADDING;

  if (kDebugMode) {
    debugPrint('calculateZHeightPositions - Z-height marker is visible');
    debugPrint('calculateZHeightPositions - Label Y: $labelY');
    debugPrint('calculateZHeightPositions - Top Arrow End: $topArrowEnd');
    debugPrint('calculateZHeightPositions - Bottom Arrow Start: $bottomArrowStart');
  }

  return {
    'visible': 1.0,
    'labelY': labelY,
    'topArrowEnd': topArrowEnd,
    'bottomArrowStart': bottomArrowStart,
    'startY': zPointY,
    'endY': seaLevelY
  };
}
```

### Visibility Control
```dart
bool hasSufficientSpace(double? topY, double? bottomY) {
  if (topY == null || bottomY == null) {
    if (kDebugMode) {
      debugPrint('hasSufficientSpace - Missing reference points');
    }
    return false;
  }
  final space = (bottomY - topY).abs();
  if (kDebugMode) {
    debugPrint('hasSufficientSpace - Available space: $space');
    debugPrint('hasSufficientSpace - Required space: $Z_HEIGHT_TOTAL_REQUIRED_HEIGHT');
  }
  return space >= Z_HEIGHT_TOTAL_REQUIRED_HEIGHT;
}
```

### SVG Updates
```dart
void updateZHeightElements(String svgContent, Map<String, double> positions) {
  var updatedSvg = svgContent;
  const xCoord = -251.08543; // Match C-Height x-coordinate
  const zHeightElements = [
    '3_1_Z_Top_arrow',
    '3_1_Z_Top_arrowhead',
    '3_2_Z_Height',
    '3_3_Z_Bottom_arrow',
    '3_3_Z_Bottom_arrowhead'
  ];

  if (positions['visible'] == 0.0) {
    // Hide Z-height elements if there's not enough space
    for (final elementId in zHeightElements) {
      updatedSvg = SvgElementUpdater.hideElement(updatedSvg, elementId);
    }
    if (kDebugMode) {
      debugPrint('Z-height elements hidden due to insufficient space');
    }
    return;
  }

  // Show and update Z-height elements
  for (final elementId in zHeightElements) {
    updatedSvg = SvgElementUpdater.showElement(updatedSvg, elementId);
  }

  // Update label using LabelGroupHandler for consistent styling
  updatedSvg = LabelGroupHandler.updateTextElement(
    updatedSvg,
    '3_2_Z_Height',
    {
      'x': '$xCoord',
      'y': '${positions['labelY']}',
    },
    'heightMeasurement',  // Use same group as C-height for consistent styling
  );

  // Update top arrow
  updatedSvg = SvgElementUpdater.updatePathElement(
    updatedSvg,
    '3_1_Z_Top_arrow',
    {
      'd': 'M $xCoord,${positions['startY']} V ${positions['topArrowEnd']}',
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
    '3_1_Z_Top_arrowhead',
    {
      'd': 'M $xCoord,${positions['startY']} l -5,10 l 10,0 z',
      'fill': '#000000',
      'fill-opacity': '1',
      'stroke': 'none',
    },
  );

  // Update bottom arrow
  updatedSvg = SvgElementUpdater.updatePathElement(
    updatedSvg,
    '3_3_Z_Bottom_arrow',
    {
      'd': 'M $xCoord,${positions['bottomArrowStart']} V ${positions['endY']}',
      'stroke': '#000000',
      'stroke-width': '1.99598',
      'stroke-dasharray': 'none',
      'stroke-dashoffset': '0',
      'stroke-opacity': '1',
    },
  );

  // Update bottom arrowhead
  updatedSvg = SvgElementUpdater.updatePathElement(
    updatedSvg,
    '3_3_Z_Bottom_arrowhead',
    {
      'd': 'M $xCoord,${positions['endY']} l -5,-10 l 10,0 z',
      'fill': '#000000',
      'fill-opacity': '1',
      'stroke': 'none',
    },
  );

  if (kDebugMode) {
    debugPrint('Z-height elements updated successfully');
    debugPrint('Label position: ${positions['labelY']}');
  }
}
```

## Key Features

1. **Configuration-Driven**
   - Styles defined in JSON
   - Prefix configurable
   - Format rules specified
   - Reference points defined

2. **Consistent Position Management**
   - Direct reference point usage
   - Clear visibility rules
   - Group-based updates
   - Matches C-Height spacing constants

3. **Error Handling**
   - Reference point validation
   - Space validation
   - Comprehensive debug logging

4. **Maintainable Structure**
   - Clear method organization
   - Consistent naming
   - Documented patterns
   - Matches C-Height implementation

## Implementation Steps

1. **Configuration**
   - Use existing JSON configuration
   - Verify style properties match C-Height
   - Confirm content rules
   - Validate reference points

2. **Code Setup**
   - Implement getZHeightLabelValues
   - Add position calculations using reference points
   - Set up visibility checks
   - Match C-Height debug logging

3. **Testing**
   - Verify configuration loading
   - Test position calculations
   - Validate visibility rules
   - Compare with C-Height behavior
