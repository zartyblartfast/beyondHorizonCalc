# Coordinate System Guide

## Overview
The Beyond Horizon Calculator uses an SVG ViewBox coordinate system for positioning elements in the diagram. Understanding this system is crucial for correct measurement group implementation.

## ViewBox Coordinate System

### Basic Properties
```
(0,0) ─────────────────────► X
   │      ViewBox Width: 400
   │
   │      Y increases downward
   │      X increases rightward
   ▼
   Y
Height: 1000
```

### Key Characteristics
1. Origin (0,0) is at top-left
2. Y-axis increases downward (0 to 1000)
3. X-axis increases rightward (0 to 400)
4. All coordinates are in viewBox units

### Important Implications
1. Higher elements have smaller Y values
2. Lower elements have larger Y values
3. Height calculations must consider Y direction:
   ```dart
   // For elements where bottom is lower than top:
   height = bottomY - topY;  // Positive value
   
   // For elements where top is lower than bottom:
   height = topY - bottomY;  // Positive value
   ```

## Measurement Group X-Coordinates

### Standard Positions
Each measurement group has a fixed x-coordinate for vertical alignment:
- C-Height: -250
- V-Height: 240
- H-Height: 280
- Z-Height: 325

### Vertical Elements
All elements in a measurement group share the same x-coordinate:
- Arrow lines
- Arrowheads
- Text labels

## Height Calculations

### ViewBox Scaling
Target heights must be scaled to viewBox units:
```dart
final double xzInKm = targetHeight / 1000.0;  // Convert to kilometers
final double xzViewbox = xzInKm * _viewboxScale;  // Scale to viewBox units
```

### Position Calculations
Consider coordinate direction when calculating positions:
```dart
// Example: Label positioning
final double labelY = topY + (totalHeight / 2.0) + (LABEL_HEIGHT / 4.0);

// Example: Arrow endpoints
final double topArrowEnd = labelY - LABEL_HEIGHT - LABEL_PADDING;
final double bottomArrowStart = labelY + LABEL_PADDING;
```

## Datum Line Relationships

### Vertical Ordering (top to bottom)
1. Mountain Peak (smallest Y)
2. C_Point_Line (Observer Level)
3. Distant_Obj_Sea_Level
4. Observer_Height_Above_Sea_Level (largest Y)

### Height Calculations Between Datum Lines
```dart
// V-Height: Mountain Peak to Observer Level
vHeight = observerLevel - mountainPeakY;

// H-Height: Sea Level to Observer Level
hHeight = seaLevelY - observerLevel;

// Z-Height: Mountain Base to Peak
zHeight = mountainBaseY - mountainPeakY;

// C-Height: Observer Height Line to Level
cHeight = observerHeightY - observerLevel;
```

## Common Pitfalls

### 1. Reversed Height Calculations
**Problem**: Negative heights due to incorrect subtraction order
**Solution**: Consider Y-axis direction when calculating heights
```dart
// CORRECT: Account for Y increasing downward
height = lowerY - higherY;

// INCORRECT: Will give negative value
height = higherY - lowerY;
```

### 2. Inconsistent X-Coordinates
**Problem**: Misaligned measurement elements
**Solution**: Use defined x-coordinate constants
```dart
// CORRECT: Use constant
final double x = V_HEIGHT_X_COORD;

// INCORRECT: Hardcoded or varying x values
final double x = 240 + offset;
```

### 3. Label Positioning
**Problem**: Labels not centered between arrows
**Solution**: Account for label height in calculations
```dart
// CORRECT: Include label height adjustment
labelY = topY + (totalHeight / 2.0) + (LABEL_HEIGHT / 4.0);

// INCORRECT: Simple midpoint
labelY = topY + (totalHeight / 2.0);
```

## Best Practices

1. Always verify datum line vertical ordering
2. Use consistent x-coordinates within measurement groups
3. Consider ViewBox direction in calculations
4. Scale heights properly to viewBox units
5. Add debug logging for position calculations
6. Validate height calculations are positive
7. Maintain proper spacing between elements
