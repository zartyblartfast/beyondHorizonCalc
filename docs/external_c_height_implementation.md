# External C-Height Implementation

## STRICT RULES - MUST FOLLOW EXACTLY

### 1. ONLY FILE TO MODIFY
```
observer_external_group_view_model.dart
```

### 2. ABSOLUTELY DO NOT MODIFY
```
diagram_view_model.dart          - Base view model
label_group_handler.dart         - Label handling
svg_element_updater.dart         - SVG updates
observer_group_view_model.dart   - Internal C-Height
mountain_diagram_view_model.dart - Mountain diagram
diagram_spec.json               - Configuration file
Any other files
```

### 3. USE EXISTING SYSTEMS
- Use existing label group "heightMeasurement"
- Use existing SVG update methods
- Use existing coordinate system
- Use existing visibility patterns

### 4. CRITICAL VISIBILITY RULES
```
NEVER SET DEFAULT POSITIONS (0,0) WHEN HIDING ELEMENTS

✅ CORRECT way to hide elements:
- Only use SvgElementUpdater.hideElement()
- Return early after hiding
- Don't set any positions

❌ WRONG way to hide elements:
- Don't set positions to 0 or default values
- Don't update positions before hiding
- Don't modify element attributes when hiding
```

### 5. Required JSON Configuration
```json
{
  "labels": {
    "measurements": [
      {
        "id": "c_height_marker_external",
        "type": "group",
        "elements": [
          {
            "id": "2e_1_C_Top_arrow",
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
            "id": "2e_1_C_Top_arrowhead",
            "type": "path",
            "behavior": "dynamic",
            "style": {
              "fill": "#000000",
              "stroke": "none",
              "fillOpacity": 1
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
            "id": "2e_1_C_Height",
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
              "x": -251.08543,
              "y": {
                "reference": "Observer Height (h1)",
                "visibility": "dependent"
              }
            }
          },
          {
            "id": "2e_3_C_Bottom_arrowhead",
            "type": "path",
            "behavior": "dynamic",
            "style": {
              "fill": "#000000",
              "stroke": "none",
              "fillOpacity": 1
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
            "id": "2e_3_C_Bottom_arrow",
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
          }
        ]
      }
    ]
  }
}
```

### 6. Implementation in observer_external_group_view_model.dart

1. **Class Declaration and Constructor** (exact code):
```dart
// This class extends DiagramViewModel to leverage existing functionality
// It must NOT override or reimplement core functionality from the base class
// All scaling, coordinate systems, and base calculations come from DiagramViewModel
//
// SHARED CODE - DO NOT MODIFY:
// - _getScaledObserverHeight(): Used by both internal/external for consistent scaling
// - getObserverLevel(): Used by both for consistent coordinate calculation
// - C_HEIGHT constants: Must stay in sync with internal C-Height for consistent spacing
// - LabelGroupHandler: Shared label styling and positioning logic
//   - getLabelStyle(): Must use same group name as internal for consistent styling
//   - updateTextElement(): Must follow same pattern for style merging
class ObserverExternalGroupViewModel extends DiagramViewModel {
  // Configuration from diagram_spec.json
  final Map<String, dynamic> config;

  // Coordinate system constants
  late final double _seaLevel;
  late final double _viewboxScale;

  // This constructor initializes the view model with the required parameters
  // It calls the base class constructor with the provided parameters
  ObserverExternalGroupViewModel({
    required CalculationResult? result,
    double? targetHeight,
    required bool isMetric,
    String? presetName,
    required this.config,
  }) : super(
    result: result,
    targetHeight: targetHeight,
    isMetric: isMetric,
    presetName: presetName,
  ) {
    // Initialize from config with fallback values
    _seaLevel = _getConfigDouble(['coordinateMapping', 'groups', 'observer', 'seaLevel', 'y']) ?? 500.0;
    _viewboxScale = 500 / 18; // Scale factor: 500 viewbox units = 18km
  }

  // Elements MUST be in this exact order to match SVG rendering dependencies
  // Order mirrors internal C-Height pattern but with 'e' prefix
  // This ordering is critical for both internal and external measurements
  static const externalElements = [
    '2e_1_C_Height',           // 1. Label anchored to Top_arrow
    '2e_1_C_Top_arrow',        // 2. Anchored to Top_arrowhead
    '2e_1_C_Top_arrowhead',    // 3. Anchored to C_Point_Line
    '2e_3_C_Bottom_arrowhead', // 4. Anchored to Observer_SL_Line
    '2e_3_C_Bottom_arrow'      // 5. Anchored to Bottom_arrowhead
  ];
}
```

2. **Constants and Helpers** (exact values - do not modify):
```dart
// Constants for C-height marker
// These values are used for positioning and sizing the C-height marker elements
static const double C_HEIGHT_LABEL_HEIGHT = 12.0877;
static const double C_HEIGHT_LABEL_PADDING = 5.0;
static const double C_HEIGHT_MIN_ARROW_LENGTH = 10.0;
static const double C_HEIGHT_TOTAL_REQUIRED_HEIGHT = 
    C_HEIGHT_LABEL_HEIGHT + (2 * C_HEIGHT_LABEL_PADDING) + (2 * C_HEIGHT_MIN_ARROW_LENGTH);

// Fixed x-coordinate for all elements
static const double _xCoord = -250.0;  

/// Gets a double value from nested config path with fallback
// This method retrieves a value from the configuration JSON
// It uses a fallback value if the path is not found
double? _getConfigDouble(List<String> path) {
  dynamic value = config;
  for (final key in path) {
    value = value is Map ? value[key] : null;
    if (value == null) return null;
  }
  return value is num ? value.toDouble() : null;
}
```

3. **Space Check Method**:
```dart
// This method is critical for coordinating between internal and external C-Height
// It inverts the internal logic because external C-Height shows when internal doesn't have space
//
// SHARED CODE - DO NOT MODIFY:
// - C_HEIGHT_TOTAL_REQUIRED_HEIGHT: Must match internal calculation exactly
// - Base class hasSufficientSpaceForCHeight(): Used by both for consistent space checks
@override
bool hasInternalSufficientSpace(double h1) {
  return !super.hasInternalSufficientSpace(h1);
}
```

4. **Position Calculation**:
```dart
// Reuses the base class position calculation logic to ensure consistency
// Only difference is when to show/hide based on internal space
//
// SHARED CODE - DO NOT MODIFY:
// - Position calculation formulas from base class
// - Scaling and coordinate system from base class
// - Visibility thresholds and checks
@override
Map<String, double> calculateCHeightPositions(double h1) {
  if (!hasInternalSufficientSpace(h1)) {
    return {'visible': 0.0};
  }
  return super.calculateCHeightPositions(h1);
}
```

5. **SVG Updates**:
```dart
// Updates SVG elements in exact dependency order
// Mirrors internal C-Height update pattern with external IDs
//
// SHARED CODE - DO NOT MODIFY:
// - SvgElementUpdater methods: Used by all diagram elements
// - Position map structure: Must match internal format
// - Visibility handling pattern: Must match internal behavior
// - Element update sequence: Must follow same pattern as internal
// - Label styling: Must use LabelGroupHandler for consistent text styling
//   - Both internal and external C-Height labels use same label group
//   - Style merging logic must match internal implementation
@override
String updateSvg(String svgContent) {
  var updatedSvg = svgContent;
  final observerHeight = result?.h1;

  // Early return if no observer height - matches internal pattern
  if (observerHeight == null) {
    for (final elementId in externalElements) {
      updatedSvg = SvgElementUpdater.hideElement(updatedSvg, elementId);
    }
    return updatedSvg;
  }

  final positions = calculateCHeightPositions(observerHeight);
  
  // Early return if should be hidden - matches internal pattern
  if (positions['visible'] == 0.0) {
    for (final elementId in externalElements) {
      updatedSvg = SvgElementUpdater.hideElement(updatedSvg, elementId);
    }
    return updatedSvg;
  }

  // Update elements in exact dependency order
  // Order is critical for proper SVG rendering
  // Each element must be updated after its dependencies
  // Uses same update pattern as internal C-Height

  // 1. Label - depends on Top_arrow position
  // Uses same text element update pattern as internal
  // IMPORTANT: Uses shared LabelGroupHandler for consistent styling
  updatedSvg = LabelGroupHandler.updateTextElement(
    updatedSvg,
    '2e_1_C_Height',
    {
      'x': '${-251.08543}',  // Exact x-coordinate from diagram_spec.json
      'y': '${positions['labelY']}',
      'text-content': formatHeightLabel(result?.h1 ?? 0), // Use same format as internal
      'visibility': 'visible'
    },
    'c_height'  // Same group name as internal for consistent styling
  );

  // 2. Top arrow - depends on Top_arrowhead position
  // Uses same path update pattern as internal
  updatedSvg = SvgElementUpdater.updatePathElement(
    updatedSvg,
    '2e_1_C_Top_arrow',
    {
      'd': 'M ${_xCoord},${positions['startY']} L ${_xCoord},${positions['topArrowEnd']}',
      'visibility': 'visible'
    }
  );

  // 3. Top arrowhead - anchored to C_Point_Line
  // Uses same arrowhead path pattern as internal
  updatedSvg = SvgElementUpdater.updatePathElement(
    updatedSvg,
    '2e_1_C_Top_arrowhead',
    {
      'd': 'M ${_xCoord},${positions['startY']} l -5,-10 l 10,0 z',
      'visibility': 'visible'
    }
  );

  // 4. Bottom arrowhead - anchored to Observer_SL_Line
  // Uses same arrowhead path pattern as internal
  updatedSvg = SvgElementUpdater.updatePathElement(
    updatedSvg,
    '2e_3_C_Bottom_arrowhead',
    {
      'd': 'M ${_xCoord},${positions['endY']} l -5,10 l 10,0 z',
      'visibility': 'visible'
    }
  );

  // 5. Bottom arrow - depends on Bottom_arrowhead position
  // Uses same path update pattern as internal
  updatedSvg = SvgElementUpdater.updatePathElement(
    updatedSvg,
    '2e_3_C_Bottom_arrow',
    {
      'd': 'M ${_xCoord},${positions['endY']} L ${_xCoord},${positions['bottomArrowStart']}',
      'visibility': 'visible'
    }
  );

  return updatedSvg;
}
```

### 7. Label Styling and Configuration

The external C-Height measurement group shares label styling configuration with the internal C-Height through the `LabelGroupHandler` class. This ensures consistent text appearance and behavior across both measurement groups.

**Shared Label Code - DO NOT MODIFY:**
1. `LabelGroupHandler.initialize()`: Loads shared configuration for all labels
2. `LabelGroupHandler.getLabelStyle()`: Retrieves styling for label groups
3. `LabelGroupHandler.updateTextElement()`: Applies consistent styling and positioning
   - Handles text-anchor attribute for proper centering
   - Merges styles from configuration with any provided styles
   - Ensures consistent text positioning relative to arrow lines

**Label Text Content and Positioning Requirements:**
The external C-Height label ('2e_1_C_Height') MUST match the internal label ('2_2_C_Height') exactly:
1. Use same label group 'heightMeasurement' for consistent styling
2. Use exact same x-coordinate (-251.08543) for positioning
3. Format text content identically:
   - Same prefix text
   - Value in meters (same units)
   - 'm' suffix
4. Apply same text anchoring and alignment:
   - Must be horizontally centered relative to its arrow line
   - Uses 'text-anchor: middle' from heightMeasurement group style
   - Centering handled automatically by LabelGroupHandler

Example label update code:
```dart
// Update label with proper centering using LabelGroupHandler
// LabelGroupHandler automatically applies text-anchor: middle from heightMeasurement group
updatedSvg = LabelGroupHandler.updateTextElement(
  updatedSvg,
  '2e_1_C_Height',
  {
    'x': '${-251.08543}',  // Exact same x-coordinate as internal
    'y': '${positions['labelY']}',
    'text-content': formatHeightLabel(result?.h1 ?? 0), // Use same format as internal
  },
  'heightMeasurement',  // Same group as internal for consistent styling including centering
);
```

**Why Label Handling Must Match:**
1. Maintains visual consistency between internal and external measurements:
   - Same horizontal centering relative to arrows
   - Same text styling and formatting
   - Same spacing and alignment
2. Ensures correct interpretation of height values
3. Preserves accessibility and readability standards
4. Follows established diagram conventions

### 8. VERIFICATION CHECKLIST

Before ANY code change:
- [ ] Confirm the file is observer_external_group_view_model.dart
- [ ] Verify NO other files will be modified
- [ ] Check we're using existing label and position systems
- [ ] No changes to shared code
- [ ] Verify we NEVER set default positions when hiding

After EACH code change:
- [ ] Verify internal C-Height still works
- [ ] Check no shared code was modified
- [ ] Run all tests
- [ ] Visual verification
- [ ] Double-check we're not setting positions on hidden elements
- [ ] Verify debug logs show correct behavior

### 9. SUCCESS CRITERIA

1. External C-Height ONLY shows when internal lacks space
2. Internal C-Height works EXACTLY as before
3. NO modifications to ANY shared code
4. ALL tests pass
5. NO console errors
6. NO regressions in ANY other diagram elements
7. NO default positions set when hiding elements
8. Debug logs show correct visibility toggling

### 10. IF IN DOUBT
- DO NOT modify the file
- DO NOT touch shared code
- DO NOT make assumptions
- DO NOT set default positions
- ASK for clarification

### 11. SVG Path Details

#### Arrowhead Orientation
The orientation of arrowheads is controlled by the SVG path data ('d' attribute):

1. **Top Arrowhead (2e_1_C_Top_arrowhead)**
   ```svg
   M x,y l -5,10 l 10,0 z
   ```
   - Points UP (positive vertical movement)
   - Starts at top point (x,y)
   - Moves left and up (-5,10)
   - Draws horizontal line (10,0)
   - Closes path (z)

2. **Bottom Arrowhead (2e_3_C_Bottom_arrowhead)**
   ```svg
   M x,y l -5,-10 l 10,0 z
   ```
   - Points DOWN (negative vertical movement)
   - Starts at bottom point (x,y)
   - Moves left and down (-5,-10)
   - Draws horizontal line (10,0)
   - Closes path (z)

The sign of the vertical movement determines the arrowhead direction:
- Positive (e.g., 10): Points upward
- Negative (e.g., -10): Points downward

### 12. Visibility Logic

The external C-Height measurement group must be hidden in several cases:

1. **No Height Data**
   - When `result?.h1` is null
   - Immediately hide all elements, no position calculations

2. **Internal Has Space**
   - When `hasInternalSufficientSpace(h1)` returns true
   - External group must remain hidden, no position calculations
   - Early return with `{'visible': 0.0}`

3. **Position Calculation Failed**
   - If base position calculation returns `{'visible': 0.0}`
   - Propagate the visibility state, no overrides

#### Implementation Safeguards
To prevent accidental display in default positions:

1. Check visibility state before any calculations:
```dart
@override
Map<String, double> calculateCHeightPositions(double h1) {
  // Critical: Only show external when internal DOESN'T have space
  if (!hasInternalSufficientSpace(h1)) {
    return {'visible': 0.0};
  }
  // ... rest of calculations
}
```

2. Multiple exit points for hiding:
   - Early return if no height data
   - Early return if internal has space
   - Early return if position calculation fails

3. Debug logging for visibility state changes

This multi-layered approach ensures the external group never displays in default positions when it should be hidden.

### 13. Handling Compilation Errors

To prevent cascading issues when fixing compilation errors:

1. **Root Cause Analysis**
   - Always identify the primary error first
   - Ignore secondary errors that may be consequences
   - Focus on fixing the root cause, not the symptoms

2. **Minimal Fix Strategy**
   - Make the smallest possible change to fix the error
   - Never modify working code unless absolutely necessary
   - If a fix requires changing working code, STOP and reassess

3. **Fix Validation Checklist**
   - Does the fix only touch the problematic code?
   - Are we maintaining the original design intent?
   - Are we preserving existing functionality?
   - Are we introducing new dependencies?

4. **Red Flags - Stop and Reassess If**:
   - Fix requires modifying multiple files
   - Fix changes existing method signatures
   - Fix alters inheritance hierarchy
   - Fix requires new dependencies
   - Fix touches unrelated functionality

5. **Proper Error Resolution Path**:
   ```
   1. Identify root error
   2. Locate exact error location
   3. Understand error context
   4. Propose minimal fix
   5. Validate against checklist
   6. Apply fix
   7. Verify no regression
   ```

6. **When to Start Over**
   - Multiple failed fix attempts
   - Fixes causing cascading errors
   - Fixes diverging from original design
   - Loss of clarity about what's broken vs working

Remember: It's better to discard failed fixes and start fresh than to keep applying divergent changes.
