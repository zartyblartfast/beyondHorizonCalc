# Z-Height (XZ) Implementation Example

This example demonstrates implementing the Z-Height (XZ) measurement group following the patterns from the [Measurement Group Implementation Guide](../measurement_group_guide.md).

## Implementation Details

### 1. Configuration
```json
{
  "labels": {
    "points": [
      {
        "id": "3_2_Z_Height",
        "type": "text",
        "prefix": "XZ: ",
        "suffix": "m"
      }
    ]
  }
}
```

### 2. SVG Elements
All elements use x-coordinate: 325 for vertical alignment.

#### Required Elements:
```
3_1_Z_Height_Top_arrow      (Top arrow line)
3_1_Z_Height_Top_arrowhead  (Top arrow marker)
3_2_Z_Height               (Text label)
3_3_Z_Height_Bottom_arrow   (Bottom arrow line)
3_3_Z_Height_Bottom_arrowhead (Bottom arrow marker)
```

### 3. Datum Lines
- **Top**: Mountain Peak (calculated position)
- **Bottom**: Mountain Base (at sea level)

### 4. Implementation Code

#### A. Value Source
```dart
Map<String, String> getLabelValues() {
  final Map<String, String> labels = {};
  
  // IMPORTANT: Use targetHeight directly - it's already in correct units
  if (targetHeight != null) {
    final prefix = _getConfigString(['labels', 'points', '3_2_Z_Height', 'prefix']) ?? 'XZ: ';
    final suffix = _getConfigString(['labels', 'points', '3_2_Z_Height', 'suffix']) ?? 'm';
    labels['3_2_Z_Height'] = '$prefix${formatHeight(targetHeight!)}$suffix';
  }
  
  return labels;
}
```

#### B. Position Calculation
```dart
Map<String, double> calculateZHeightPositions(double peakY, double baseY) {
  if (kDebugMode) {
    debugPrint('calculateZHeightPositions - Starting calculation');
    debugPrint('  - Mountain Peak Y: $peakY');
    debugPrint('  - Mountain Base Y: $baseY');
  }

  if (!hasSufficientSpace(peakY, baseY)) {
    return {'visible': 0.0};
  }
  
  final double totalHeight = baseY - peakY;  // In viewBox coordinates
  final double labelY = peakY + (totalHeight / 2.0) + (Z_HEIGHT_LABEL_HEIGHT / 4.0);
  final double topArrowEnd = labelY - Z_HEIGHT_LABEL_HEIGHT - Z_HEIGHT_LABEL_PADDING;
  final double bottomArrowStart = labelY + Z_HEIGHT_LABEL_PADDING;
  
  return {
    'visible': 1.0,
    'startY': peakY,
    'topArrowEnd': topArrowEnd,
    'labelY': labelY,
    'bottomArrowStart': bottomArrowStart,
    'endY': baseY
  };
}
```

#### C. Usage in updateDynamicElements
```dart
// Position mountain peak above its base by target height
final double mountainBaseY = seaLevelY;
final double mountainPeakY = mountainBaseY - xzViewbox;

// Calculate Z-Height positions
final zHeightPositions = calculateZHeightPositions(mountainPeakY, mountainBaseY);
```

## Key Implementation Notes

### Coordinate System Considerations
- ViewBox coordinates: y=0 at top, y=1000 at bottom
- Mountain peak is higher than base (smaller Y value)
- Uses xzViewbox for scaling target height to viewBox units

### Value Handling
1. targetHeight is already in correct units (meters/feet)
2. No conversion needed from kilometers
3. Uses formatHeight() for consistent display

### Positioning Logic
1. Mountain base aligns with sea level
2. Peak position calculated from base and scaled height
3. Label centered between peak and base
4. Arrows properly aligned with mountain geometry

### Error Handling
1. Null safety for targetHeight
2. Default prefix and suffix values
3. Space validation before positioning
4. Visibility management based on available space

## Common Issues and Solutions

### 1. Height Scaling
**Problem**: Incorrect mountain peak position  
**Solution**: Properly scale target height to viewBox units
```dart
final double xzViewbox = xzInKm * _viewboxScale;
final double mountainPeakY = mountainBaseY - xzViewbox;
```

### 2. Value Units
**Problem**: Unnecessary unit conversion  
**Solution**: Use targetHeight directly as it's already in correct units
```dart
labels['3_2_Z_Height'] = '$prefix${formatHeight(targetHeight!)}$suffix';
// NOT: convertFromKm(targetHeight!)
```

### 3. Mountain Geometry
**Problem**: Z-Height not aligned with mountain  
**Solution**: Use exact mountain peak and base coordinates
```dart
final zHeightPositions = calculateZHeightPositions(mountainPeakY, mountainBaseY);
```

## Integration with Mountain Group
Z-Height is tightly integrated with the mountain geometry:
1. Uses same base point as mountain triangle
2. Peak position determined by target height
3. Updates dynamically with mountain size changes
4. Maintains visual alignment with mountain shape
