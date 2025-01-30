# Visible Height (h3) Implementation Example

This example demonstrates implementing the Visible Height (h3) measurement group following the patterns from the [Measurement Group Implementation Guide](../measurement_group_guide.md).

## Implementation Details

### 1. Configuration
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
All elements use x-coordinate: 240 for vertical alignment.

#### Required Elements:
```
1_1_Visible_Height_Top_arrow      (Top arrow line)
1_1_Visible_Height_Top_arrowhead  (Top arrow marker)
1_2_Visible_Height_Height         (Text label)
1_3_Visible_Height_Bottom_arrow   (Bottom arrow line)
1_3_Visible_Height_Bottom_arrowhead (Bottom arrow marker)
```

### 3. Datum Lines
- **Top**: Z_Point_Line (Mountain Peak)
- **Bottom**: C_Point_Line (Observer Level)

### 4. Implementation Code

#### A. Value Source
```dart
Map<String, String> getLabelValues() {
  final Map<String, String> labels = {};
  
  if (result?.visibleTargetHeight != null) {
    final prefix = _getConfigString(['labels', 'points', '1_2_Visible_Height_Height', 'prefix']) ?? 'h3: ';
    final suffix = _getConfigString(['labels', 'points', '1_2_Visible_Height_Height', 'suffix']) ?? 'm';
    
    // Convert from km to current units
    final heightInUnits = convertFromKm(result!.visibleTargetHeight!);
    labels['1_2_Visible_Height_Height'] = '$prefix${formatHeight(heightInUnits)}$suffix';
  }
  
  return labels;
}
```

#### B. Position Calculation
```dart
Map<String, double> calculateVHeightPositions(double topY, double bottomY) {
  if (!hasSufficientSpace(topY, bottomY)) {
    return {'visible': 0.0};
  }
  
  final double totalHeight = bottomY - topY;
  final double labelY = topY + (totalHeight / 2.0) + (V_HEIGHT_LABEL_HEIGHT / 4.0);
  final double topArrowEnd = labelY - V_HEIGHT_LABEL_HEIGHT - V_HEIGHT_LABEL_PADDING;
  final double bottomArrowStart = labelY + V_HEIGHT_LABEL_PADDING;
  
  return {
    'visible': 1.0,
    'startY': topY,
    'topArrowEnd': topArrowEnd,
    'labelY': labelY,
    'bottomArrowStart': bottomArrowStart,
    'endY': bottomY
  };
}
```

#### C. Usage in updateDynamicElements
```dart
// Calculate V-Height positions between Z_Point_Line and C_Point_Line
final vHeightPositions = calculateVHeightPositions(mountainPeakY, observerLevel);
final vHeightElements = [
  '1_1_Visible_Height_Top_arrowhead',
  '1_1_Visible_Height_Top_arrow',
  '1_2_Visible_Height_Height',
  '1_3_Visible_Height_Bottom_arrow',
  '1_3_Visible_Height_Bottom_arrowhead'
];

if (vHeightPositions['visible'] == 0.0) {
  // Hide V-height elements if there's not enough space
  updatedSvg = updateVisibility(updatedSvg, vHeightElements, false);
} else {
  // Update V-height element positions
  updatedSvg = updateVisibility(updatedSvg, vHeightElements, true);
  // ... position updates follow
}
```

## Key Implementation Notes

### Coordinate System Considerations
- Uses standard ViewBox coordinates (y increases downward)
- Properly calculates totalHeight as bottomY - topY
- Maintains consistent x-coordinate (240) for vertical alignment

### Error Handling
1. Null safety for visibleTargetHeight
2. Default prefix and suffix values
3. Space validation before positioning
4. Visibility management based on available space

### Unit Conversions
- Input height is in kilometers
- Converts to meters/feet based on user preference
- Uses formatHeight() for consistent display

### Positioning Logic
1. Centers label between datum lines
2. Maintains consistent spacing with label padding
3. Properly aligns arrows with datum lines
4. Handles visibility based on available space

## Common Issues and Solutions

### 1. Label Positioning
**Problem**: Label not centered between arrows  
**Solution**: Use quarter-height adjustment in labelY calculation
```dart
labelY = topY + (totalHeight / 2.0) + (V_HEIGHT_LABEL_HEIGHT / 4.0);
```

### 2. Arrow Alignment
**Problem**: Arrows not connecting to datum lines  
**Solution**: Use exact datum line coordinates
```dart
'startY': topY,    // Exact Z_Point_Line coordinate
'endY': bottomY    // Exact C_Point_Line coordinate
```

### 3. Space Management
**Problem**: Elements overlap when space is limited  
**Solution**: Implement visibility check
```dart
if (!hasSufficientSpace(topY, bottomY)) {
  return {'visible': 0.0};
}
```
