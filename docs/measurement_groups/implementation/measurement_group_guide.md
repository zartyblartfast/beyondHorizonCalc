# Measurement Group Implementation Guide

## Overview
This guide provides a comprehensive approach to implementing measurement groups in the Beyond Horizon Calculator. Each measurement group follows a consistent pattern while handling its specific requirements.

## Implementation Checklist

### 1. Configuration Setup
- [ ] Add measurement group configuration to `diagram_spec.json`
- [ ] Define SVG element IDs and types
- [ ] Specify datum lines
- [ ] Set coordinate positions
- [ ] Configure label formats

### 2. SVG Elements Required
1. Top Arrow Components:
   - Arrowhead element
   - Arrow line element
2. Label Component:
   - Text element with proper styling
3. Bottom Arrow Components:
   - Arrow line element
   - Arrowhead element

### 3. Coordinate System Understanding
```
ViewBox Coordinates (0,0) at top-left
│
├─ Y increases downward (0 to 1000)
│  ├─ Higher elements have smaller Y values
│  └─ Lower elements have larger Y values
│
└─ X increases rightward (0 to standard width)
```

### 4. Implementation Steps

#### A. Configuration in diagram_spec.json
```json
{
  "labels": {
    "points": [
      {
        "id": "[GROUP_ID]_Height",
        "type": "text",
        "prefix": "[PREFIX]: ",
        "suffix": "m"
      }
    ]
  }
}
```

#### B. Value Source Implementation
```dart
Map<String, String> getLabelValues() {
  final Map<String, String> labels = {};
  
  if (result?.[heightValue] != null) {
    final prefix = _getConfigString(['labels', 'points', '[GROUP_ID]', 'prefix']) ?? '[DEFAULT]: ';
    final suffix = _getConfigString(['labels', 'points', '[GROUP_ID]', 'suffix']) ?? 'm';
    
    // Convert from km to current units
    final heightInUnits = convertFromKm(result![heightValue]!);
    labels['[GROUP_ID]'] = '$prefix${formatHeight(heightInUnits)}$suffix';
  }
  
  return labels;
}
```

#### C. Position Calculation
```dart
Map<String, double> calculate[Group]Positions(double topY, double bottomY) {
  if (!hasSufficientSpace(topY, bottomY)) {
    return {'visible': 0.0};
  }
  
  // Calculate total height considering coordinate system
  final double totalHeight = bottomY - topY;  // Or reverse if needed
  
  // Position label with proper vertical centering
  final double labelY = topY + (totalHeight / 2.0) + (LABEL_HEIGHT / 4.0);
  
  // Calculate arrow endpoints
  final double topArrowEnd = labelY - LABEL_HEIGHT - LABEL_PADDING;
  final double bottomArrowStart = labelY + LABEL_PADDING;
  
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

### 5. Critical Considerations

#### Datum Lines
- Always verify correct datum lines from diagram_spec.json
- Consider coordinate system direction when calculating positions
- Example datum line pairs:
  - V_Height: Mountain Peak (Z_Point_Line) to Observer Level (C_Point_Line)
  - H_Height: Sea Level (Distant_Obj_Sea_Level) to Observer Level (C_Point_Line)

#### Coordinate Calculations
- Verify direction of height calculation based on datum line positions
- Account for ViewBox coordinate system (y increases downward)
- Use consistent x-coordinates for vertical alignment

#### Null Safety
- Handle null values in result data
- Provide fallback values for configuration
- Return safe defaults when space is insufficient

#### Testing Requirements
- Verify correct positioning with different height values
- Test visibility management
- Validate label formatting
- Check arrow alignment and spacing

## Common Pitfalls
1. Incorrect datum line selection
2. Not accounting for ViewBox coordinate system
3. Mixing up measurement group patterns
4. Insufficient null safety handling
5. Incorrect height unit conversions

## Best Practices
1. Always review diagram_spec.json first
2. Verify datum lines before implementation
3. Follow established naming conventions
4. Maintain consistent x-coordinates
5. Use proper unit conversions
6. Implement comprehensive error handling
7. Add debug logging for position calculations

## Related Documentation
- [Coordinate System Guide](../technical/coordinate_system.md)
- [Datum Lines Reference](../technical/datum_lines.md)
- [Measurement Types](../technical/measurement_types.md)
- [Testing Guide](../testing/measurement_testing_guide.md)
