# Geometric Model Reference

> **Note**: This document provides detailed technical implementation of the geometric model. For a high-level introduction to the core concepts and basic definitions, please see [diagram_explanation.md](../../diagram_explanation.md) first.

## Overview
This document details the geometric model and mathematical relationships underlying the Beyond Horizon Calculator. It serves as the foundational reference for implementing measurement calculations and diagram features.

## Core Geometric Elements

### 1. Earth Model
- **Center (O)**: Origin of the geometric model
- **Radius (R)**: Earth's radius (≈ 6371 km)
- **Surface Points**: All points on Earth's surface are at distance R from O
  ```
  OB = OX = R
  ```

### 2. Observer Position
- **Point A**: Observer's eye-level position
- **Height h₁**: Observer's height above sea level
- **Distance from Center**: 
  ```
  OA = R + h₁
  ```

### 3. Horizon Definition
- **Point B**: Horizon point on Earth's surface
- **Properties**:
  - Line AB is tangent to Earth's surface
  - Angle OBA = 90° (right angle)
  - AB defines line of sight to horizon

### 4. Target Object
- **Base (X)**: Point on Earth's surface (OX = R)
- **Top (Z)**: Highest point of target
- **Height (XZ)**: Total vertical height
- **Position**: Beyond horizon from observer's perspective

### 5. Line of Sight Intersection
- **Point C**: Where observer's line of sight meets target
- **Hidden Height (XC = h₂)**: Portion below horizon
- **Visible Height (CZ = h₃)**: Portion above horizon

### 6. Distance Measurements
- **Surface Distance (L₀)**: Total distance at sea level from observer to target
- **Straight-line Distance**: Direct distance through Earth (not used in calculations)
- **Arc Distance**: Following Earth's curvature (used for accurate measurements)

## Mathematical Relationships

### 1. Height Relationships
```
Total Height (XZ) = Hidden Height (h₂) + Visible Height (h₃)
XZ = XC + CZ
```

### 2. Distance Calculations
```
Arc Distance = R × θ
where θ is the angle AOX in radians
```

### 3. Hidden Height Formula
```
h₂ = f(L₀, h₁)
where:
- L₀ is surface distance
- h₁ is observer height
```

### 4. Perspective Adjustments
- **Apparent Height (CD)**: Perpendicular to horizon line BC
- **Relationship**: CD < CZ due to perspective
- **Angle Factor**: cos(α) where α is the angle between CZ and CD

## Implementation in Diagram

### 1. Coordinate System Integration
- Origin at top-left of SVG viewBox
- Y increases downward
- Scaled to maintain proportions
- See [Coordinate System Guide](coordinate_system.md)

### 2. Measurement Groups
Each measurement represents a specific geometric relationship:
1. **C-Height (h₁)**:
   - Observer height above sea level
   - Direct measurement of OA - R

2. **H-Height (h₂)**:
   - Hidden portion due to Earth's curvature
   - Calculated from L₀ and h₁
   - See [H-Height Example](../implementation/examples/h_height_example.md)

3. **V-Height (h₃)**:
   - Visible portion above horizon
   - CZ in geometric model
   - See [V-Height Example](../implementation/examples/v_height_example.md)

4. **Z-Height (XZ)**:
   - Total target height
   - Sum of h₂ and h₃
   - See [Z-Height Example](../implementation/examples/z_height_example.md)

### 3. Datum Lines
Each measurement uses specific geometric points as reference:
- See [Datum Lines Guide](datum_lines.md) for implementation details

## Calculations in Code

### 1. Hidden Height Calculation
```dart
double calculateHiddenHeight(double distance, double observerHeight) {
  // Convert to kilometers
  final distanceKm = distance / 1000.0;
  final observerHeightKm = observerHeight / 1000.0;
  
  // Calculate using Earth's curvature
  return calculateEarthCurvature(distanceKm, observerHeightKm);
}
```

### 2. Visible Height Calculation
```dart
double calculateVisibleHeight(double totalHeight, double hiddenHeight) {
  return max(0.0, totalHeight - hiddenHeight);
}
```

### 3. Distance Scaling
```dart
double scaleToViewBox(double realWorldValue) {
  return realWorldValue * viewBoxScale;
}
```

## Common Use Cases

### 1. Target Beyond Horizon
```
if (L₀ > horizonDistance) {
  h₂ > 0  // Part of target hidden
  h₃ < XZ // Not fully visible
}
```

### 2. Target Within Horizon
```
if (L₀ ≤ horizonDistance) {
  h₂ = 0   // Nothing hidden
  h₃ = XZ  // Fully visible
}
```

### 3. Target Fully Hidden
```
if (h₂ ≥ XZ) {
  h₃ = 0  // No visible portion
}
```

## Related Documentation
- [Coordinate System Guide](coordinate_system.md)
- [Datum Lines Reference](datum_lines.md)
- [Measurement Types Guide](measurement_types.md)
- [Implementation Examples](../implementation/examples/)
- [Diagram Explanation](../../diagram_explanation.md)
