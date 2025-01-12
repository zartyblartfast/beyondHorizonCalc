# Earth Curvature Calculation Methods

This document explains the two primary methods for calculating hidden height due to Earth's curvature.

## Method 1: Parabolic Approximation
### Formula: `h = d²/(2R)`
where:
- h = hidden height
- d = distance
- R = Earth's radius (adjusted for refraction)

### Characteristics
1. **Mathematical Simplicity**: Direct application of geometric principles
2. **Computational Efficiency**: Requires only basic arithmetic operations
3. **Industry Usage**: Common in surveying and engineering for quick calculations
4. **Approximation**: Uses parabolic approximation of Earth's curve

### Limitations
- Assumes small angles (parabolic approximation)
- Less accurate for longer distances
- Does not account for true spherical geometry

## Method 2: Trigonometric Method
### Formula: `h = R/cos(θ) - R`
where:
- h = hidden height
- R = Earth's radius (adjusted for refraction)
- θ = arc angle = 2π * (l2/C)
- l2 = total_distance - horizon_distance
- C = Earth's circumference

### Characteristics
1. **Exact Trigonometry**: No small-angle approximation
2. **Full Curvature**: Accounts for Earth's complete spherical shape
3. **Arc Length**: Uses true surface distance along Earth's curve
4. **Higher Accuracy**: More precise results, especially at longer distances

### Implementation Considerations
1. **Computational Complexity**: Requires more trigonometric operations
2. **Precision Requirements**: Needs careful handling of floating-point operations
3. **Range Validity**: Valid for all reasonable Earth-surface distances

## Accuracy Comparison

The trigonometric method (Method 2) is mathematically more rigorous and will never be less accurate than the parabolic approximation. While both methods give similar results over shorter distances, the trigonometric method becomes noticeably more accurate over longer distances as it properly accounts for the Earth's spherical geometry.

The difference becomes particularly noticeable when:
1. Calculating over longer distances
2. High precision is required
3. Working with scenarios where the cumulative effect of Earth's curvature is significant

## Implementation Note

The calculator uses the Earth's radius adjusted for atmospheric refraction:
```
Effective_Radius = Earth_Radius * refraction_factor
```
where the typical refraction factor is 1.07, accounting for the way light bends through the atmosphere.

## References
1. Surveying Engineering & Instruments, 7th Ed.
2. Geodesy: Introduction to Geodetic Datum and Geodetic Systems
3. NOAA Technical Memorandum NOS NGS-61
