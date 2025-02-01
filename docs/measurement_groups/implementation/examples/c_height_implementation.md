# C_Height Measurement Implementation Guide

## Overview
This guide covers the implementation details for both internal and external C_Height measurements in the Beyond The Horizon Calculator.

## Implementation Details

### Constants and Measurements
```dart
// Constants for C-height marker
const double C_HEIGHT_LABEL_HEIGHT = 12.0877;
const double C_HEIGHT_LABEL_PADDING = 5.0;
const double C_HEIGHT_MIN_ARROW_LENGTH = 10.0;
const double C_HEIGHT_TOTAL_REQUIRED_HEIGHT = 
    C_HEIGHT_LABEL_HEIGHT + 
    (2 * C_HEIGHT_LABEL_PADDING) + 
    (2 * C_HEIGHT_MIN_ARROW_LENGTH);  // Total: 42.0877 viewbox units
```

### Key Implementation Considerations

#### 1. Unit Management
- The system uses multiple unit types:
  - ViewBox units (SVG coordinate space)
  - Kilometers/Miles (user input)
  - Meters/Feet (calculations)
- Always convert to appropriate units before comparisons
- Use `_viewboxScale` (500/18 ≈ 27.78 units/km) for scaling

#### 2. Space Requirements
- Minimum space required: 42.0877 viewbox units
- Components:
  - Label height: 12.0877 units
  - Label padding: 5.0 units (each side)
  - Arrow length: 10.0 units (each end)

#### 3. Visibility Logic
```dart
bool hasSufficientSpaceForCHeight(double h1) {
    final double scaledHeight = _getScaledObserverHeight();
    final double observerLevel = _seaLevel - scaledHeight;
    final double availableSpace = _seaLevel - observerLevel;
    return availableSpace >= C_HEIGHT_TOTAL_REQUIRED_HEIGHT;
}
```

### Best Practices

1. **Unit Conversion**
   - Always convert measurements to viewbox units before comparison
   - Use consistent scaling factors throughout
   - Document unit types in method signatures

2. **Space Calculation**
   - Consider both internal and external C_Height space requirements
   - Account for label and arrow spacing
   - Validate available space before rendering

3. **SVG Element Updates**
   - Update all elements of a measurement group together
   - Maintain proper z-index ordering
   - Use group transformations when possible

## Common Issues and Solutions

### 1. Unit Mismatch Issues
- **Problem**: Comparing raw observer height with viewbox units
- **Solution**: Always convert to viewbox units before comparison
```dart
// Incorrect
if (observerHeight >= C_HEIGHT_TOTAL_REQUIRED_HEIGHT) // Comparing meters with viewbox units

// Correct
final double scaledHeight = observerHeight * (_viewboxScale / 500.0);
if (scaledHeight >= C_HEIGHT_TOTAL_REQUIRED_HEIGHT) // Both in viewbox units
```

### 2. Visibility Logic Flow
- **Problem**: Incorrect order of height calculations
- **Solution**: Ensure proper order and unit conversion
```dart
// Incorrect
final double availableSpace = (observerLevel - seaLevel) * scale; // Negative result

// Correct
final double availableSpace = (seaLevel - observerLevel) * scale; // Positive result
```

### 3. Update Sequence
- **Problem**: Race conditions in element updates
- **Solution**: Use atomic updates for measurement groups
```dart
// Recommended pattern
void updateCHeightGroup() {
    final positions = calculatePositions();
    final group = svg.getElementById('C_Height_Group');
    group.setAttributes({
        'transform': `translate(0, ${positions.y})`,
        'opacity': positions.visible ? '1' : '0'
    });
}
```

## References
- [Geometric Model](../technical/geometric_model.md)
- [Diagram Architecture](../technical/diagram_architecture.md)
- [Testing Requirements](../testing/measurement_testing.md)
