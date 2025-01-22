# Mountain Diagram Implementation Strategy

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

## Coordinate Mapping Challenges

### 1. ViewBox Specifications
- X-axis: -200 to +200 (400 units wide)
- Y-axis: 0 to 1000 (1000 units high)
- Origin (0,0) at top center
- Vertical-centric design

### 2. Dynamic Range Mapping Considerations

#### Input Variables
- Observer Height (h₁)
- Total Distance (L₀)
- Target Height (optional)
- Hidden Height (h₂) - calculated
- Visible Height (h₃) - calculated

#### Mapping Challenges
1. **Vertical Space Requirements**
   - Mountain base position varies with distance
   - Hidden portion (h₂) affects visible structure
   - Need to maintain proportional relationships

2. **Scale Factors**
   - Different scales needed for different measurement types
   - Height scale vs Distance scale
   - Perspective considerations

3. **Dynamic Adjustments**
   - Mountain position changes with input values
   - Need to maintain visibility within viewbox
   - Maintain visual clarity at extreme values

### 3. Proposed Mapping Strategy

#### Coordinate Zones
1. **Sky Zone** (y: 0-342)
   - Reserved for labels and upper diagram elements
   - Fixed position elements

2. **Horizon Zone** (y: 342-474)
   - Critical reference area
   - Contains horizon line and observer reference points

3. **Mountain Zone** (y: 474-1000)
   - Dynamic area for mountain representation
   - Must accommodate various mountain heights and positions
   - Includes opacity overlay for hidden portions

#### Scale Calculations
1. **Height Scale**
   ```
   heightScale = availableVerticalSpace / maxPossibleHeight
   where:
   - availableVerticalSpace = mountainZoneHeight
   - maxPossibleHeight = calculated based on max target height and position
   ```

2. **Distance Scale**
   ```
   distanceScale = availableHorizontalSpace / maxDistance
   where:
   - availableHorizontalSpace = viewbox width (400 units)
   - maxDistance = 600km (maximum input distance)
   ```

## Implementation Recommendations

### 1. New Components Needed
- **MountainDiagramViewModel**
  - Handles mountain-specific calculations
  - Manages coordinate mapping
  - Controls opacity layers

- **CoordinateMapper**
  - Dedicated class for value-to-coordinate conversions
  - Handles scale calculations
  - Maintains mapping consistency

### 2. Validation Requirements
- Pre-calculation validation
- Coordinate boundary checks
- Scale factor validation

### 3. Testing Strategy
- Unit tests for coordinate mapping
- Visual tests for extreme values
- Integration tests for complete diagram updates

## Next Steps
1. Update diagram_spec.json with coordinate mapping details
2. Create coordinate mapping test cases
3. Implement CoordinateMapper class
4. Extend current ViewModel system
5. Add new label management for mountain elements

## Notes
- Consider adding debug overlay option for coordinate visualization
- Document edge cases and their handling
- Maintain flexibility for future diagram enhancements
