# Measurement Types Guide

## Overview
The Beyond Horizon Calculator uses four distinct types of height measurements to help users understand target visibility over the Earth's curvature. Each measurement type serves a specific purpose and uses particular datum lines.

## Measurement Types

### 1. Visible Height (h3)
- **Purpose**: Shows portion of target visible to observer
- **Mathematical Symbol**: h3
- **Datum Lines**:
  - Top: Z_Point_Line (Mountain Peak)
  - Bottom: C_Point_Line (Observer Level)
- **Key Characteristics**:
  - Dynamic based on target and observer positions
  - Always less than or equal to total target height
  - Zero when target is fully hidden
- **Implementation Details**:
  - Uses result.visibleTargetHeight (in km)
  - Requires conversion to meters/feet
  - X-coordinate: 240

### 2. Hidden Height (h2)
- **Purpose**: Shows portion of target hidden by Earth's curvature
- **Mathematical Symbol**: h2
- **Datum Lines**:
  - Top: C_Point_Line (Observer Level)
  - Bottom: Distant_Obj_Sea_Level (Sea Level)
- **Key Characteristics**:
  - Increases with distance to target
  - Affected by observer height
  - Zero when target fully visible
- **Implementation Details**:
  - Uses result.hiddenHeight (in km)
  - Requires conversion to meters/feet
  - X-coordinate: 280

### 3. Target Height (XZ)
- **Purpose**: Shows total height of target object
- **Mathematical Symbol**: XZ
- **Datum Lines**:
  - Top: Mountain Peak
  - Bottom: Mountain Base (at sea level)
- **Key Characteristics**:
  - Fixed based on user input
  - Sum of visible and hidden heights
  - Independent of observer position
- **Implementation Details**:
  - Uses targetHeight directly (in meters/feet)
  - No conversion needed
  - X-coordinate: 325

### 4. Observer Height (h1)
- **Purpose**: Shows observer's height above sea level
- **Mathematical Symbol**: h1
- **Datum Lines**:
  - Top: C_Point_Line (Observer Level)
  - Bottom: Observer_Height_Above_Sea_Level
- **Key Characteristics**:
  - Fixed based on user input
  - Affects hidden height calculations
  - Independent of target properties
- **Implementation Details**:
  - Uses observerHeight directly (in meters/feet)
  - No conversion needed
  - X-coordinate: -250

## Mathematical Relationships

### Height Calculations
```
Total Target Height (XZ) = Visible Height (h3) + Hidden Height (h2)
Hidden Height (h2) = f(distance, observer_height)
Visible Height (h3) = XZ - h2
```

### Unit Conversions
```dart
// From kilometers to meters
final heightInMeters = heightInKm * 1000;

// From kilometers to feet
final heightInFeet = heightInKm * 3280.84;
```

## Implementation Patterns

### 1. Value Source
```dart
// For heights in kilometers (h2, h3)
final heightInUnits = convertFromKm(result!.heightValue!);

// For heights in meters/feet (h1, XZ)
final heightInUnits = heightValue;  // Direct use
```

### 2. Label Formatting
```dart
// Standard format
$prefix${formatHeight(heightInUnits)}$suffix

// Example outputs:
"h1: 2.0m"    // Observer Height
"h2: 15.3m"   // Hidden Height
"h3: 84.7m"   // Visible Height
"XZ: 100.0m"  // Target Height
```

### 3. Position Calculations
```dart
// Standard position calculation pattern
final double totalHeight = bottomY - topY;
final double labelY = topY + (totalHeight / 2.0) + (LABEL_HEIGHT / 4.0);
```

## Testing Considerations

### 1. Value Tests
- Verify correct unit conversions
- Check mathematical relationships
- Validate height calculations

### 2. Edge Cases
- Zero heights
- Very large heights
- Equal visible and hidden portions
- Fully hidden targets

### 3. Dynamic Updates
- Changes in observer height
- Changes in target height
- Changes in distance

## Best Practices

1. **Unit Handling**
   - Always verify input units
   - Use correct conversion functions
   - Maintain consistent output format

2. **Value Validation**
   - Check for null values
   - Validate mathematical relationships
   - Handle edge cases gracefully

3. **Visual Clarity**
   - Maintain proper spacing
   - Use consistent formatting
   - Ensure readability at all scales

4. **Code Organization**
   - Group related calculations
   - Use clear variable names
   - Document mathematical relationships

## Related Documentation
- [Coordinate System Guide](coordinate_system.md)
- [Datum Lines Reference](datum_lines.md)
- [Implementation Guide](../implementation/measurement_group_guide.md)
