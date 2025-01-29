# Z-Height Implementation Guide

## Overview

This document details the implementation of the Z-Height measurement group (3_*) for measuring the total height of the target mountain. Implementation follows patterns established by the C-Height reference implementation.

## Related Documentation
- [1_measurement_groups_guide.md](1_measurement_groups_guide.md) - Main guide
- [2_1_c_height_implementation.md](2_1_c_height_implementation.md) - Reference implementation
- [1_1_measurement_config_guide.md](1_1_measurement_config_guide.md) - Configuration patterns

## Core Files

1. **Configuration**
   - `assets/info/diagram_spec.json` - Group and element definitions
   - `assets/svg/BTH_viewBox_diagram2.svg` - SVG source file

2. **Implementation**
   - `lib/widgets/calculator/diagram/mountain_group_view_model.dart` - Core view model
   - `lib/widgets/calculator/diagram/diagram_label_service.dart` - Label handling
   - `lib/widgets/calculator/diagram/svg_element_updater.dart` - SVG updates

## Components

The Z-Height measurement consists of five elements in fixed vertical order:
1. Top arrowhead (3_1_Z_Height_Top_arrowhead) - pointing upward
2. Top arrow (3_1_Z_Height_Top_arrow)
3. Height label (3_2_Z_Height)
4. Bottom arrow (3_3_Z_Height_Bottom_arrow)
5. Bottom arrowhead (3_3_Z_Height_Bottom_arrowhead) - pointing downward

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

### Arrows
```css
/* Top Arrow (3_1_Z_Height_Top_arrow) */
stroke="#000000"
stroke-width="1.99598"

/* Bottom Arrow (3_3_Z_Height_Bottom_arrow) */
stroke="#000000"
stroke-width="2.07704"
```

### Arrowheads
```css
/* Both arrowheads */
style="fill:#000000;stroke:none;fill-opacity:1"
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
- Minimum space requirement: 75 units
- No partial display - all elements shown or hidden together

## Configuration

### JSON Configuration
```json
{
  "id": "3_2_Z_Height",
  "type": "text",
  "style": {
    "fontFamily": "Calibri",
    "fontSize": "12.0877px",
    "fontWeight": "bold",
    "fill": "#552200",
    "textAnchor": "middle"
  },
  "content": {
    "prefix": "XZ: ",
    "value": {
      "source": "Target Height",
      "format": {
        "type": "distance",
        "decimalPlaces": 1,
        "includeUnits": true
      }
    }
  }
}
```

## Implementation

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
  final zPointY = getPointY('Z_Point_Line');
  final seaLevelY = getPointY('Distant_Obj_Sea_Level');
  
  if (!hasSufficientSpace(zPointY, seaLevelY)) {
    return {'visible': 0.0};
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
bool hasSufficientSpaceForZHeight(double? topY, double? bottomY) {
  if (topY == null || bottomY == null) return false;
  return (bottomY - topY).abs() >= Z_HEIGHT_MIN_SPACE;
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

2. **Consistent Position Management**
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
   - Add JSON configuration
   - Define style properties
   - Set content rules
   - Configure reference points

2. **Code Setup**
   - Implement getZHeightLabelValues
   - Add position calculations using reference points
   - Set up visibility checks

3. **Testing**
   - Test configuration loading
   - Verify position calculations
   - Check visibility rules
   - Validate reference point handling

## Best Practices

1. **Configuration First**
   - Always prefer JSON configuration
   - Minimize hardcoded values
   - Document configuration structure

2. **Group Operations**
   - Update elements as a group
   - Maintain consistent visibility
   - Use shared styling

3. **Error Prevention**
   - Validate reference points
   - Provide fallbacks
   - Log important state changes

## Debug Support

Debug output includes:
1. Input validation
   - Target Height value and units
   - Reference point positions
2. Position validation
   - Z_Point_Line position
   - Distant_Obj_Sea_Level position
   - Available space calculation
3. Visibility decisions
   - Space requirements
   - Visibility state changes

## Testing Requirements

1. **Configuration Tests**
   - JSON validation
   - Style verification
   - Reference point validation

2. **Functional Tests**
   - Position calculations
   - Visibility management
   - Label formatting
   - Error handling

3. **Integration Tests**
   - Different mountain heights
   - Various diagram scales
   - Edge cases
   - Label formatting variations

4. **Visual Verification**
   - Element alignment
   - Style consistency
   - Visibility transitions
   - Label positioning
