# Earth Curve Calculator Terminology Alignment

This document outlines the recommended terminology alignments for future consistency across code, UI, and documentation.

## Geometric Concepts

### Angles
- **Central/Subtended Angle (θ)**: The angle at Earth's center between the observer's position and target
- **Geometric Dip Angle (α)**: The angle between horizontal line of sight and the radius line to target (90° - θ)

### Distances and Heights
- **Arc Distance**: The distance along Earth's surface (currently `totalDistance`)
- **Radial Hidden Height**: Height following Earth's curvature (currently `hiddenHeight`)
- **Geometric Drop/Earth Curvature Drop**: Vertical distance from line of sight to surface point

### Reference Lines
- **Line of Sight/Tangent Plane**: The horizontal line from observer (line ABC)
- **Radius Line**: Line from Earth's center to surface point (OX, extending to C)

## Proposed Code Refactoring

```dart
// Current -> Future
angleAtCenter -> centralAngle or subtendedAngle
complementaryAngle -> geometricDipAngle
hiddenHeight -> radialHiddenHeight
totalDistance -> arcDistance
```

## UI Label Recommendations

- Rename "Hidden Height" to "Radial Hidden Height"
- Add new field "Geometric Drop" (vertical hidden height)
- Include units (km) in all measurements
- Add tooltips explaining each measurement's meaning

## Diagram Annotations

- Label both central angle and geometric dip angle
- Distinguish between vertical drops and radial distances
- Add legend explaining measurement types
- Use consistent color coding for:
  - Horizontal reference lines
  - Earth radius lines
  - Height measurements

## Implementation Priority (Future)

1. Update documentation and comments
2. Modify UI labels and tooltips
3. Refactor code variables and methods
4. Update diagram annotations

Note: These changes should be implemented as a coordinated effort to maintain consistency across all application components.
