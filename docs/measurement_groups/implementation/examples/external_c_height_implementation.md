# External C-Height Implementation Guide

## Overview
The external C-Height measurement provides an alternative display of the observer height (h1) when there isn't enough space to show it in the main diagram area. It appears on the left side of the diagram with fixed-length arrows and precise positioning.

## Implementation Details

### 1. Constants and Configuration
```dart
// Fixed positioning
static const double _xCoord = -250.0;        // Common x-coordinate for all elements
static const double _labelWidth = 80.0;       // Approximate width of label text
static const double _labelXOffset = _xCoord - (_labelWidth / 2);  // Label midpoint alignment

// Arrow dimensions
static const double EXTERNAL_ARROW_LENGTH = 50.0;
static const double ARROWHEAD_SIZE = 5.0;

// Space requirements
static const double C_HEIGHT_LABEL_HEIGHT = 12.0877;
static const double C_HEIGHT_LABEL_PADDING = 5.0;
static const double C_HEIGHT_MIN_ARROW_LENGTH = 10.0;
static const double C_HEIGHT_TOTAL_REQUIRED_HEIGHT = 
    C_HEIGHT_LABEL_HEIGHT + (2 * C_HEIGHT_LABEL_PADDING) + (2 * C_HEIGHT_MIN_ARROW_LENGTH);
```

### 2. Element Layering Order
```dart
static const externalElements = [
  '2e_1_C_Height',           // 1. Label anchored to Top_arrow
  '2e_1_C_Top_arrow',        // 2. Anchored to Top_arrowhead
  '2e_1_C_Top_arrowhead',    // 3. Anchored to C_Point_Line
  '2e_3_C_Bottom_arrowhead', // 4. Anchored to Observer_SL_Line
  '2e_3_C_Bottom_arrow'      // 5. Anchored to Bottom_arrowhead
];
```

### 3. Visibility Logic
The external C-Height is only shown when:
1. Observer height (h1) data is available
2. There isn't enough space for the internal C-Height marker
3. The diagram is in a valid state

```dart
bool hasInternalSufficientSpace(double h1) {
  final cPointY = _getCPointLineY();          // Y coordinate of C_Point_Line
  final observerSLY = _getObserverSLLineY(); // Y coordinate of Observer_SL_Line
  final availableSpace = (observerSLY - cPointY).abs();
  return availableSpace >= C_HEIGHT_TOTAL_REQUIRED_HEIGHT;
}
```

### 4. Position Calculation
```dart
Map<String, double> calculateCHeightPositions(double h1) {
  // Only show external when internal DOESN'T have space
  if (hasInternalSufficientSpace(h1)) {
    return {'visible': 0.0};
  }

  final cPointY = _getCPointLineY();
  final observerSLY = _getObserverSLLineY();
  
  // Fixed positions relative to datum lines
  return {
    'visible': 1.0,
    'labelY': cPointY - (EXTERNAL_ARROW_LENGTH + C_HEIGHT_LABEL_HEIGHT/2),
    'topArrowY': cPointY - EXTERNAL_ARROW_LENGTH,
    'topArrowheadY': cPointY,
    'bottomArrowheadY': observerSLY,
    'bottomArrowY': observerSLY + EXTERNAL_ARROW_LENGTH
  };
}
```

### 5. SVG Element Updates
- Label updates include proper text anchoring and baseline alignment
- Arrow paths are constructed using absolute and relative moves
- Arrowheads use relative path commands for consistent sizing
- All elements maintain consistent styling

```dart
// Example label update
updatedSvg = SvgElementUpdater.updateTextElement(
  updatedSvg,
  '2e_1_C_Height',
  {
    'x': '$_labelXOffset',
    'y': '${positions['labelY']}',
    'text-anchor': 'start',
    'dominant-baseline': 'middle',
    'content': formatHeightLabel(observerHeight),
    'style': 'visibility: visible'
  }
);

// Example arrow update
updatedSvg = SvgElementUpdater.updatePathElement(
  updatedSvg,
  '2e_1_C_Top_arrow',
  {
    'd': 'M $_xCoord,${positions['topArrowY']} V ${positions['topArrowheadY']}',
    'visibility': 'visible',
    'stroke': '#000000',
    'stroke-width': '1.99598'
  }
);
```

## Best Practices

1. **Visibility Management**
   - Always use `SvgElementUpdater.hideElement()` for hiding elements
   - Return early after hiding elements
   - Never set positions when elements are hidden

2. **Position Calculations**
   - Use fixed offsets in viewBox coordinates
   - Maintain consistent spacing between elements
   - Anchor elements to existing diagram lines

3. **Label Formatting**
   - Include proper unit conversion (metric/imperial)
   - Maintain consistent decimal places
   - Add space before unit display

4. **Error Handling**
   - Handle null observer height gracefully
   - Validate position calculations
   - Maintain extensive debug logging

## Related Documentation
- [C-Height Implementation](c_height_implementation.md)
- [Geometric Model](../../technical/geometric_model.md)
- [Diagram Architecture](../../technical/diagram_architecture.md)
