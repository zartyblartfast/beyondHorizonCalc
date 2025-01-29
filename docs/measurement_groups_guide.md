# Measurement Groups Implementation Guide

## Purpose and Scope

This guide describes how to incorporate existing SVG measurement groups from the diagram into the dynamic configuration system. The measurement elements already exist in the SVG file, created using an SVG editor. The goal is to make these static elements dynamic - responding to user input values and diagram datum lines.

### Existing Measurement Groups

The diagram contains several measurement groups that need to be incorporated:

1. **Visible Height (1_*)** - First group to be configured:
   ```
   1_1_Visible_Height_Top_arrowhead
   1_1_Visible_Height_Top_arrow
   1_2_Visible_Height_Height
   1_3_Visible_Height_Bottom_arrow
   1_3_Visible_Height_Bottom_arrowhead
   ```

2. **Z Height (3_*)** - Already configured, use as reference:
   ```
   3_1_Z_Height_Top_arrow
   3_1_Z_Height_Top_arrowhead
   3_2_Z_Height
   3_3_Z_Height_Bottom_arrow
   3_3_Z_Height_Bottom_arrowhead
   ```

3. **Observer Group (4_*)** - Already configured, use as reference:
   ```
   4_1_Observer_here_arrow
   4_2_observer_A
   4_3_Observer_Line_of_Sight
   ```

4. **Hidden Height (5_*)** - To be handled separately:
   ```
   5_1_Hidden_Height_Top_arrow
   5_1_Hidden_Height_Top_arrowhead
   5_2_Hidden_Height_Height
   5_3_Hidden_Height_Bottom_arrow
   5_3_Hidden_Height_Bottom_arrowhead
   ```

### Key Points
1. Elements already exist in SVG - no need to create new paths or styles
2. Focus is on making static elements dynamic through configuration
3. Use existing Z-height (3_*) and Observer (4_*) groups as reference patterns
4. Each group follows similar pattern: arrows, labels, and arrowheads
5. Hidden Height (5_*) will be handled separately due to different requirements

## Overview

This document describes the standardized structure for implementing measurement groups in the Beyond Horizon Calculator diagram. A measurement group typically consists of arrows, arrowheads, and labels that work together to indicate a specific measurement (e.g., Z-height, C-height, visible height).

## SVG Coordinate System

Important considerations for the coordinate system:
- ViewBox: -300 to 300 (x-axis), 0 to 1000 (y-axis)
- Y coordinates increase downward (0 at top, 1000 at bottom)
- Negative y-offsets move elements upward
- Positive y-offsets move elements downward

## X-Coordinate Guidelines

1. **Default Position**
   - Each measurement group has a default x-coordinate defined in the SVG file
   - Use the SVG's x-coordinate for consistency with the original design
   - Example: Extract x-coordinate from the group's arrow path in SVG:
     ```xml
     <path d="m 236.17952,305.79732 v 28.42249" id="1_3_Visible_Height_Bottom_arrow" />
     <!-- x-coordinate is 236.17952 -->
     ```

2. **Group Positioning**
   - Left side groups (C-height): Around x = -251
   - Center groups (Observer): Around x = 0
   - Right side groups (Z-height): Around x = 325
   - Visible/Hidden Height: Around x = 236

3. **Horizontal Alignment**
   - Keep all elements in a group aligned to the same x-coordinate
   - Maintain consistent spacing between groups
   - Use the SVG's original x-coordinates unless there's a specific reason to change

## Group Structure

Each measurement group follows a consistent naming and numbering convention:

```
{prefix}_{element_type}_{measurement_name}
```

Where:
- `prefix`: Numerical prefix for the group (e.g., 2_ for C-height, 3_ for Z-height)
- `element_type`: Sequential number and type (1=top arrow, 2=label, 3=bottom arrow)
- `measurement_name`: Descriptive name (e.g., Z_Height, C_Height)

Example for Z-height group:
- `3_1_Z_Height_Top_arrow`
- `3_2_Z_Height`
- `3_3_Z_Height_Bottom_arrow`

## Element Configuration

### 1. Arrow Elements
```json
{
  "id": "{prefix}_1_{name}_Top_arrow",
  "type": "path",
  "behavior": "dynamic",
  "style": {
    "stroke": "#000000",
    "strokeWidth": 2.46886
  },
  "position": {
    "x": [fixed_position],
    "y": "dynamic"
  }
}
```

### 2. Arrowheads
```json
{
  "id": "{prefix}_1_{name}_Top_arrowhead",
  "type": "path",
  "behavior": "dynamic",
  "style": {
    "fill": "#000000",
    "fillOpacity": 1,
    "stroke": "none"
  },
  "position": {
    "x": [same_as_arrow],
    "y": "dynamic"
  }
}
```

### 3. Labels
```json
{
  "id": "{prefix}_2_{name}",
  "type": "text",
  "behavior": "dynamic",
  "style": {
    "fontFamily": "Calibri",
    "fontSize": "12.0877px",
    "fontWeight": "bold",
    "fill": "#552200",
    "textAnchor": "start"  // Critical for consistent left alignment
  },
  "position": {
    "x": [arrow_x + offset],  // Position relative to arrow with padding
    "y": "dynamic"
  }
}
```

## Label Alignment Rules

1. Text Alignment:
   - Always use `textAnchor: "start"` for left alignment
   - Never use "middle" or "end" for measurement labels

2. Horizontal Positioning:
   - Labels should be positioned relative to their associated arrow
   - Add 5 units padding from the end of the arrow to the start of the label
   - For arrow-label pairs, calculate the arrow's end point before setting label position

3. Vertical Positioning:
   - Use negative y-offsets to move labels upward
   - Consider the SVG coordinate system (0-1000, increasing downward)
   - Maintain consistent vertical spacing between group elements

## Specific Group Requirements

### Observer Group (4_*)
- Special case with curved arrow path
- Label positions must account for the arrow's end point
- Both labels (`4_2_observer_A` and `4_3_Observer_Line_of_Sight`) should align left

### C-Height Group (2_*)
- Straight vertical arrows
- Label aligns left with 5 units padding from arrow
- Position considers the full measurement range

### Z-Height Group (3_*)
- Similar to C-Height but on the right side
- Maintains consistent style with other measurement groups
- Uses dynamic positioning for mountain peak tracking

## Configuration Location in diagram_spec.json

The measurement group configurations are organized in different sections of diagram_spec.json based on their behavior:

### 1. Static Measurements
Located under the root `labels.measurements` array:
```json
{
  "labels": {
    "measurements": [
      {
        "id": "2_2_C_Height",
        "type": "text",
        "style": { ... },
        "position": { ... }
      }
    ]
  }
}
```

### 2. Dynamic Observer Elements
Located under `coordinateMapping.groups.observer.labelGroup`:
```json
{
  "coordinateMapping": {
    "groups": {
      "observer": {
        "labelGroup": {
          "elements": [
            {
              "id": "4_1_Observer_here_arrow",
              "type": "path",
              "behavior": "dynamic",
              "position": { ... }
            },
            {
              "id": "4_2_observer_A",
              "type": "text",
              "behavior": "dynamic",
              "style": { ... },
              "position": { ... }
            }
          ]
        }
      }
    }
  }
}
```

### 3. Z-Height Elements
Located under the root `layers` array in the Mountain group:
```json
{
  "layers": [
    {
      "name": "Mountain",
      "elements": [
        {
          "id": "3_2_Z_Height",
          "type": "text",
          "behavior": "dynamic",
          "style": { ... },
          "position": { ... }
        }
      ]
    }
  ]
}
```

### Important Notes:
1. Despite being in different sections, all measurement groups follow the same styling and positioning principles outlined above
2. The location in diagram_spec.json determines how the element is processed by the view models:
   - Observer group elements are handled by ObserverGroupViewModel
   - Mountain layer elements (including Z-height) by MountainGroupViewModel
   - Static measurements directly by the SVG updater

3. When adding new measurement groups:
   - Determine which section is appropriate based on the measurement's behavior
   - Follow the naming and structure conventions regardless of location
   - Ensure the view model can handle the new group's dynamic behavior if required

## Implementation Process

### Configuration-First Approach

Before making any code changes:

1. **Always Start with Configuration**:
   - First attempt to implement the new measurement group through `diagram_spec.json`
   - Use existing view models and update methods where possible
   - Follow the patterns established in similar measurement groups

2. **Document Configuration Limitations**:
   If configuration changes are insufficient, document specifically:
   - What functionality cannot be achieved through configuration
   - Which view model limitations prevent the desired behavior
   - Why code changes are necessary

### Required Proposal Process

Before implementing any changes:

1. **Configuration Changes Proposal**:
```markdown
Proposal: Add New Measurement Group Configuration

Files to Modify:
- assets/info/diagram_spec.json

Changes:
1. Add new measurement group configuration under [specific section]
2. Define styles consistent with existing measurements
3. Configure position and behavior properties

Reason:
[Explain why this measurement group is needed and how it fits into the diagram]
```

2. **Code Changes Proposal** (only if configuration is insufficient):
```markdown
Proposal: Implement Support for New Measurement Group

Files to Modify:
1. lib/widgets/calculator/diagram/mountain_group_view_model.dart:
   - Add position calculation method
   - Update SVG handling logic

2. lib/services/models/calculation_result.dart:
   - Add new measurement value

3. lib/widgets/calculator/diagram/svg_element_updater.dart:
   - Add new element type handling (if needed)

Reason for Code Changes:
[Document specific limitations in current implementation that prevent
achieving the desired functionality through configuration alone]

Implementation Details:
[Provide specific method signatures and changes required]

Testing Plan:
1. Unit tests for new calculations
2. Widget tests for visual rendering
3. Integration tests for dynamic behavior
```

3. **Review Process**:
   - Submit configuration changes first
   - Test with existing view models
   - Only proceed with code changes if absolutely necessary
   - Get explicit approval before implementing any changes

### Testing Requirements

1. **Configuration Testing**:
   - Verify visual alignment
   - Test dynamic behavior
   - Check interaction with other elements
   - Validate across different viewport sizes

2. **Code Changes Testing** (if needed):
   - Unit tests for new methods
   - Integration tests for view model changes
   - Visual regression tests
   - Performance impact assessment

## Required Code Changes

When adding a new measurement group, changes are needed in both the configuration and code:

### 1. View Model Changes

Depending on which view model handles the group, you'll need to update one of:

#### MountainGroupViewModel
```dart
class MountainGroupViewModel {
  // Add any new calculated values needed for the group
  double _calculateNewMeasurement() {
    // Implementation
  }

  // Update the updateSvg method to handle the new group
  String updateSvg(String svgContent) {
    // ... existing code ...
    
    // Add case for new measurement group
    case 'new_measurement_group':
      final position = _calculateNewMeasurement();
      updatedSvg = _updateMeasurementGroup(
        svgContent,
        groupPrefix: 'X_',  // Your group prefix
        position: position,
        style: config['styling']?['new_measurement_group']
      );
      break;
  }

  // Add helper method if needed
  String _updateMeasurementGroup(String svg, {
    required String groupPrefix,
    required double position,
    Map<String, dynamic>? style
  }) {
    // Implementation for updating arrows and labels
  }
}
```

#### ObserverGroupViewModel
```dart
class ObserverGroupViewModel {
  // Add new measurement-specific methods
  double _getNewMeasurementPosition() {
    // Calculate position based on observer state
  }

  // Update label group handling if needed
  String _updateObserverLabelGroup(String svgContent, double observerLevel) {
    // ... existing code ...
    
    // Add handling for new measurement elements
    if (id.startsWith('X_')) {  // Your group prefix
      // Handle new measurement elements
    }
  }
}
```

### 2. SVG Element Updater

Update `svg_element_updater.dart` if new element types or styles are needed:

```dart
class SvgElementUpdater {
  // Add new update methods if needed
  static String updateNewElementType(
    String svg,
    String id,
    Map<String, String> attributes,
  ) {
    // Implementation
  }

  // Update existing methods if new attributes are needed
  static String updateTextElementWithStyle(
    String svg,
    String id,
    Map<String, String> attributes,
  ) {
    // Add handling for new style attributes
  }
}
```

### 3. Integration Points

1. **Model Updates**:
   - Add new measurement values to `CalculationResult` if needed
   - Update any relevant calculation methods

2. **View Model Factory**:
   - If the new group requires special handling, update `DiagramViewModelFactory`
   - Add any new configuration parameters needed

3. **Testing**:
   - Add unit tests for new measurement calculations
   - Add widget tests for visual rendering
   - Test dynamic behavior and interactions

### Implementation Checklist

1. Configuration:
   - Add measurement group to appropriate section in diagram_spec.json
   - Define all required styles and positions
   - Add any new calculation parameters

2. View Model:
   - Add position calculation methods
   - Update SVG update logic
   - Add any new helper methods
   - Update tests

3. SVG Updates:
   - Add any new element update methods
   - Update existing methods if needed
   - Test with different SVG states

4. Integration:
   - Update model classes if needed
   - Add factory handling if required
   - Add comprehensive tests
   - Document new measurement group

### Example: Adding a New Height Measurement

```dart
// In mountain_group_view_model.dart
class MountainGroupViewModel {
  String updateSvg(String svgContent) {
    // ... existing code ...
    
    // Add new height measurement
    final newHeight = _calculateNewHeight();
    updatedSvg = _updateHeightGroup(
      svgContent,
      groupPrefix: '5_',  // New group prefix
      height: newHeight,
      style: config['styling']?['new_height']
    );
  }

  double _calculateNewHeight() {
    // Implementation
    return result?.newHeightValue ?? 0.0;
  }
}

// In calculation_result.dart
class CalculationResult {
  final double? newHeightValue;
  
  CalculationResult({
    // ... existing parameters ...
    this.newHeightValue,
  });
}
```

## Example Implementation: Hidden Height (5_*)

The Hidden Height measurement group demonstrates a complete implementation following this guide's patterns:

1. **Group Structure**
   ```
   5_1_Hidden_Height_Top_arrow       - Upper vertical arrow
   5_1_Hidden_Height_Top_arrowhead   - Upper arrowhead
   5_2_Hidden_Height_Height          - Label showing height value
   5_3_Hidden_Height_Bottom_arrow    - Lower vertical arrow
   5_3_Hidden_Height_Bottom_arrowhead - Lower arrowhead
   ```

2. **Key Characteristics**
   - Part of the mountain group (handled by MountainGroupViewModel)
   - Measures height between Distant_Obj_Sea_Level and C_Point_Line
   - Vertical measurement with straight arrows
   - Label follows standard measurement group format

3. **Configuration in diagram_spec.json**
   ```json
   {
     "measurementGroups": {
       "hiddenHeight": {
         "prefix": "5",
         "elements": [
           "5_1_Hidden_Height_Top_arrow",
           "5_1_Hidden_Height_Top_arrowhead",
           "5_2_Hidden_Height_Height",
           "5_3_Hidden_Height_Bottom_arrow",
           "5_3_Hidden_Height_Bottom_arrowhead"
         ]
       }
     }
   }
   ```

4. **Implementation Steps**
   - Add group configuration to diagram_spec.json
   - Update MountainGroupViewModel to handle positioning
   - Use LabelGroupHandler for consistent styling
   - Follow standard measurement group patterns

This example demonstrates how to properly integrate a new measurement group while maintaining consistency with existing patterns.

## Implementation Pattern
Follow these steps to ensure your measurement group is compliant with the established pattern. Use `2_2_C_Height` as the reference implementation.

### 1. Content Generation
Content must be managed through `DiagramLabelService` via `getLabelValues()`:
```dart
@override
Map<String, String> getLabelValues() {
  final Map<String, String> labels = {};
  
  // 1. Get value into local variable for null safety
  final observerHeight = result?.h1;
  
  // 2. Check for null before using
  if (observerHeight != null) {
    // 3. Convert from km to meters using convertFromKm()
    // 4. Format with units using formatHeight()
    labels['2_2_C_Height'] = 'h1: ${formatHeight(convertFromKm(observerHeight))}';
  }
  
  return labels;
}
```

### 2. Position and Style
Position and style are handled separately through `LabelGroupHandler`:
```dart
updatedSvg = LabelGroupHandler.updateTextElement(
  updatedSvg,
  '2_2_C_Height',
  {
    'x': '$xCoordinate',
    'y': '$yCoordinate',
  },
  'heightMeasurement',
);
```

### 3. Configuration
Style configuration in `diagram_spec.json`:
```json
{
  "labels": {
    "2_2_C_Height": {
      "style": "heightMeasurement",
      "position": {
        "x": "...",
        "y": "..."
      }
    }
  }
}
```

## Common Issues and Solutions

1. **Units**: 
   - Values in `CalculationResult` are in kilometers
   - Must convert to meters using `convertFromKm()` before formatting
   - Use `formatHeight()` to add the correct unit label

2. **Null Safety**:
   - Always get value into local variable first
   - Check for null before using
   - Example: `final value = result?.someField; if (value != null) { ... }`

3. **Content vs Position**:
   - Content generation belongs in `getLabelValues()`
   - Position updates belong in `updateTextElement()`
   - Never mix content and position updates

## Testing Your Implementation

1. Verify content appears in correct units (meters/feet)
2. Verify position matches configuration
3. Verify style matches configuration
4. Verify null handling works correctly

## Reference Implementation

The `2_2_C_Height` label in `observer_group_view_model.dart` demonstrates all these principles:
- Content managed by `DiagramLabelService`
- Position managed by `LabelGroupHandler`
- Proper unit conversion
- Proper null safety
- Clear separation of concerns

## Future Enhancement: External Measurement Objects

The diagram_spec.json includes a template for external measurement objects, which will provide a more modular and reusable approach to measurement groups:

```json
{
  "measurementObjects": {
    "description": "Templates for reusable measurement objects",
    "templates": {
      "verticalMeasurement": {
        "elements": {
          "topArrow": {
            "type": "path",
            "style": {
              "stroke": "#000000",
              "strokeWidth": 2.0
            }
          },
          "label": {
            "type": "text",
            "style": {
              "fontFamily": "Calibri",
              "fontSize": "12.0877px",
              "fontWeight": "bold",
              "fill": "#552200",
              "textAnchor": "start"
            }
          },
          "bottomArrow": {
            "type": "path",
            "style": {
              "stroke": "#000000",
              "strokeWidth": 2.0
            }
          }
        },
        "spacing": {
          "labelPadding": 5,
          "arrowHeadSize": 3
        }
      }
    }
  }
}
```

### Benefits of External Objects:
1. **Reusability**: Define measurement styles and behaviors once, reuse across multiple instances
2. **Consistency**: Ensures all measurements follow the same visual and behavioral patterns
3. **Maintainability**: Central location for style updates and behavior modifications
4. **Extensibility**: Easy to add new measurement types by defining new templates

### Planned Usage:
```json
{
  "measurements": [
    {
      "type": "verticalMeasurement",
      "id": "2_C_Height",
      "position": {
        "x": -250,
        "y": "dynamic"
      },
      "content": {
        "prefix": "h1: ",
        "value": {
          "source": "Observer Height (h1)"
        }
      }
    }
  ]
}
```

### Implementation Notes:
1. Templates will define:
   - Default styles and behaviors
   - Element relationships and spacing
   - Animation and interaction patterns

2. Instance configurations will specify:
   - Position and orientation
   - Content and data sources
   - Any style overrides

3. Migration Strategy:
   - New measurements should use the template system
   - Existing measurements will be gradually migrated
   - Both systems will coexist during transition

This enhancement will simplify the creation of new measurement groups while ensuring consistency across the diagram.

## Implementation Steps

1. Arrow Setup:
   - Define arrow path and position
   - Ensure arrowhead aligns perfectly with arrow endpoint

2. Label Positioning:
   - Calculate arrow endpoint
   - Add 5 units padding for label start position
   - Set `textAnchor: "start"`
   - Verify vertical alignment with arrow

3. Testing:
   - Verify label alignment at different measurement values
   - Check arrow-label connection remains intact
   - Ensure consistent spacing across all groups

## Common Pitfalls

1. Label Alignment:
   - Don't use centered text alignment
   - Don't position labels without considering arrow endpoints

2. Coordinate System:
   - Remember y-axis increases downward
   - Use negative y-offsets for upward movement

3. Arrow-Label Connection:
   - Always maintain visual connection between arrows and labels
   - Account for arrow path when positioning labels

## Example Implementation

```json
{
  "elements": [
    {
      "id": "3_2_Z_Height",
      "type": "text",
      "behavior": "dynamic",
      "style": {
        "fontFamily": "Calibri",
        "fontSize": "12.0877px",
        "fontWeight": "bold",
        "fill": "#552200",
        "textAnchor": "start"
      },
      "position": {
        "x": 330,  // 325 (arrow) + 5 (padding)
        "y": "dynamic"
      }
    }
  ]
}
