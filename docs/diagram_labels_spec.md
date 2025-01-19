# Dynamic SVG Diagram Labels Specification

## SVG Object IDs and Descriptions

| ID | Name | Description | Value Source |
|----|------|-------------|--------------|
| FromTo | Preset Label | Corresponds to the preset label text | Selected preset name |
| HiddenVisible | Visibility State | Indicates object visibility state | Calculated based on target height vs. hidden height (h2) |
| HiddenHeight | Hidden Portion | For target height Z: If Z ≤ h2, equals XZ; If Z > h2, equals XC | Calculation result |
| VisibleHeight | Visible Portion | For target height Z: If Z > h2, equals CZ | Calculation result |
| h1 | Observer Height | Height of observer's eye level | Direct from input field |
| h2 | Hidden Height | Height hidden beyond horizon (XC) | Calculation result |
| LoS_Distance_d0 | Line of Sight | Line of sight distance (D0) AC | Calculation result |
| d1 | Distance to Horizon | Distance from observer (A) to horizon (B) | Calculation result |
| d2 | Horizon to Object Base | Distance from horizon (B) to object base projection (C) | Calculation result |
| L0 | Total Distance | Sea level distance between observer and object | Direct from input field |
| radius | Earth Radius | Earth's radius in km or miles | Based on units: "R = 6,378 km" or "R = 3,963 mi" |

## Visibility States
- "Hidden": Target height < Hidden height (h2)
- "Partially Visible": Target height ≈ Hidden height (h2)
- "Fully Visible": Target height > Hidden height (h2)

## Implementation Plan

### Phase 1: Core Architecture
1. Create base `DiagramViewModel` class
   - Handle common calculations
   - Define shared properties
   - Implement unit conversions

2. Create `HorizonDiagramViewModel` implementation
   - Implement specific horizon diagram calculations
   - Handle label text formatting
   - Manage visibility state logic

3. Create `DiagramService` for SVG manipulation
   - Define label ID mappings
   - Implement SVG text update methods
   - Handle error cases

### Phase 2: Widget Integration
1. Update `DiagramDisplay` widget
   - Integrate with ViewModel
   - Connect to DiagramService
   - Handle state updates

2. Add error handling and loading states
   - Handle null or invalid values
   - Show appropriate placeholder states
   - Implement error messages

### Phase 3: Testing and Validation
1. Unit tests
   - Test calculations
   - Verify visibility logic
   - Validate formatting

2. Widget tests
   - Test SVG updates
   - Verify layout behavior
   - Check error states

### Future Extensions
1. Support for additional diagram types
   - Create new ViewModel implementations
   - Add new label ID mappings
   - Implement specific calculations

2. Enhanced features
   - Animation support
   - Interactive elements
   - Custom styling options

## Notes
- SVG updates will be handled through the Flutter SVG package
- All measurements will support both metric and imperial units
- Diagram selection logic remains in the existing implementation
- Error margins (epsilon) will be used for floating-point comparisons
