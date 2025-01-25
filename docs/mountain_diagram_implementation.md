# Mountain Diagram Implementation Strategy

> For detailed code examples and implementation patterns, see [diagram_modification_guide.md](./diagram_modification_guide.md).

## Current System Analysis

### 1. Core Components
- **DiagramViewModel**: Base class handling unit conversions and formatting
- **HorizonDiagramViewModel**: Specific implementation for horizon calculations
- **DiagramLabelService**: Manages SVG text updates
- **SvgHelper**: Handles SVG loading and basic modifications

### 2. View Model Hierarchy and Responsibilities

#### Base Classes
- **DiagramViewModel**: Provides common utilities like formatDistance() (1 decimal place) and formatHeight()
- **DiagramLabelService**: Handles SVG text updates while preserving attributes

#### Specific View Models
1. **ObserverGroupViewModel**
   - Primary owner of observer-related labels
   - Provides L0 label for both diagram types
   - Format: "Distance (L0): [value]" with 1 decimal place

2. **HorizonDiagramViewModel**
   - Handles BTH_1.svg through BTH_4.svg
   - Manages horizon-specific calculations and labels
   - Uses ObserverGroupViewModel for some labels

3. **MountainDiagramViewModel**
   - Handles BTH_viewBox_diagram2.svg
   - Uses ObserverGroupViewModel for observer labels
   - Adds mountain-specific labels and calculations

### 3. Data Flow
- User inputs → CalculationResult → ViewModel → SVG Updates
- All calculations are in metric (km) and converted for display

### 4. Value Ranges
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
