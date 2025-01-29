# Z-Height Implementation Guide

## Related Documentation
- [1_measurement_groups_guide.md](1_measurement_groups_guide.md) - Main guide
- [2_1_c_height_implementation.md](2_1_c_height_implementation.md) - Reference implementation

## Coordinate System
- Y-axis: 0 at top, 1000 at bottom
- Mountain layer: Y range 474-1000
- **IMPORTANT**: When calculating distances or checking space:
  - A larger Y value means lower on the diagram
  - To check if point A is above point B: A.y < B.y
  - Height = |bottom.y - top.y|
  - Available space = |bottom_anchor.y - top_anchor.y|

## Components
The Z-Height measurement consists of five elements in fixed vertical order, with fixed arrowhead positions and orientations:
1. Top arrowhead (3_1_Z_Height_Top_arrowhead) - always at top, pointing upward
2. Top arrow (3_1_Z_Height_Top_arrow)
3. Height label (3_2_Z_Height)
4. Bottom arrow (3_3_Z_Height_Bottom_arrow)
5. Bottom arrowhead (3_3_Z_Height_Bottom_arrowhead) - always at bottom, pointing downward

## Visibility Rules
- Check space between Z_Point_Line (top) and Distant_Obj_Sea_Level (bottom)
- **Space Calculation**: 
  ```dart
  double availableSpace = distant_obj_sea_level.y - z_point_line.y;  // Remember: larger Y = lower position
  bool hasSpace = availableSpace >= MINIMUM_REQUIRED_HEIGHT;
  ```
- Minimum height needed = sum of:
  - Top arrowhead height (10 units)
  - Label height (15 units)
  - Bottom arrowhead height (10 units)
  - Minimum arrow lengths (20 units each)
  - Total minimum: 75 units

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

## Label Positioning
- **Vertical Centering**: Label must be vertically centered between its arrows
  ```dart
  double totalSpace = bottomArrowY - topArrowY;
  double labelHeight = 15;  // Standard label height
  labelY = topArrowY + (totalSpace - labelHeight) / 2;  // Centers label with equal padding
  ```

- **Horizontal Centering**: Configured in diagram_spec.json
  ```json
  {
    "id": "3_2_Z_Height",
    "type": "text",
    "style": {
      "textAlign": "start",  // This is overridden by the LabelGroupHandler
      "fontFamily": "Calibri",
      "fontSize": "12.0877px",
      "fontWeight": "bold",
      "fill": "#552200"
    }
  }
  ```
  Note: Text alignment is handled automatically by the LabelGroupHandler, which ensures proper centering.

## Arrowhead Alignment
- **Critical**: SVG path reference point must be adjusted to achieve proper centering
- **Mountain Group Position**: All Z-height elements are on right side (x=325)
  ```dart
  // INCORRECT - Using right vertex as reference:
  d="m 325,${y} -5,10 h 10 z"  // Results in off-center arrowhead
  
  // CORRECT - Adjust reference point left by half width:
  double arrowX = 325;  // Mountain group x-coordinate
  double refX = arrowX - 5;  // Move reference left by half width (10/2)
  d="m ${refX},${y} -5,10 h 10 z"  // Creates centered arrowhead
  ```

- Arrowhead dimensions and centering:
  - Total width: 10 units
  - Reference point must be 5 units left of desired center
  - For Mountain group (x=325), reference point is at x=320
  - Path commands create triangle from adjusted reference:
    1. Move to (refX, y)
    2. Line left 5 units and down 10 units
    3. Horizontal line right 10 units
    4. Close path to create triangle

- Common mistakes to avoid:
  - Using arrow line x-coordinate directly as path reference
  - Not adjusting for arrowhead width in reference point
  - Assuming path commands are relative to arrow line center

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
The arrowheads have fixed orientations and must be properly centered:

### Top Arrowhead (3_1_Z_Height_Top_arrowhead)
```css
style="fill:#000000;fill-opacity:1;stroke:none"
d="m 320,244.95184 -5,10 h 10 z"  # Centered on x=325
```

### Top Arrow (3_1_Z_Height_Top_arrow)
```css
style="fill:none;stroke:#000000;stroke-width:0.5;stroke-linecap:butt;stroke-linejoin:miter;stroke-miterlimit:4;stroke-dasharray:none;stroke-opacity:1"
```
