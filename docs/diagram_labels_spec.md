# Dynamic SVG Diagram Labels Specification

## SVG Object IDs and Descriptions

| ID | Name | Description | Value Source | Label Format |
|----|------|-------------|--------------|--------------|
| FromTo | Preset Label | Corresponds to the preset label text | Selected preset name | Direct value |
| HiddenVisible | Visibility State | Indicates object visibility state | Calculated based on target height vs. hidden height (h2) | Direct value |
| HiddenHeight | Hidden Portion | For target height Z: If Z ≤ h2, equals XZ; If Z > h2, equals XC | Calculation result | "Hidden Height = [value]" |
| VisibleHeight | Visible Portion | For target height Z: If Z > h2, equals CZ | Calculation result | "Visible Height = [value]" |
| h1 | Observer Height | Height of observer's eye level | Direct from input field | "h₁" |
| h2 | Hidden Height | Height hidden beyond horizon (XC) | Calculation result | "h₂" |
| h3 | Visible Height | Visible portion of target height (CZ) | Calculation result | "h₃" |
| LoS_Distance_d0 | Line of Sight | Line of sight distance (D0) AC | Calculation result | "D₀" |
| d1 | Distance to Horizon | Distance from observer (A) to horizon (B) | Calculation result | "d₁" |
| d2 | Horizon to Object Base | Distance from horizon (B) to object base projection (C) | Calculation result | "d₂" |
| L0 | Total Distance | Sea level distance between observer and object | Direct from input field | "Distance (L0): [value]" with 1 decimal place |
| radius | Earth Radius | Earth's radius in km or miles | Based on units: "R = 6,378 km" or "R = 3,963 mi" | "R = [value]" |

## Visibility States
- "Hidden": Target height < Hidden height (h2)
- "Partially Visible": Target height ≈ Hidden height (h2)
- "Fully Visible": Target height > Hidden height (h2)

## Label Diagram Mapping

Labels may appear in multiple diagram types. Here's the mapping:

### Horizon Diagrams (BTH_1.svg through BTH_4.svg)
- FromTo
- HiddenVisible
- HiddenHeight
- VisibleHeight
- h1, h2, h3
- LoS_Distance_d0
- d1, d2
- L0
- radius

### Mountain Diagram (BTH_viewBox_diagram2.svg)
- FromTo
- HiddenVisible
- HiddenHeight
- VisibleHeight
- Observer_Height_Label
- Visible_Label
- Hidden_Label
- L0

## View Model Label Responsibility

Labels are managed by different view models:

1. **ObserverGroupViewModel**
   - Observer_Height_Label
   - Visible_Label
   - Hidden_Label
   - L0 (used by both diagram types)

2. **HorizonDiagramViewModel**
   - All horizon diagram labels except those from ObserverGroupViewModel

3. **MountainDiagramViewModel**
   - Inherits ObserverGroupViewModel labels
   - Adds mountain-specific labels (FromTo, HiddenVisible, etc.)

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
