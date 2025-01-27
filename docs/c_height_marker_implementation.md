# C-Height Marker Implementation Plan

## Overview
Add dynamic height measurement marker to BTH_viewBox_diagram2.svg consisting of three elements:
1. Top arrow (2_1_C_Top_arrow)
2. Height label (2_2_C_Height)
3. Bottom arrow (2_3_C_Bottom_arrow)

## Requirements
- Fixed x-coordinate at -250 for all elements
- Dynamic vertical positioning based on actual Observer Height (h1) value
- Label text format: "h1: [value]" using Observer Height input
- Arrows must scale with h1 height changes
- Must maintain visual styling from original SVG
- Hide all three elements if insufficient space for display

## Visibility Rules
- All three elements (2_1, 2_2, 2_3) are treated as a single unit
- If insufficient space exists between C_Point_Line and Observer_Height_Above_Sea_Level:
  - Hide all three elements
  - No partial display or alternative layouts in stage 1

## SVG Element Specifications

### Text Label (2_2_C_Height)
```
style="font-style:normal;
       font-variant:normal;
       font-weight:bold;
       font-stretch:normal;
       font-size:12.0877px;
       font-family:Calibri;
       text-align:start;
       fill:#552200"
```

### Top Arrow (2_1_C_Top_arrow)
```
stroke="#000000"
stroke-width="1.99598"
```

### Top Arrowhead (2_1_C_Top_arrowhead)
```
style="fill:#000000;stroke:none;fill-opacity:1"
d="m -229.47326,349.35208 l -5,10 l 10,0 z"
```

### Bottom Arrow (2_3_C_Bottom_arrow)
```
stroke="#000000"
stroke-width="2.07704"
```

### Bottom Arrowhead (2_3_C_Bottom_arrowhead)
```
style="fill:#000000;stroke:none;fill-opacity:1"
d="m -229.48734,465.97393 l -5,-10 l 10,0 z"
```

## Dynamic Positioning System

### Base Reference
- Sea level (`_seaLevel`) serves as the primary datum line
- All vertical positions are calculated relative to sea level
- Positions in SVG file are NOT absolute - they are dynamically updated based on user inputs
- Only x-coordinates remain fixed for vertical alignment

### Position Calculation
1. Observer height (h1) from user input is converted to viewbox units using `_getScaledObserverHeight()`
2. Final vertical position is calculated as `_seaLevel - scaledHeight`
3. All elements in the observer group are positioned relative to this calculated level
4. ObserverGroupViewModel handles all position updates when user inputs change

### Implementation Notes
- When adding new elements to observer group:
  - Define fixed x-coordinate for vertical alignment
  - Use relative positioning from observer level
  - Elements will automatically move with observer height changes
  - Group related elements (e.g., arrow and arrowhead) to maintain their relationship

## Implementation Steps

### 1. Update diagram_spec.json
Add new measurement group for C-height marker:
```json
{
  "layers": {
    "measurements": {
      "c_height_marker": {
        "elements": [
          {
            "id": "2_1_C_Top_arrow",
            "type": "path",
            "behavior": "dynamic",
            "style": {
              "stroke": "#000000",
              "strokeWidth": 1.99598
            },
            "position": {
              "x": -250,
              "y": {
                "reference": "Observer Height (h1)",
                "visibility": "dependent"
              }
            }
          },
          {
            "id": "2_1_C_Top_arrowhead",
            "type": "path",
            "behavior": "dynamic",
            "style": {
              "fill": "#000000",
              "stroke": "none",
              "fillOpacity": 1
            },
            "d": "m -229.47326,349.35208 l -5,10 l 10,0 z",
            "position": {
              "x": -250,
              "y": {
                "reference": "Observer Height (h1)",
                "visibility": "dependent"
              }
            }
          },
          {
            "id": "2_2_C_Height",
            "type": "text",
            "style": {
              "fontFamily": "Calibri",
              "fontSize": "12.0877px",
              "fontWeight": "bold",
              "fill": "#552200",
              "textAnchor": "middle"
            },
            "content": {
              "prefix": "h1: ",
              "value": {
                "source": "Observer Height (h1)",
                "format": {
                  "type": "distance",
                  "decimalPlaces": 1,
                  "includeUnits": true
                }
              }
            },
            "position": {
              "x": -250,
              "y": {
                "reference": "Observer Height (h1)",
                "visibility": "dependent"
              }
            }
          },
          {
            "id": "2_3_C_Bottom_arrow",
            "type": "path",
            "behavior": "dynamic",
            "style": {
              "stroke": "#000000",
              "strokeWidth": 2.07704
            },
            "position": {
              "x": -250,
              "y": {
                "reference": "Observer Height (h1)",
                "visibility": "dependent"
              }
            }
          },
          {
            "id": "2_3_C_Bottom_arrowhead",
            "type": "path",
            "behavior": "dynamic",
            "style": {
              "fill": "#000000",
              "stroke": "none",
              "fillOpacity": 1
            },
            "d": "m -229.48734,465.97393 l -5,-10 l 10,0 z",
            "position": {
              "x": -250,
              "y": {
                "reference": "Observer Height (h1)",
                "visibility": "dependent"
              }
            }
          }
        ],
        "visibility": {
          "condition": "sufficient_space",
          "minimumSpace": "TOTAL_REQUIRED_HEIGHT",
          "behavior": "all_or_none"
        }
      }
    }
  }
}
```

### 2. Code Changes Required

#### DiagramViewModel Updates
- Add calculations for:
  - Vertical positions based on Observer Height (h1)
  - Space availability check
  - Visibility state management

#### DiagramLabelService Updates
- Add methods for:
  - Updating arrow path data with proper stroke and marker attributes
  - Positioning and styling text label
  - Handling visibility state

#### Calculations
```dart
// Constants
const double LABEL_HEIGHT = 12.0877;
const double LABEL_PADDING = 5.0;
const double ARROW_MIN_LENGTH = 10.0;
const double TOTAL_REQUIRED_HEIGHT = LABEL_HEIGHT + (2 * LABEL_PADDING) + (2 * ARROW_MIN_LENGTH);

// Visibility check
bool hasEnoughSpace(double h1) {
  return h1 >= TOTAL_REQUIRED_HEIGHT;
}

// Calculate positions
void calculatePositions(double h1) {
  if (!hasEnoughSpace(h1)) {
    setElementsVisible(false);
    return;
  }
  
  setElementsVisible(true);
  
  // Calculate positions relative to h1
  final labelY = h1 / 2;
  final topArrowEnd = labelY - (LABEL_HEIGHT / 2) - LABEL_PADDING;
  final bottomArrowStart = labelY + (LABEL_HEIGHT / 2) + LABEL_PADDING;
}
```

### 3. Implementation Details and Lessons Learned

### 1. SVG Marker Limitations
- flutter_svg does not support SVG markers (marker-end, marker-start)
- Instead of using markers, create explicit arrowhead paths for each arrow
- Arrowheads must be positioned dynamically with their parent arrows
- Example arrowhead path:
  ```
  M -250,342 l -4,-4 l 8,4 l -8,4 z
  ```

### 2. Dynamic Positioning
- Arrowheads are positioned relative to their parent arrows
- Top arrowhead points upward from arrow end
- Bottom arrowhead points downward from arrow end
- Both arrows and arrowheads use the same x-coordinate (-250)
- Y-coordinates are calculated based on observer height (h1)

### 3. Configuration in diagram_spec.json
- Add arrowhead configurations in the same group as their parent arrows
- Example arrowhead configuration:
  ```json
  {
    "id": "2_1_C_Top_arrowhead",
    "type": "path",
    "behavior": "dynamic",
    "style": {
      "fill": "#000000",
      "stroke": "none"
    }
  }
  ```

### 4. Visibility Management
- Arrowheads follow same visibility rules as their parent arrows
- All elements (arrows, arrowheads, label) are treated as a single unit
- Use ObserverGroupViewModel.hasSufficientSpaceForCHeight() to check space
- Hide all elements if insufficient space between C_Point_Line and Observer_Height_Above_Sea_Level

### 5. Reference Line Extensions
- Horizontal reference lines (C_Point_Line, Observer_SL_Line) must extend to x=-275
- These lines are managed dynamically in ObserverGroupViewModel.updateSvg()
- Do not rely on static paths in diagram_spec.json for these lines
- Example path format:
  ```dart
  'd': 'M -275,$observerLevel L 200,$observerLevel'
  ```

### Lessons for Future Tasks (3_1, 3_2, 3_3)
1. Arrowhead Implementation:
   - Create explicit arrowhead paths instead of using markers
   - Position arrowheads dynamically with parent arrows
   - Keep arrowheads in same group as parent arrows

2. Dynamic Positioning:
   - Use ObserverGroupViewModel for dynamic updates
   - Calculate positions based on relevant inputs (h1, distance, etc.)
   - Maintain consistent x-coordinates for vertical alignment

3. Configuration:
   - Add new elements to diagram_spec.json
   - Group related elements together
   - Include style configurations
   - Set behavior as "dynamic" for elements that move

4. Visibility:
   - Group related elements for consistent visibility
   - Implement visibility checks in ObserverGroupViewModel
   - Hide all related elements as a unit

5. Reference Lines:
   - Extend horizontal lines to x=-275 in ObserverGroupViewModel
   - Keep dynamic y-coordinates for proper positioning
   - Use consistent line styles and stroke widths

## Known Limitations and Future Improvements

#### Current Visibility Handling Issues
- When insufficient space is detected, elements (2_1, 2_2, 2_3, and arrowheads) may revert to default positions
- Default positions come from either diagram_spec.json or the original SVG file
- This creates undesirable visual artifacts when space is constrained
- Current visibility toggle doesn't prevent position reversion

#### Planned Improvements
1. Alternative Layout for Constrained Space:
   - Instead of making elements invisible, implement external positioning
   - Invert arrow lines to appear outside of C_Point_Line
   - Position label externally for better visibility
   - This approach maintains measurement visibility while avoiding overlap

2. Implementation Considerations for External Layout:
   - Need to calculate alternative positions based on available space
   - Consider both above and below placement options
   - Maintain consistent styling and arrow directions
   - Ensure label remains readable in external position

3. Future Tasks:
   - Implement proper position retention when visibility is toggled
   - Add logic for external layout positioning
   - Create smooth transition between internal/external layouts
   - Update visibility check to consider external layout option

This improved approach will be particularly relevant for implementing similar measurement markers (3_1, 3_2, 3_3) where space constraints may also be an issue.

## Implementation Order
1. Update diagram_spec.json with new measurement group
2. Add visibility check and position calculations to DiagramViewModel
3. Implement label and arrow update methods in DiagramLabelService
4. Add tests focusing on visibility behavior
5. Manual testing with various h1 values

## Testing Plan

#### Functional Testing
1. Verify visibility behavior:
   - Test with h1 values below minimum required height
   - Verify all elements hide/show together
   - Check transitions at threshold values

2. Style Verification:
   - Arrow stroke widths
   - Arrow markers
   - Text font and color
   - Text alignment and centering

#### Visual Testing
1. Verify dynamic updates:
   - Smooth movement with h1 changes
   - Proper scaling of arrows
   - Text remains centered and readable
   - Arrow heads remain properly oriented
   - Clean transitions when hiding/showing

2. Verify text formatting:
   - Correct prefix "h1: "
   - Value matches Observer Height input
   - Units displayed correctly
   - Text alignment and spacing

### SVG Element Visibility Handling

#### Key Implementation Details
1. Different SVG Element Types:
   - Path elements (arrows, arrowheads): Only need visibility attribute
   - Text elements (labels): Need ALL attributes set in both visible and hidden states
   - Reason: Text elements retain their last position if not explicitly set

2. Visibility State Management:
   ```dart
   // For path elements (arrows, arrowheads)
   {'visibility': 'hidden'}  // Sufficient for paths

   // For text elements (labels)
   {
     'x': '$xCoord',
     'y': '$yCoord',
     'style': 'text-anchor:middle;fill:#552200',
     'visibility': 'hidden'
   }  // Must set ALL attributes
   ```

3. Common Pitfalls:
   - Setting only visibility for text elements causes them to revert to default positions
   - Different SVG element types need different attribute handling
   - Position attributes must be consistent between visible and hidden states

#### Best Practices for Future Tasks (3_1, 3_2, 3_3)
1. Element Visibility:
   - Always set complete attributes for text elements in both states
   - Use the same x-coordinate in both visible and hidden states
   - Choose a safe y-coordinate for hidden state (e.g., start or end position)

2. Code Organization:
   - Group element updates by type (text vs path)
   - Maintain consistent attribute sets between states
   - Use constants for shared values (x-coordinates, styles)

3. Testing Visibility:
   - Test both showing and hiding transitions
   - Verify text elements maintain position when hidden
   - Check all elements in group hide/show together

4. Error Prevention:
   - Always set complete attribute sets for text elements
   - Use consistent coordinate variables across visibility states
   - Document any element-specific handling requirements

This approach ensures reliable visibility toggling while maintaining proper element positioning, particularly important for text elements in the diagram.
