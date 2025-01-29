# Z-Height Implementation Guide

## Overview

This document details the implementation of the Z-Height measurement group (3_*) for measuring the total height of the target mountain. Implementation follows patterns established by the C-Height reference implementation.

## Related Documentation
- [1_measurement_groups_guide.md](1_measurement_groups_guide.md) - Main guide
- [2_1_c_height_implementation.md](2_1_c_height_implementation.md) - Reference implementation
- [1_1_measurement_config_guide.md](1_1_measurement_config_guide.md) - Configuration patterns

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

/* Top arrowhead path */
d="m 320,${y} -5,-10 h 10 z"  // Points upward

/* Bottom arrowhead path */
d="m 320,${y} -5,10 h 10 z"   // Points downward
```

## Implementation Details

### Fixed Properties
- X-coordinate: 325 for all elements
- Style properties must match original SVG
- All elements treated as single visibility unit
- Part of Mountain layer (uses mountain scaling)

### Dynamic Properties
- Vertical positioning based on Target Height (XZ)
- Label text format: "XZ: [value]"
- Arrow scaling with height changes
- Reference points: Z_Point_Line (top) and Distant_Obj_Sea_Level (bottom)

### Coordinate System
- Y-axis: 0 at top, 1000 at bottom
- Mountain layer range: 474-1000
- Larger Y value = lower position
- Height calculations: |bottom.y - top.y|
- Available space: |Distant_Obj_Sea_Level.y - Z_Point_Line.y|

### Scaling
```dart
// Mountain group scaling
static const double _viewboxScale = 600 / 18;  // 600 viewbox units = 18km

// Height conversion
double heightInKm = isMetric ? targetHeight / 1000.0 : targetHeight / 3280.84;
double scaledHeight = heightInKm * _viewboxScale;
```

## Code Integration

### MountainGroupViewModel Integration
```dart
class MountainGroupViewModel extends DiagramViewModel {
  // Get Z-Height label values
  @override
  Map<String, String> getLabelValues() {
    final targetHeight = this.targetHeight;
    if (targetHeight != null) {
      final prefix = _getConfigString(['labels', 'points', '3_2_Z_Height', 'prefix']) ?? 'XZ: ';
      labels['3_2_Z_Height'] = '$prefix${formatHeight(targetHeight)}';
    }
    return labels;
  }

  // Calculate Z-Height positions
  Map<String, double> calculateZHeightPositions() {
    if (!hasSufficientSpaceForZHeight()) {
      return {'visible': 0.0};
    }

    final zPointY = getZPointY();
    final seaLevelY = getDistantObjSeaLevelY();
    
    return {
      'visible': 1.0,
      'topArrowY': zPointY,
      'labelY': calculateZHeightLabelY(zPointY, seaLevelY),
      'bottomArrowY': seaLevelY
    };
  }

  // Check available space
  bool hasSufficientSpaceForZHeight() {
    final zPointY = getZPointY();
    final seaLevelY = getDistantObjSeaLevelY();
    final availableSpace = seaLevelY - zPointY;
    
    return availableSpace >= 75.0;  // Minimum required height
  }

  // Update Z-Height elements
  void updateZHeightGroup(String svgContent) {
    final positions = calculateZHeightPositions();
    
    if (kDebugMode) {
      debugPrint('\nZ-Height Group Validation:');
      debugPrint('1. Input Values:');
      debugPrint('  - Target Height (XZ): ${targetHeight ?? 0.0} ${isMetric ? 'm' : 'ft'}');
      debugPrint('  - Z Point Y: ${positions['topArrowY']}');
      debugPrint('  - Sea Level Y: ${positions['bottomArrowY']}');
      debugPrint('  - Available Space: ${positions['bottomArrowY']! - positions['topArrowY']!}');
    }

    // Update visibility
    final isVisible = positions['visible'] == 1.0;
    final elements = [
      '3_1_Z_Height_Top_arrowhead',
      '3_1_Z_Height_Top_arrow',
      '3_2_Z_Height',
      '3_3_Z_Height_Bottom_arrow',
      '3_3_Z_Height_Bottom_arrowhead'
    ];
    
    for (final elementId in elements) {
      updatedSvg = isVisible
        ? SvgElementUpdater.showElement(updatedSvg, elementId)
        : SvgElementUpdater.hideElement(updatedSvg, elementId);
    }

    // Update positions if visible
    if (isVisible) {
      // Update arrows and arrowheads
      // Top section
      updatedSvg = SvgElementUpdater.updateElement(
        updatedSvg,
        '3_1_Z_Height_Top_arrow',
        {'y': '${positions['topArrowY']}'}
      );
      updatedSvg = SvgElementUpdater.updateElement(
        updatedSvg,
        '3_1_Z_Height_Top_arrowhead',
        {'y': '${positions['topArrowY']}'}
      );

      // Label
      updatedSvg = LabelGroupHandler.updateTextElement(
        updatedSvg,
        '3_2_Z_Height',
        {
          'x': '325',
          'y': '${positions['labelY']}',
        },
        'heightMeasurement'
      );

      // Bottom section
      updatedSvg = SvgElementUpdater.updateElement(
        updatedSvg,
        '3_3_Z_Height_Bottom_arrow',
        {'y': '${positions['bottomArrowY']}'}
      );
      updatedSvg = SvgElementUpdater.updateElement(
        updatedSvg,
        '3_3_Z_Height_Bottom_arrowhead',
        {'y': '${positions['bottomArrowY']}'}
      );
    }
  }
}
```

## Configuration

### JSON Configuration (diagram_spec.json)
```json
{
  "id": "z_height_marker",
  "type": "group",
  "elements": [
    {
      "id": "3_1_Z_Height_Top_arrowhead",
      "type": "path",
      "behavior": "dynamic",
      "style": {
        "fill": "#000000",
        "stroke": "none",
        "fillOpacity": 1
      },
      "position": {
        "x": 325,
        "y": {
          "reference": "Target Height",
          "visibility": "dependent"
        }
      }
    },
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
  ],
  "visibility": {
    "condition": "sufficient_space",
    "minimumSpace": "TOTAL_REQUIRED_HEIGHT",
    "behavior": "all_or_none"
  }
}
```

## Debug Support

Debug output includes:
1. Input validation
   - Target Height value and units
   - Reference point positions
2. Scaling verification
   - Viewbox scale factor
   - Converted heights
3. Position validation
   - Z_Point_Line position
   - Distant_Obj_Sea_Level position
   - Available space calculation
4. Visibility decisions
   - Space requirements
   - Visibility state changes

## Error Handling

1. Missing reference points
   ```dart
   if (zPointY == null || seaLevelY == null) {
     debugPrint('Error: Missing reference points for Z-Height measurement');
     return {'visible': 0.0};
   }
   ```

2. Invalid scaling
   ```dart
   if (targetHeight != null && (targetHeight <= 0 || targetHeight > 9000)) {
     debugPrint('Error: Target height out of valid range');
     return {'visible': 0.0};
   }
   ```

3. Insufficient space
   ```dart
   if (availableSpace < MINIMUM_REQUIRED_HEIGHT) {
     debugPrint('Warning: Insufficient space for Z-Height display');
     debugPrint('Required: $MINIMUM_REQUIRED_HEIGHT, Available: $availableSpace');
     return {'visible': 0.0};
   }
   ```
