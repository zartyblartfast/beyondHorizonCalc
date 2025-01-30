# Beyond Horizon Calculator - Measurement Groups

## Overview
The Beyond Horizon Calculator uses measurement groups to display various height calculations in the diagram. Each measurement group represents a specific height calculation (visible height, hidden height, etc.) and follows consistent implementation patterns while maintaining its unique characteristics.

## Key Concepts

### What is a Measurement Group?
A measurement group is a collection of SVG elements that work together to display a height measurement on the diagram. Each group typically consists of:
- Arrow markers indicating start and end points
- A text label showing the measurement value
- Specific datum lines it measures between

### Types of Measurements
1. **Visible Height (h3)**
   - Measures visible portion of target
   - Between Z_Point_Line and C_Point_Line
   - Displayed in meters/feet

2. **Hidden Height (h2)**
   - Measures hidden portion due to Earth's curvature
   - Between Distant_Obj_Sea_Level and C_Point_Line
   - Critical for understanding target visibility

3. **Z-Height (XZ)**
   - Total target height
   - From target base to peak
   - Used in visibility calculations

4. **C-Height (h1)**
   - Observer height above sea level
   - Affects visibility calculations
   - Influences hidden height calculations

## Documentation Structure

### Implementation
- [Measurement Group Implementation Guide](implementation/measurement_group_guide.md)
  - Step-by-step implementation process
  - Best practices and common pitfalls
  - Code patterns and examples

### Examples
- [V_Height Example](implementation/examples/v_height_example.md)
- [H_Height Example](implementation/examples/h_height_example.md)
- [Z_Height Example](implementation/examples/z_height_example.md)
- [C_Height Example](implementation/examples/c_height_example.md)

### Technical Reference
- [Coordinate System](technical/coordinate_system.md)
- [Datum Lines](technical/datum_lines.md)
- [Measurement Types](technical/measurement_types.md)

### Testing
- [Testing Guide](testing/measurement_testing_guide.md)

## Getting Started
1. Read the [Measurement Group Implementation Guide](implementation/measurement_group_guide.md)
2. Review relevant example implementations
3. Understand the coordinate system and datum lines
4. Follow testing guidelines for validation

## Best Practices Summary
1. Always verify datum lines before implementation
2. Consider ViewBox coordinate system (0,0 at top-left)
3. Maintain consistent x-coordinates for vertical alignment
4. Handle null values and edge cases
5. Follow established naming conventions
6. Implement comprehensive error handling

## Related Resources
- [diagram_spec.json](../assets/info/diagram_spec.json) - Configuration reference
- [MountainGroupViewModel](../lib/widgets/calculator/diagram/mountain_group_view_model.dart) - Implementation reference
