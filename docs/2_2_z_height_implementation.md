# Z-Height Implementation Guide

## Overview
The Z-Height measurement group displays the target height (XZ) value in the diagram. This guide documents the implementation details and key lessons learned to ensure consistency with other measurement groups like C-Height.

## Key Components

### 1. Configuration in diagram_spec.json
```json
{
  "labels": {
    "points": [
      {
        "id": "3_2_Z_Height",
        "type": "text",
        "prefix": "XZ: "
      }
    ]
  }
}
```

### 2. SVG Element
- ID must match exactly: `3_2_Z_Height`
- Element should be a text element in the SVG
- Initial content can be empty or placeholder

### 3. Value Source
In `MountainGroupViewModel`:
```dart
@override
Map<String, String> getLabelValues() {
  final Map<String, String> labels = {};
  
  // IMPORTANT: Use targetHeight directly - it's already in correct units
  if (targetHeight != null) {
    final prefix = _getConfigString(['labels', 'points', '3_2_Z_Height', 'prefix']) ?? 'XZ: ';
    labels['3_2_Z_Height'] = '$prefix${formatHeight(targetHeight!)}';
  }
  
  return labels;
}
```

## Critical Implementation Points

1. **Value Source**
   - Use `targetHeight` directly from the view model
   - Do NOT use `result.visibleTargetHeight` - this is for visible portion calculations
   - `targetHeight` is already in correct units (meters/feet) - no conversion needed

2. **Label Integration**
   - Ensure `MountainDiagramViewModel.getLabelValues()` includes mountain group labels:
   ```dart
   return {
     // ... other labels ...
     ..._mountainGroup.getLabelValues(),
   };
   ```

3. **Configuration Path**
   - Follow existing pattern for label configuration
   - Use consistent ID format: `3_2_Z_Height`
   - Include prefix in configuration

4. **Unit Handling**
   - Input values are already in correct units (meters/feet)
   - No need for km conversion unlike some calculation results
   - Use existing `formatHeight()` for consistent formatting

## Common Pitfalls to Avoid

1. **Value Source Confusion**
   - Don't use `visibleTargetHeight` - it's for visible portion after curvature
   - Don't convert units unnecessarily - input is already in correct units

2. **Label Integration**
   - Ensure group's labels are included in parent view model
   - Check label map is properly merged with other label groups

3. **Configuration**
   - Match IDs exactly between config, SVG, and code
   - Follow existing prefix pattern from other measurements

## Testing New Measurement Groups

1. **Configuration**
   - Add configuration to diagram_spec.json
   - Follow existing ID and prefix patterns

2. **Value Source**
   - Identify correct value source (direct input vs. calculation result)
   - Understand units of the source value

3. **Integration**
   - Add label to parent view model's getLabelValues()
   - Test with both metric and imperial units

4. **Validation**
   - Verify value matches input field
   - Check unit conversion behavior
   - Test empty/null value handling

## Best Practices

1. **Follow Existing Patterns**
   - Use consistent ID format for new measurements
   - Follow C-Height implementation as reference

2. **Unit Handling**
   - Document unit expectations clearly
   - Use existing conversion helpers
   - Be explicit about unit sources

3. **Value Flow**
   - Understand the difference between input values and calculation results
   - Document where values come from and any transformations

4. **Testing**
   - Test both metric and imperial units
   - Verify empty/null handling
   - Check integration with parent view models

## Step-by-Step Implementation Guide for New Measurement Groups

### 1. Configuration Setup
1. Open `assets/info/diagram_spec.json`
2. Add new label configuration under `labels.points`:
   ```json
   {
     "labels": {
       "points": [
         {
           "id": "X_Y_NewMeasurement",  // Follow ID pattern: group_subgroup_name
           "type": "text",
           "prefix": "Label: "          // Consistent with other measurements
         }
       ]
     }
   }
   ```

### 2. SVG Element Preparation
1. Locate the SVG element in the diagram file
2. Ensure the element ID matches configuration exactly:
   ```xml
   <text
     id="X_Y_NewMeasurement"
     inkscape:label="X_Y_NewMeasurement">
   </text>
   ```

### 3. Value Source Implementation
1. Identify the correct value source:
   - Direct input value (like targetHeight) - already in meters/feet
   - Calculation result (like hiddenHeight) - may need unit conversion
   - Derived value - document any calculations needed

2. In the appropriate group view model (e.g., MountainGroupViewModel):
   ```dart
   @override
   Map<String, String> getLabelValues() {
     final Map<String, String> labels = {};
     
     // For direct input values (already in meters/feet):
     if (inputValue != null) {
       final prefix = _getConfigString(['labels', 'points', 'X_Y_NewMeasurement', 'prefix']) ?? 'Label: ';
       labels['X_Y_NewMeasurement'] = '$prefix${formatHeight(inputValue!)}';
     }
     
     // For calculation results (in km):
     if (result?.calculatedValue != null) {
       final valueInUnits = convertFromKm(result!.calculatedValue!);
       labels['X_Y_NewMeasurement'] = '$prefix${formatHeight(valueInUnits)}';
     }
     
     return labels;
   }
   ```

### 4. Label Integration
1. Ensure parent view model includes the group's labels:
   ```dart
   // In parent view model (e.g., MountainDiagramViewModel)
   @override
   Map<String, String> getLabelValues() {
     return {
       // Existing labels...
       ..._measurementGroup.getLabelValues(),  // Add this line
     };
   }
   ```

### 5. Testing Checklist
Before committing changes:
1. [ ] Configuration
   - [ ] Label ID matches between config and SVG
   - [ ] Prefix is defined correctly
   - [ ] Configuration path is correct in getLabelValues()

2. [ ] Value Display
   - [ ] Label appears in diagram
   - [ ] Value matches input/calculation
   - [ ] Units are correct (metric/imperial)
   - [ ] Formatting matches other labels

3. [ ] Edge Cases
   - [ ] Null value handling works
   - [ ] Zero value displays correctly
   - [ ] Large values format properly
   - [ ] Unit conversion works correctly

### 6. Troubleshooting Guide
If label doesn't appear:
1. Check SVG element ID matches config exactly
2. Verify label is included in parent view model's getLabelValues()
3. Check value source is not null
4. Add debug logging:
   ```dart
   if (kDebugMode) {
     debugPrint('Label update:');
     debugPrint('  - Config prefix: $prefix');
     debugPrint('  - Value: $value');
     debugPrint('  - Final label: ${labels['X_Y_NewMeasurement']}');
   }
   ```

### 7. Common Solutions
- **Label not showing**: Check parent view model includes group's getLabelValues()
- **Wrong value**: Verify using correct value source (direct vs calculated)
- **Wrong units**: Check if value needs conversion from km
- **Inconsistent format**: Use formatHeight() for consistency

By following this guide step-by-step, you can avoid the common label-related issues we encountered with the Z-Height implementation.

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
       text-anchor:middle;
       dominant-baseline:middle;
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
