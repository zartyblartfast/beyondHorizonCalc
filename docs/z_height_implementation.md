# Z-Height Implementation Guide

## Components
The Z-Height measurement consists of five elements in fixed vertical order, with fixed arrowhead positions and orientations:
1. Top arrowhead (3_1_Z_Height_Top_arrowhead) - always at top, pointing upward
2. Top arrow (3_1_Z_Height_Top_arrow)
3. Height label (3_2_Z_Height)
4. Bottom arrow (3_3_Z_Height_Bottom_arrow)
5. Bottom arrowhead (3_3_Z_Height_Bottom_arrowhead) - always at bottom, pointing downward

## Overview
Implement dynamic height measurement for the mountain's total height (XZ) in BTH_viewBox_diagram2.svg. The five elements must maintain their vertical order and work together as a unit:
- Upper section: Upward-pointing arrowhead at top with its arrow (3_1_Z_Height_Top_arrowhead, 3_1_Z_Height_Top_arrow)
- Middle: Height label (3_2_Z_Height)
- Lower section: Arrow with downward-pointing arrowhead at bottom (3_3_Z_Height_Bottom_arrow, 3_3_Z_Height_Bottom_arrowhead)

## Mountain Group Context
- Part of the Mountain layer in the diagram's vertical structure
- Uses mountain-specific scaling (600 units = 18km)
- Positioned dynamically based on calculation results
- Reference points are Z_Point_Line and Distant_Obj_Sea_Level
- All elements must move together as the mountain height changes

## Geometric Model Integration
- Z point: Mountain top (highest point of the target object)
- X point: Mountain base at sea level
- XZ: Total vertical height of the mountain
- Relationship to h2/XC (hidden height below horizon)
- All measurements relative to mountain's actual position

## Requirements
- Fixed x-coordinate at 325 for all elements
- Dynamic vertical positioning based on:
  - Top anchor: Z_Point_Line (mountain top)
  - Bottom anchor: Distant_Obj_Sea_Level (mountain base)
- Label text format: "Z: [value]" using total mountain height
- Elements must scale with height changes
- Must maintain visual styling from original SVG
- Hide all elements if insufficient space for display

## SVG Element Specifications
The arrowheads have fixed orientations that must be preserved:

### Top Arrowhead (3_1_Z_Height_Top_arrowhead)
```
style="fill:#000000;fill-opacity:1;stroke:none"
d="m 324.75543,244.95184 -5,10 h 10 z"  # Always points upward
```

### Top Arrow (3_1_Z_Height_Top_arrow)
```
stroke="#000000"
stroke-width="2.43608"
```

### Text Label (3_2_Z_Height)
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

### Bottom Arrow (3_3_Z_Height_Bottom_arrow)
```
stroke="#000000"
stroke-width="2.46886"
```

### Bottom Arrowhead (3_3_Z_Height_Bottom_arrowhead)
```
style="fill:#000000;fill-opacity:1;stroke:none"
d="m 324.80065,548.10056 -5,-10 h 10 z"  # Always points downward
```

## Implementation Details

### 1. Configuration in diagram_spec.json
All five elements require configuration:
```json
{
  "mountain_group": {
    "z_height": {
      "elements": {
        "3_1_Z_Height_Top_arrowhead": {
          "type": "path",
          "behavior": "dynamic"
        },
        "3_1_Z_Height_Top_arrow": {
          "type": "path",
          "behavior": "dynamic"
        },
        "3_2_Z_Height": {
          "type": "text",
          "behavior": "dynamic"
        },
        "3_3_Z_Height_Bottom_arrow": {
          "type": "path",
          "behavior": "dynamic"
        },
        "3_3_Z_Height_Bottom_arrowhead": {
          "type": "path",
          "behavior": "dynamic"
        }
      }
    }
  }
}
```

### 2. Dynamic Positioning
- Use MountainGroupViewModel for dynamic updates
- Calculate positions based on total mountain height
- Center label between arrows with proper padding
- Account for arrowhead lengths when calculating arrow line endpoints
- Example calculations:
```dart
// Constants
const double LABEL_HEIGHT = 12.0877;
const double LABEL_PADDING = 5.0;
const double ARROW_MIN_LENGTH = 10.0;
const double X_COORDINATE = 325.0;
const double ARROWHEAD_HEIGHT = 10.0;  // Height of the triangular arrowhead

// Calculate positions for all elements
void calculatePositions(double mountainHeight) {
  if (!hasEnoughSpace(mountainHeight)) {
    setElementsVisible(false);
    return;
  }
  
  setElementsVisible(true);
  
  // Calculate positions relative to mountain height
  final topArrowheadY = mountainTop;
  // Top arrow starts at arrowhead base, ends at label
  final topArrowStartY = topArrowheadY + ARROWHEAD_HEIGHT;
  final labelY = mountainTop + (mountainHeight / 2);
  final topArrowEndY = labelY - (LABEL_HEIGHT / 2) - LABEL_PADDING;
  
  // Bottom arrow starts at label, ends at arrowhead tip
  final bottomArrowStartY = labelY + (LABEL_HEIGHT / 2) + LABEL_PADDING;
  final bottomArrowheadY = mountainBase;
  final bottomArrowEndY = bottomArrowheadY - ARROWHEAD_HEIGHT;
  
  // Ensure minimum arrow lengths including arrowheads
  if ((topArrowEndY - topArrowStartY) < ARROW_MIN_LENGTH ||
      (bottomArrowEndY - bottomArrowStartY) < ARROW_MIN_LENGTH) {
    setElementsVisible(false);
    return;
  }
}

### 3. Visibility Management
- All five elements treated as a single unit
- Use MountainGroupViewModel.hasSufficientSpaceForZHeight() to check space
- Hide all elements if insufficient space between reference points

## Key Differences from C_Height Implementation
1. **Reference Points**:
   - Uses mountain group datum lines instead of observer group
   - Top anchor is Z_Point_Line (mountain top)
   - Bottom anchor is Distant_Obj_Sea_Level (sea level)

2. **Positioning**:
   - Fixed x-coordinate at 325 (vs -250 for C_Height)
   - Different base points for dynamic positioning
   - Vertical scaling based on actual mountain height

3. **Group Context**:
   - Part of mountain group rather than observer group
   - Uses MountainGroupViewModel instead of ObserverGroupViewModel
   - Scaling factor: 600 viewbox units = 18km

## Important Implementation Notes
1. Maintain consistent x-coordinate (325) for all five elements
2. Preserve the fixed vertical order as defined in Components
3. Top arrowhead must always be at the top and point upward
4. Bottom arrowhead must always be at the bottom and point downward
5. Label should be centered between arrows both horizontally and vertically
6. All elements should scale proportionally with mountain height changes
7. Ensure proper z-index ordering to maintain visual hierarchy

## Label Content Implementation
The Z-height label (3_2_Z_Height) is correctly displayed through a specific sequence of steps:

1. **Content Generation in MountainGroupViewModel**
   ```dart
   // Format the height value with units
   final String heightText = isMetric ? 
     '${(targetHeight ?? 0.0).toStringAsFixed(1)}m' :
     '${(targetHeight ?? 0.0).toStringAsFixed(1)}ft';
   
   // Combine prefix with formatted value
   updatedSvg = LabelGroupHandler.updateTextElement(
     updatedSvg,
     '3_2_Z_Height',
     {
       'x': '$xCoordinate',
       'y': '$labelY',
       'content': 'Z: $heightText',  // Complete label content provided here
     },
     'heightMeasurement',
   );
   ```

2. **Content Flow**
   - MountainGroupViewModel formats the complete content string
   - Content is passed as an attribute to LabelGroupHandler
   - LabelGroupHandler preserves content while applying styles
   - SvgElementUpdater writes content directly to SVG text element

3. **Key Success Factors**
   - Complete content string assembled in one place
   - Consistent decimal places (1)
   - Units included in value
   - Fixed prefix format ("Z: ")
   - Content passed through untouched by style handling

4. **Style Application**
   - Label style from diagram_spec.json applied via 'heightMeasurement' group
   - Style merged with position attributes
   - Content and style remain separate concerns

This implementation ensures the label is displayed correctly while maintaining separation between content formatting and visual styling.

## SVG Text Styling Requirements

### Text Attribute Handling
When updating any text elements in the SVG, styling attributes must be handled correctly to ensure proper rendering:

1. **Style String Attributes**
   The following attributes must ALWAYS be included in the style string, never as standalone XML attributes:
   ```
   - text-anchor
   - dominant-baseline
   - font-style
   - font-variant
   - font-weight
   - font-stretch
   - font-size
   - font-family
   - text-align
   - fill
   ```

2. **Correct Format**
   ```dart
   // CORRECT - Include in style string
   'style': 'text-anchor:middle;dominant-baseline:middle;font-size:12.0877px;...'

   // INCORRECT - Do not use as standalone attributes
   'text-anchor': 'middle',
   'dominant-baseline': 'middle',
   ```

3. **Common Issues**
   - Standalone text attributes can cause rendering inconsistencies
   - Text may not center properly if text-anchor is not in style string
   - Multiple text elements may be created if attributes are duplicated
   - This affects multiple components:
     - Z-height labels (3_2_Z_Height)
     - Observer labels (4_2_observer_A)
     - Line of sight labels (4_3_Observer_Line_of_Sight)

4. **Implementation Note**
   When using SvgElementUpdater.updateTextElement, always combine all text-related attributes into the style string:
   ```dart
   updatedSvg = SvgElementUpdater.updateTextElement(
     updatedSvg,
     '3_2_Z_Height',
     {
       'x': '$xCoordinate',
       'y': '$labelY',
       'style': 'font-size:12.0877px;font-family:Calibri;text-anchor:middle;dominant-baseline:middle;fill:#552200',
       'content': 'Z: $heightText',
     },
   );
   ```

### Critical Label Update Requirements
When updating the Z-height label (3_2_Z_Height), you must:
1. Pass both positioning AND content attributes to the SVG updater
2. Include all text styling in the style string
3. Never use standalone text styling attributes
4. Example implementation:
```dart
updatedSvg = SvgElementUpdater.updateTextElement(
  updatedSvg,
  '3_2_Z_Height',
  {
    'x': '325',  // Position attributes
    'y': '${mountainPeakY + 10}',
    'style': 'font-size:12.0877px;font-family:Calibri;text-anchor:middle;dominant-baseline:middle;fill:#552200',  // All text styling in style string
    'content': 'Z: ${formatHeight(targetHeight)}',
  }
);
```

### Dependencies and Related Components
The text styling requirements affect:
1. Z-height Implementation:
   - 3_1_Z_Height_Top_arrowhead
   - 3_1_Z_Height_Top_arrow
   - 3_2_Z_Height
   - 3_3_Z_Height_Bottom_arrow
   - 3_3_Z_Height_Bottom_arrowhead

2. Observer Group:
   - 4_2_observer_A
   - 4_3_Observer_Line_of_Sight

Any changes to text handling must consider impacts on all these components.

### Important Note on Text Styling Attributes
Text styling attributes like `text-anchor`, `dominant-baseline`, `font-style`, etc. must be passed as part of the style string, not as standalone attributes. The following attributes should ALWAYS be included in the style string, never as standalone XML attributes:
   - text-anchor
   - dominant-baseline
   - font-style
   - font-variant
   - font-weight
   - font-stretch
   - font-size
   - font-family
   - text-align
   - fill

This is critical because:
- Standalone text styling attributes can cause rendering issues
- SVG spec prefers these attributes to be part of the style string
- Affects not just Z-height labels but all text elements (e.g. 4_2_observer_A, 4_3_Observer_Line_of_Sight)
