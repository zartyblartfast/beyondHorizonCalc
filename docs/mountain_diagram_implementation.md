# Mountain Diagram Implementation Strategy

> For detailed code examples and implementation patterns, see [diagram_modification_guide.md](./diagram_modification_guide.md).

## Current System Analysis

### 1. Core Components
- **DiagramViewModel**: Base class handling unit conversions and formatting
- **HorizonDiagramViewModel**: Specific implementation for horizon calculations
- **DiagramLabelService**: Manages SVG text updates
- **SvgHelper**: Handles SVG loading and basic modifications

### 2. Data Flow
- User inputs → CalculationResult → ViewModel → SVG Updates
- All calculations are in metric (km) and converted for display

### 3. Value Ranges
- Observer Height: 2m to 9000m
- Distance: 5km to 600km
- Target Height: 0m to 9000m

## Implementation Notes

### 1. Coordinate System
- ViewBox specifications and layer structure are detailed in [diagram_modification_guide.md](./diagram_modification_guide.md)
- All drawing operations use viewBox coordinates directly
- Core diagram area is 400x1000 units with additional margin space for labels
- See "Coordinate System and Scaling" in diagram_modification_guide.md for details

### 2. Dynamic Range Mapping

#### Input Variables
- Observer Height (h₁)
- Total Distance (L₀)
- Target Height (optional)
- Hidden Height (h₂) - calculated
- Visible Height (h₃) - calculated

#### Key Considerations
1. **Dynamic Adjustments**
   - Mountain position changes with input values
   - Need to maintain visibility within viewBox
   - Maintain visual clarity at extreme values

2. **Scale Factors**
   - Different scales needed for different measurement types
   - Height scale vs Distance scale
   - Perspective considerations

## Future Enhancements
1. Add debug overlay option for coordinate visualization
2. Document edge cases and their handling
3. Maintain flexibility for future diagram enhancements
