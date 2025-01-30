# C-Height (h1) Implementation Example

This example demonstrates implementing the C-Height (h1) measurement group following the patterns from the [Measurement Group Implementation Guide](../measurement_group_guide.md). This is considered the reference implementation for measurement groups.

## Implementation Details

### 1. Configuration
```json
{
  "labels": {
    "points": [
      {
        "id": "2_2_C_Height",
        "type": "text",
        "prefix": "h1: ",
        "suffix": "m"
      }
    ]
  }
}
```

### 2. SVG Elements
All elements use x-coordinate: -250 for vertical alignment.

#### Required Elements:
```
2_1_C_Height_Top_arrow      (Top arrow line)
2_1_C_Height_Top_arrowhead  (Top arrow marker)
2_2_C_Height               (Text label)
2_3_C_Height_Bottom_arrow   (Bottom arrow line)
2_3_C_Height_Bottom_arrowhead (Bottom arrow marker)
```

### 3. Datum Lines
- **Top**: C_Point_Line (Observer Level)
- **Bottom**: Observer_Height_Above_Sea_Level (Extended line below C_Point_Line)

### 4. Implementation Code

#### A. Value Source
```dart
Map<String, String> getLabelValues() {
  final Map<String, String> labels = {};
  
  if (observerHeight != null) {
    final prefix = _getConfigString(['labels', 'points', '2_2_C_Height', 'prefix']) ?? 'h1: ';
    final suffix = _getConfigString(['labels', 'points', '2_2_C_Height', 'suffix']) ?? 'm';
    
    // observerHeight is already in correct units
    labels['2_2_C_Height'] = '$prefix${formatHeight(observerHeight!)}$suffix';
  }
  
  return labels;
}
```

#### B. Position Calculation
```dart
Map<String, double> calculateCHeightPositions(double observerLevelY, double observerHeightY) {
  if (kDebugMode) {
    debugPrint('calculateCHeightPositions - Starting calculation');
    debugPrint('  - Observer Level Y: $observerLevelY');
    debugPrint('  - Observer Height Y: $observerHeightY');
  }

  if (!hasSufficientSpace(observerLevelY, observerHeightY)) {
    return {'visible': 0.0};
  }
  
  final double totalHeight = observerHeightY - observerLevelY;  // ViewBox coordinates
  final double labelY = observerLevelY + (totalHeight / 2.0) + (C_HEIGHT_LABEL_HEIGHT / 4.0);
  final double topArrowEnd = labelY - C_HEIGHT_LABEL_HEIGHT - C_HEIGHT_LABEL_PADDING;
  final double bottomArrowStart = labelY + C_HEIGHT_LABEL_PADDING;
  
  return {
    'visible': 1.0,
    'startY': observerLevelY,
    'topArrowEnd': topArrowEnd,
    'labelY': labelY,
    'bottomArrowStart': bottomArrowStart,
    'endY': observerHeightY
  };
}
```

#### C. Usage in updateDynamicElements
```dart
// Calculate C-Height positions
final cHeightPositions = calculateCHeightPositions(observerLevel, observerHeightLine);
```

### 5. SVG Styling

#### Text Label Style
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

#### Arrow Styles
```css
/* Top Arrow */
stroke="#000000"
stroke-width="1.99598"

/* Top Arrowhead */
style="fill:#000000;stroke:none;fill-opacity:1"
```

## Key Implementation Notes

### Coordinate System Considerations
- ViewBox coordinates: y=0 at top, y=1000 at bottom
- Observer level is higher than height line
- Uses standard vertical measurement layout

### Value Handling
1. observerHeight is already in correct units (meters/feet)
2. No conversion needed from kilometers
3. Uses formatHeight() for consistent display

### Positioning Logic
1. Aligns with observer position in diagram
2. Extends below C_Point_Line
3. Label centered between datum lines
4. Maintains consistent arrow and label spacing

### Error Handling
1. Null safety for observerHeight
2. Default prefix and suffix values
3. Space validation before positioning
4. Visibility management based on available space

## Common Issues and Solutions

### 1. Style Consistency
**Problem**: Inconsistent text or arrow styling  
**Solution**: Use reference CSS styles exactly
```css
font-family:Calibri;
font-size:12.0877px;
font-weight:bold;
```

### 2. Position Alignment
**Problem**: Misalignment with observer position  
**Solution**: Use exact observer level coordinates
```dart
final cHeightPositions = calculateCHeightPositions(observerLevel, observerHeightLine);
```

### 3. Label Spacing
**Problem**: Uneven label spacing  
**Solution**: Use standard padding calculations
```dart
final double topArrowEnd = labelY - C_HEIGHT_LABEL_HEIGHT - C_HEIGHT_LABEL_PADDING;
final double bottomArrowStart = labelY + C_HEIGHT_LABEL_PADDING;
```

## Reference Implementation Status
C-Height serves as the reference implementation for all measurement groups because it:
1. Follows all standard patterns
2. Uses consistent styling
3. Implements proper error handling
4. Demonstrates correct coordinate system usage
5. Shows proper integration with diagram elements
