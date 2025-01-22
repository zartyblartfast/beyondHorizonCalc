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

## Implementation Strategy

### 1. Configuration Structure
- JSON-based configuration for all diagram groups
- Separate scaling configurations for Observer and Mountain
- Flexible framework for future adjustments

### 2. Scaling Implementation

#### Phase 1: Observer Group
- Sea level reference at y=500
- Linear scaling for observer height
- ViewBox range 250-500 for height representation
- Scale factor computation based on validation ranges

#### Phase 2: Mountain Group (Planned)
- Base position range: y=100 to 900
- Width range: x=-90 to +90
- Height scale range: y=50 to 900
- Perspective scaling reserved for future implementation

### 3. Class Structure

#### DiagramScaling
- Base class managing overall scaling factors
- Configurable scale adjustments
- Group-specific scaling implementations

#### ObserverScaling
- Handles Observer group coordinate mapping
- Uses validation ranges for scale computation
- Linear scaling with configurable factors

#### Future: MountainScaling
- Will handle mountain position and size
- Dynamic perspective adjustments
- Scale factor adjustments based on distance

### 4. Benefits of Approach
- Separation of configuration and logic
- Flexible scaling framework
- Easy adjustment of reference points
- Maintainable and extensible structure
- Group-specific scaling control

### 5. Next Steps
1. Implement Observer group scaling
2. Test with various input ranges
3. Validate visual representation
4. Plan Mountain group implementation
5. Consider perspective scaling requirements

## Observer Group Structure

### Objects and Relationships

#### 1. Primary Reference Elements
- **Observer_SL_Line** (Sea Level Line):
  * Primary datum line
  * Horizontal line spanning full width
  * Position at y=500 in viewbox
  * All other elements positioned relative to this

- **Observer_Height_Above_Sea_Level**:
  * Vertical line representing h1
  * Bottom anchored to Observer_SL_Line
  * Length determined by scaled h1 value
  * Key dynamic element

#### 2. Secondary Elements
- **C_Point_Line**:
  * Horizontal line spanning full width
  * Position determined by top of Observer_Height_Above_Sea_Level
  * Acts as horizon reference line

- **dot** (ellipse):
  * Centered on top of Observer_Height_Above_Sea_Level
  * Represents observer's eye position

#### 3. Labels
- **h1_label**:
  * Positioned midway along Observer_Height_Above_Sea_Level
  * Moves to maintain center position as h1 changes

- **A, B, C points**:
  * Aligned horizontally with C_Point_Line
  * Move vertically with C_Point_Line as h1 changes

- **Visible_Label & Hidden_Label**:
  * Position relative to C_Point_Line
  * Move vertically as h1 changes

#### 4. Opacity Mask
- **Beyond_Horizon_Hidden**:
  * Top edge anchored to and moves with C_Point_Line
  * Bottom edge fixed at viewbox bottom (y=1000)
  * Height adjusts dynamically (1000 - C_Point_Line y-position)
  * Width spans full diagram
  * Creates opacity mask for elements below horizon

### Dynamic Behavior

When Observer Height (h1) changes:
1. Observer_Height_Above_Sea_Level adjusts length based on scaled h1
2. C_Point_Line moves to new top position of Observer_Height_Above_Sea_Level
3. dot moves with top of Observer_Height_Above_Sea_Level
4. All labels maintain relative positions to their reference elements
5. Beyond_Horizon_Hidden:
   * Top edge follows C_Point_Line's new position
   * Height automatically adjusts to maintain bottom at y=1000
   * Ensures consistent opacity masking below horizon

### Key Positioning References
All elements position relative to either:
- The datum (Observer_SL_Line)
- The scaled height line (Observer_Height_Above_Sea_Level)
- The horizon line (C_Point_Line)

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
