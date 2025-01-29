# C-Height Implementation Guide

## Overview

This document details the reference implementation of the C-Height measurement group (2_*). This implementation serves as the standard pattern for all measurement groups.

## Related Documentation
- [1_measurement_groups_guide.md](1_measurement_groups_guide.md) - Main guide
- [1_1_measurement_config_guide.md](1_1_measurement_config_guide.md) - Configuration patterns
- [1_2_measurement_implementation_guide.md](1_2_measurement_implementation_guide.md) - Implementation details

## Components

The C-Height measurement consists of five elements:
1. Top arrowhead (2_1_C_Top_arrowhead)
2. Top arrow (2_1_C_Top_arrow)
3. Height label (2_2_C_Height)
4. Bottom arrow (2_3_C_Bottom_arrow)
5. Bottom arrowhead (2_3_C_Bottom_arrowhead)

## SVG Element Specifications

### Text Label (2_2_C_Height)
```css
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
```css
stroke="#000000"
stroke-width="1.99598"
```

### Top Arrowhead (2_1_C_Top_arrowhead)
```css
style="fill:#000000;stroke:none;fill-opacity:1"
d="m -229.47326,349.35208 l -5,10 l 10,0 z"
```

## Implementation Details

### Fixed Properties
- X-coordinate: -250 for all elements
- Style properties must match original SVG
- All elements treated as single visibility unit

### Dynamic Properties
- Vertical positioning based on Observer Height (h1)
- Label text format: "h1: [value]"
- Arrow scaling with height changes

### Visibility Rules
- Check space between C_Point_Line and Observer_Height_Above_Sea_Level
- No partial display - all elements shown or hidden together

## Configuration

### JSON Configuration
```json
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
  }
}
```

## Implementation

### Label Value Handling
```dart
Map<String, String> getLabelValues() {
  final observerHeight = result?.h1;
  final prefix = _getConfigString(['labels', 'points', '2_2_C_Height', 'prefix']) ?? 'h1: ';
  labels['2_2_C_Height'] = '$prefix${formatHeight(observerHeight)}';
}
```

### Position Management
```dart
Map<String, double> calculateCHeightPositions(double h1) {
  if (!hasSufficientSpace(h1)) {
    return {'visible': 0.0};
  }
  
  return {
    'visible': 1.0,
    'labelY': calculateLabelY(h1),
    'topArrowY': calculateTopY(h1),
    'bottomArrowY': calculateBottomY(h1)
  };
}
```

### Visibility Control
```dart
bool hasSufficientSpace(double h1) {
  return h1 >= C_HEIGHT_TOTAL_REQUIRED_HEIGHT;
}

void updateVisibility(List<String> elements, bool isVisible) {
  for (final elementId in elements) {
    updatedSvg = isVisible
      ? SvgElementUpdater.showElement(updatedSvg, elementId)
      : SvgElementUpdater.hideElement(updatedSvg, elementId);
  }
}
```

## Key Features

1. **Configuration-Driven**
   - Styles defined in JSON
   - Prefix configurable
   - Format rules specified

2. **Consistent Position Management**
   - Centralized position calculations
   - Clear visibility rules
   - Group-based updates

3. **Error Handling**
   - Fallback values
   - Space validation
   - Debug logging

4. **Maintainable Structure**
   - Clear method organization
   - Consistent naming
   - Documented patterns

## Implementation Steps

1. **Configuration**
   - Add JSON configuration
   - Define style properties
   - Set content rules

2. **Code Setup**
   - Implement getLabelValues
   - Add position calculations
   - Set up visibility checks

3. **Testing**
   - Test configuration loading
   - Verify position calculations
   - Check visibility rules

## Best Practices

1. **Configuration First**
   - Always prefer JSON configuration
   - Minimize hardcoded values
   - Document configuration structure

2. **Group Operations**
   - Update elements as a group
   - Maintain consistent visibility
   - Use shared styling

3. **Error Prevention**
   - Validate inputs
   - Provide fallbacks
   - Log important state changes
