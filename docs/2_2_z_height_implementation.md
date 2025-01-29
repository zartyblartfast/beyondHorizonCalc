# Z-Height Implementation Guide

## Overview

This document details the implementation of the Z-Height measurement group (3_*) for measuring the total height of the target mountain. Implementation follows patterns established by the C-Height reference implementation.

## Related Documentation
- [1_measurement_groups_guide.md](1_measurement_groups_guide.md) - Main guide
- [1_1_measurement_config_guide.md](1_1_measurement_config_guide.md) - Configuration patterns
- [1_2_measurement_implementation_guide.md](1_2_measurement_implementation_guide.md) - Implementation details

## Components

The Z-Height measurement consists of five elements:
1. Top arrowhead (3_1_Z_Height_Top_arrowhead)
2. Top arrow (3_1_Z_Height_Top_arrow)
3. Height label (3_2_Z_Height)
4. Bottom arrow (3_3_Z_Height_Bottom_arrow)
5. Bottom arrowhead (3_3_Z_Height_Bottom_arrowhead)

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

### Top Arrow (3_1_Z_Height_Top_arrow)
```css
stroke="#000000"
stroke-width="1.99598"
```

### Bottom Arrow (3_3_Z_Height_Bottom_arrow)
```css
stroke="#000000"
stroke-width="2.07704"
```

### Arrowheads
```css
/* Both top and bottom arrowheads */
style="fill:#000000;
       stroke:none;
       fill-opacity:1"
```

## Implementation Details

### Fixed Properties
- X-coordinate: 325 for all elements
- Style properties must match original SVG
- All elements treated as single visibility unit
- Part of Mountain layer (uses mountain scaling)

### Dynamic Properties
- Vertical positioning based on reference points:
  - Top elements: Z_Point_Line
  - Bottom elements: Distant_Obj_Sea_Level
  - Label: Z_Point_Line
- Label text format: "XZ: [value]" from Target Height
- Arrow scaling with height changes

### Visibility Rules
- Check space between Z_Point_Line and Distant_Obj_Sea_Level
- No partial display - all elements shown or hidden together

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
  }

  // Check if there's enough space
  if (!hasSufficientSpace(zPointY, seaLevelY)) {
    if (kDebugMode) {
      debugPrint('calculateZHeightPositions - Insufficient space, hiding Z-height marker');
    }
    return {'visible': 0.0};
  }

  if (kDebugMode) {
    debugPrint('calculateZHeightPositions - Z-height marker is visible');
  }

  return {
    'visible': 1.0,
    'top_arrow_y': zPointY,
    'top_arrowhead_y': zPointY,
    'label_y': zPointY,
    'bottom_arrow_y': seaLevelY,
    'bottom_arrowhead_y': seaLevelY
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
  }
  return space >= Z_HEIGHT_MIN_SPACE;
}

void updateVisibility(List<String> elements, bool isVisible) {
  for (final elementId in elements) {
    updatedSvg = isVisible
      ? SvgElementUpdater.showElement(updatedSvg, elementId)
      : SvgElementUpdater.hideElement(updatedSvg, elementId);
  }
}
```

## Key Features

1. **Configuration-Driven**
   - Styles defined in JSON
   - Prefix configurable
   - Format rules specified
   - Reference points defined

2. **Position Management**
   - Direct reference point usage
   - Clear visibility rules
   - Group-based updates

3. **Error Handling**
   - Reference point validation
   - Space validation
   - Debug logging

4. **Maintainable Structure**
   - Clear method organization
   - Consistent naming
   - Documented patterns

## Implementation Steps

1. **Configuration**
   - Use existing JSON configuration
   - Verify style properties
   - Confirm content rules
   - Validate reference points

2. **Code Setup**
   - Implement getZHeightLabelValues
   - Add position calculations using reference points
   - Set up visibility checks
   - Add debug logging

3. **Testing**
   - Verify configuration loading
   - Test position calculations
   - Validate visibility rules
