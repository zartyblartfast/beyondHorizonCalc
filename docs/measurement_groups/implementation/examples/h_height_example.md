# Hidden Height (h2) Implementation Example

This example demonstrates implementing the Hidden Height (h2) measurement group following the patterns from the [Measurement Group Implementation Guide](../measurement_group_guide.md).

## Implementation Details

### 1. Configuration
```json
{
  "labels": {
    "points": [
      {
        "id": "4_2_H_Height_Height",
        "type": "text",
        "prefix": "h2: ",
        "suffix": "m"
      }
    ]
  }
}
```

### 2. SVG Elements
All elements use x-coordinate: 280 for vertical alignment.

#### Required Elements:
```
4_1_H_Height_Top_arrow      (Top arrow line)
4_1_H_Height_Top_arrowhead  (Top arrow marker)
4_2_H_Height_Height         (Text label)
4_3_H_Height_Bottom_arrow   (Bottom arrow line)
4_3_H_Height_Bottom_arrowhead (Bottom arrow marker)
```

### 3. Datum Lines
- **Top**: C_Point_Line (Observer Level)
- **Bottom**: Distant_Obj_Sea_Level (Sea Level)

### 4. Implementation Code

#### A. Value Source
```dart
Map<String, String> getLabelValues() {
  final Map<String, String> labels = {};
  
  if (result?.hiddenHeight != null) {
    final prefix = _getConfigString(['labels', 'points', '4_2_H_Height_Height', 'prefix']) ?? 'h2: ';
    final suffix = _getConfigString(['labels', 'points', '4_2_H_Height_Height', 'suffix']) ?? 'm';
    
    // Convert from km to current units
    final heightInUnits = convertFromKm(result!.hiddenHeight!);
    labels['4_2_H_Height_Height'] = '$prefix${formatHeight(heightInUnits)}$suffix';
  }
  
  return labels;
}
```

#### B. Position Calculation
```dart
Map<String, double> calculateHHeightPositions(double distantObjY, double cPointY) {
  if (kDebugMode) {
    debugPrint('calculateHHeightPositions - Starting calculation');
    debugPrint('  - Distant_Obj_Sea_Level Y: $distantObjY');
    debugPrint('  - C_Point_Line Y: $cPointY');
  }

  if (!hasSufficientSpace(distantObjY, cPointY)) {
    return {'visible': 0.0};
  }
  
  // Note: In viewBox coordinates, Y increases downward (0 to 1000)
  // So cPointY will be less than distantObjY
  final double totalHeight = distantObjY - cPointY;  // Reversed order due to coordinate system
  final double labelY = cPointY + (totalHeight / 2.0) + (H_HEIGHT_LABEL_HEIGHT / 4.0);
  final double topArrowEnd = labelY - H_HEIGHT_LABEL_HEIGHT - H_HEIGHT_LABEL_PADDING;
  final double bottomArrowStart = labelY + H_HEIGHT_LABEL_PADDING;
  
  return {
    'visible': 1.0,
    'startY': cPointY,           // Top arrow starts at C_Point_Line (higher in viewBox)
    'topArrowEnd': topArrowEnd,
    'labelY': labelY,
    'bottomArrowStart': bottomArrowStart,
    'endY': distantObjY         // Bottom arrow ends at Distant_Obj_Sea_Level (lower in viewBox)
  };
}
```

#### C. Usage in updateDynamicElements
```dart
// Get Distant_Obj_Sea_Level and C_Point_Line Y-coordinates
final double distantObjY = seaLevelY;  // Distant_Obj_Sea_Level aligns with sea level
final double cPointY = observerLevel;  // C_Point_Line aligns with observer level

// Calculate H-Height positions
final hHeightPositions = calculateHHeightPositions(distantObjY, cPointY);
```

## Key Implementation Notes

### Coordinate System Considerations
- ViewBox coordinates: y=0 at top, y=1000 at bottom
- C_Point_Line is higher than Distant_Obj_Sea_Level
- Calculations must account for reversed Y direction

### Error Handling
1. Null safety for hiddenHeight
2. Default prefix and suffix values
3. Space validation before positioning
4. Visibility management based on available space

### Unit Conversions
- Input height is in kilometers
- Converts to meters/feet based on user preference
- Uses formatHeight() for consistent display

### Positioning Logic
1. Accounts for reversed Y coordinate system
2. Centers label between datum lines
3. Maintains consistent spacing with label padding
4. Properly aligns arrows with datum lines

## Common Issues and Solutions

### 1. Coordinate System
**Problem**: Incorrect height calculation due to Y-axis direction  
**Solution**: Calculate totalHeight as distantObjY - cPointY
```dart
final double totalHeight = distantObjY - cPointY;  // Not cPointY - distantObjY
```

### 2. Datum Line Selection
**Problem**: Using wrong datum lines (e.g., Z_Point_Line)  
**Solution**: Use correct datum lines from diagram_spec.json
```dart
final double distantObjY = seaLevelY;
final double cPointY = observerLevel;
```

### 3. Label Position
**Problem**: Label not centered between arrows  
**Solution**: Account for coordinate system in calculations
```dart
final double labelY = cPointY + (totalHeight / 2.0) + (H_HEIGHT_LABEL_HEIGHT / 4.0);
```
