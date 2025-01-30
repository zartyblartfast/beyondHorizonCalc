# Visible Height (h3) Implementation Guide

## Overview
The Visible Height measurement group displays the visible portion of the target height (h3) in the diagram. This implementation follows the patterns established by Z-Height and C-Height measurement groups.

## Key Components

### 1. Configuration in diagram_spec.json
```json
{
  "labels": {
    "points": [
      {
        "id": "1_2_Visible_Height_Height",
        "type": "text",
        "prefix": "h3: ",
        "suffix": "m"
      }
    ]
  }
}
```

### 2. SVG Elements
Required elements with specific IDs:
- `1_1_Visible_Height_Top_arrow` and arrowhead (top measurement arrow)
- `1_2_Visible_Height_Height` (text label)
- `1_3_Visible_Height_Bottom_arrow` and arrowhead (bottom measurement arrow)

Common x-coordinate: 240 (for vertical alignment)

Datum lines:
- Upper: Z_Point_Line
- Lower: C_Point_Line

### 3. Value Source
In `MountainGroupViewModel`:
```dart
@override
Map<String, String> getLabelValues() {
  final Map<String, String> labels = {};
  
  // Use visibleTargetHeight for h3 calculation
  if (result?.visibleTargetHeight != null) {
    final prefix = _getConfigString(['labels', 'points', '1_2_Visible_Height_Height', 'prefix']) ?? 'h3: ';
    final suffix = _getConfigString(['labels', 'points', '1_2_Visible_Height_Height', 'suffix']) ?? 'm';
    
    // Convert from km to current units (meters or feet)
    final heightInUnits = convertFromKm(result!.visibleTargetHeight!);
    labels['1_2_Visible_Height_Height'] = '$prefix${formatHeight(heightInUnits)}$suffix';
  }
  
  return labels;
}
```

## Critical Implementation Points

1. **Value Source**
   - Use `result.visibleTargetHeight` - this represents the visible portion of the target
   - IMPORTANT: Value is in kilometers and must be converted to meters:
     ```dart
     // Convert from km to current units (meters or feet)
     final heightInUnits = convertFromKm(result!.visibleTargetHeight!);
     labels['1_2_Visible_Height_Height'] = '$prefix${formatHeight(heightInUnits)}';
     ```
   - Use formatHeight() for consistent formatting with 'm' suffix
   - Include both prefix ('h3: ') and suffix ('m') in label
   - IMPORTANT: Handle null safety properly with visibleTargetHeight

2. **SVG Positioning**
   - All measurement arrows and text must share x=240 coordinate
   - Arrows must span between Z_Point_Line and C_Point_Line
   - Text label positioning must follow Z_Height pattern:
     ```dart
     // Calculate total available space
     final double totalHeight = bottomY - topY;
     
     // Position label with proper vertical centering
     final double labelY = topY + (totalHeight / 2.0) + (V_HEIGHT_LABEL_HEIGHT / 4.0);
     
     // Calculate arrow endpoints with even spacing
     final double topArrowEnd = labelY - V_HEIGHT_LABEL_HEIGHT - V_HEIGHT_LABEL_PADDING;
     final double bottomArrowStart = labelY + V_HEIGHT_LABEL_PADDING;
     ```
   - IMPORTANT: Arrow paths must follow Z_Height pattern exactly for null safety:
     ```dart
     // Top arrowhead (correct pattern)
     'd': 'M ${V_HEIGHT_X_COORD},${positions['startY']} l -5,10 h 10 z'
     
     // Bottom arrowhead (correct pattern)
     'd': 'M ${V_HEIGHT_X_COORD},${positions['endY']} l -5,-10 h 10 z'
     
     // DO NOT use arithmetic in path strings as it causes null safety issues:
     // INCORRECT: 'd': 'M ${V_HEIGHT_X_COORD - 5},${positions['startY'] + 10} ...'
     ```

3. **Integration**
   - Part of the mountain group alongside Z_Height
   - Updates dynamically with target height and observer position changes
   - Follows same visibility management pattern as Z_Height

4. **Null Safety Considerations**
   - Position values from calculateVHeightPositions must be non-null
   - Use the exact same SVG path patterns as Z_Height for arrows and arrowheads
   - Avoid arithmetic operations in SVG path strings to prevent null safety issues
   - Extract position values early and reuse to maintain consistency

## Common Pitfalls and Solutions

1. **Null Safety**
   - Always use null-safe access for result fields: `result?.visibleTargetHeight`
   - Add null coalescing for position values to prevent runtime errors
   - Double-bang (!!) only when you're certain the value exists

2. **Value Source Confusion**
   - Use `visibleTargetHeight` not `visibleHeight`
   - The field represents the visible portion after curvature calculations
   - Available in the CalculationResult class

3. **Position Management**
   - Extract position values before using in multiple places
   - Use consistent coordinate system with other measurement groups
   - Handle null cases gracefully with default values

## Common Issues and Solutions

1. **Arrow Path Null Safety**
   - Problem: Arithmetic in SVG paths can cause null safety errors
   - Solution: Follow Z_Height pattern exactly for path definitions
   - Example: Use `l -5,10 h 10 z` instead of calculating coordinates

2. **Position Management**
   - Problem: Null values in position calculations
   - Solution: Ensure calculateVHeightPositions returns non-null values
   - Use null coalescing only when absolutely necessary

3. **Arrow Spacing**
   - Problem: Arrows connecting directly to label position
   - Solution: Use topArrowEnd and bottomArrowStart positions
   - Follow Z_Height pattern for consistent spacing

4. **Label Vertical Positioning**
   - Problem: Uneven spacing above and below label
   - Solution: Follow Z_Height pattern for label positioning:
     - Center based on total height: `(totalHeight / 2.0)`
     - Add quarter label height offset: `(V_HEIGHT_LABEL_HEIGHT / 4.0)`
     - Use consistent padding above and below: `V_HEIGHT_LABEL_PADDING`
   - Ensures visual balance and readability

5. **Unit Conversion**
   - Problem: Values from CalculationResult are in kilometers
   - Solution: Convert to meters before display:
     - Use `convertFromKm()` from DiagramViewModel
     - Apply conversion before formatHeight()
     - Ensures consistency with Z_Height display
   - Example:
     ```dart
     // Correct: Convert km to m before formatting
     final heightInUnits = convertFromKm(result!.visibleTargetHeight!);
     labels['1_2_Visible_Height_Height'] = '$prefix${formatHeight(heightInUnits)}';
     
     // Incorrect: Using raw kilometer value
     labels['1_2_Visible_Height_Height'] = '$prefix${formatHeight(result!.visibleTargetHeight!)}';
     ```

## Testing Considerations
1. Verify label updates with target height changes
2. Confirm correct positioning relative to datum lines
3. Check formatting consistency with other measurement groups
4. Validate prefix and suffix display
5. Test null safety handling with missing or partial data
6. Verify visibility management with insufficient space
7. Confirm units display correctly in meters (not kilometers)
