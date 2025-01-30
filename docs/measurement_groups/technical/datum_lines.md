# Datum Lines Reference Guide

## Overview
Datum lines are reference lines in the diagram that measurement groups use for positioning and calculations. Each measurement group uses specific datum lines that relate to its purpose.

## Datum Line Catalog

### C_Point_Line
- **Purpose**: Defines the observer's position and horizon level
- **Characteristics**:
  - Horizontal line at observer's eye level
  - Primary reference for visibility calculations
  - Used by multiple measurement groups
- **Used By**:
  - V-Height (bottom datum)
  - H-Height (top datum)
  - C-Height (top datum)

### Distant_Obj_Sea_Level
- **Purpose**: Represents sea level at the target location
- **Characteristics**:
  - Horizontal line at sea level
  - Reference for hidden height calculations
  - Aligned with mountain base
- **Used By**:
  - H-Height (bottom datum)
  - Z-Height (mountain base reference)

### Observer_Height_Above_Sea_Level
- **Purpose**: Shows observer's height above sea level
- **Characteristics**:
  - Vertical line extending below C_Point_Line
  - Length scaled from observer height input
- **Used By**:
  - C-Height (bottom datum)

### Z_Point_Line
- **Purpose**: Represents mountain peak position
- **Characteristics**:
  - Dynamic position based on target height
  - Reference for visible height calculations
- **Used By**:
  - V-Height (top datum)
  - Z-Height (top datum)

## Measurement Group Relationships

### 1. V-Height (Visible Height)
```
Z_Point_Line (top)
    │
    │ Visible portion of target
    │
C_Point_Line (bottom)
```

### 2. H-Height (Hidden Height)
```
C_Point_Line (top)
    │
    │ Hidden portion due to curvature
    │
Distant_Obj_Sea_Level (bottom)
```

### 3. Z-Height (Target Height)
```
Mountain Peak (top, aligned with Z_Point_Line)
    │
    │ Total target height
    │
Mountain Base (bottom, at sea level)
```

### 4. C-Height (Observer Height)
```
C_Point_Line (top)
    │
    │ Observer height above sea level
    │
Observer_Height_Above_Sea_Level (bottom)
```

## Implementation Considerations

### 1. Vertical Ordering
From top to bottom in ViewBox coordinates:
1. Mountain Peak/Z_Point_Line (smallest Y)
2. C_Point_Line
3. Distant_Obj_Sea_Level
4. Observer_Height_Above_Sea_Level (largest Y)

### 2. Dynamic vs Static Lines
- **Dynamic**:
  - Z_Point_Line (moves with target height)
  - Observer_Height_Above_Sea_Level (scales with observer height)
- **Static**:
  - C_Point_Line (fixed position)
  - Distant_Obj_Sea_Level (fixed at sea level)

### 3. Coordinate Access
```dart
// Get datum line Y-coordinates
final double observerLevel = getPointY('C_Point_Line');
final double seaLevelY = getPointY('Distant_Obj_Sea_Level');
final double mountainPeakY = getPointY('Z_Point_Line');
```

## Common Pitfalls

### 1. Wrong Datum Line Selection
**Problem**: Using incorrect datum lines for measurements
**Solution**: Verify datum lines in diagram_spec.json
```dart
// CORRECT for H-Height
calculateHHeightPositions(distantObjY, cPointY);

// INCORRECT for H-Height
calculateHHeightPositions(zPointY, cPointY);
```

### 2. Coordinate Direction
**Problem**: Not considering ViewBox Y-direction
**Solution**: Remember Y increases downward
```dart
// CORRECT: Consider Y direction
height = bottomDatumY - topDatumY;

// INCORRECT: Wrong direction
height = topDatumY - bottomDatumY;
```

### 3. Dynamic Line Updates
**Problem**: Not updating positions with input changes
**Solution**: Recalculate in updateDynamicElements
```dart
// Update mountain peak position
final mountainPeakY = mountainBaseY - xzViewbox;

// Update observer height line
final observerHeightY = observerLevel + observerHeightViewbox;
```

## Best Practices

1. Always verify datum lines in configuration
2. Consider coordinate system direction
3. Update dynamic lines properly
4. Maintain proper vertical ordering
5. Use consistent naming conventions
6. Add debug logging for datum line positions
7. Validate position calculations

## Related Documentation
- [Coordinate System Guide](coordinate_system.md)
- [Measurement Types](measurement_types.md)
- [Implementation Guide](../implementation/measurement_group_guide.md)
