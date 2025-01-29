# Measurement Group Configuration Guide

## Overview

This guide details the configuration patterns for measurement groups in the diagram_spec.json file, using C_Height (2_*) as the reference implementation.

## Related Documentation
- [1_measurement_groups_guide.md](1_measurement_groups_guide.md) - Main guide
- [1_2_measurement_implementation_guide.md](1_2_measurement_implementation_guide.md) - Implementation details
- [1_3_measurement_testing_guide.md](1_3_measurement_testing_guide.md) - Testing guide

## JSON Configuration Structure

### Label Configuration

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

### Key Configuration Elements

1. **Style Definition**
   - All styles must be defined in JSON
   - Required style properties:
     - fontFamily
     - fontSize
     - fontWeight
     - fill
     - textAnchor

2. **Content Configuration**
   - Prefix definition
   - Value source specification
   - Format rules
   - Units handling

3. **Position References**
   - X-coordinate definition
   - Y-coordinate references
   - Relative positioning rules

## Label Group Structure

1. **Naming Convention**
   - Use consistent prefixes (e.g., 2_* for C_Height)
   - Component numbering pattern:
     - *_1_* : Top elements
     - *_2_* : Label elements
     - *_3_* : Bottom elements

2. **Group Components**
   ```json
   {
     "heightMeasurement": {
       "components": {
         "label": ["2_2_C_Height"],
         "arrows": [
           "2_1_C_Top_arrow",
           "2_3_C_Bottom_arrow"
         ],
         "arrowheads": [
           "2_1_C_Top_arrowhead",
           "2_3_C_Bottom_arrowhead"
         ]
       }
     }
   }
   ```

## Component Standards

### Arrowhead Specifications
- All arrowheads must be centered on their arrow lines
- Standard dimensions: 10x10 units
- **Group Positions**:
  - Observer Group (C_Height): Left side (x=-250)
  - Mountain Group (Z_Height): Right side (x=325)

- **Reference Point Adjustment**:
  ```svg
  <!-- Example for Mountain Group (x=325) -->
  <!-- INCORRECT - Using arrow line x-coordinate as reference -->
  d="m 325,${y} -5,10 h 10 z"  <!-- Results in off-center arrowhead -->
  
  <!-- CORRECT - Reference point adjusted left by half width -->
  d="m 320,${y} -5,10 h 10 z"  <!-- Creates centered arrowhead at x=325 -->
  
  <!-- Example for Observer Group (x=-250) -->
  <!-- INCORRECT - Using arrow line x-coordinate as reference -->
  d="m -250,${y} -5,10 h 10 z"  <!-- Results in off-center arrowhead -->
  
  <!-- CORRECT - Reference point adjusted left by half width -->
  d="m -255,${y} -5,10 h 10 z"  <!-- Creates centered arrowhead at x=-250 -->
  ```
- Positioning calculation:
  ```dart
  // Always adjust reference point left by half width
  double arrowLineX = groupXCoordinate;  // -250 for Observer, 325 for Mountain
  double pathRefX = arrowLineX - (arrowheadWidth / 2);  // Reference point for path
  ```
- Path construction sequence:
  1. Move to adjusted reference point (pathRefX, y)
  2. Draw left diagonal (-5,10)
  3. Draw horizontal line right (h 10)
  4. Close path (z)

### Label Standards

### Text Alignment
Label alignment is handled automatically by the LabelGroupHandler:
- Horizontal centering is applied to all measurement group labels
- Configuration in diagram_spec.json focuses on content and styling:
  ```json
  {
    "type": "text",
    "style": {
      "fontFamily": "Calibri",
      "fontSize": "12.0877px",
      "fontWeight": "bold",
      "fill": "#552200"
    }
  }
  ```

### Vertical Positioning
- All measurement group labels must be vertically centered between their arrows
- Standard label height is 15 units
- Equal padding must be maintained above and below label text
- Use this calculation pattern:
  ```dart
  double totalSpace = bottomArrowY - topArrowY;
  double labelHeight = 15;  // Standard height
  labelY = topArrowY + (totalSpace - labelHeight) / 2;  // Centers with equal padding
  ```

### Standard Style Properties
```json
{
  "style": {
    "fontFamily": "Calibri",
    "fontSize": "12.0877px",
    "fontWeight": "bold",
    "fill": "#552200",
    "textAnchor": "middle"  // Critical - do not omit
  }
}
```

### Common Label Alignment Issues
1. Horizontal Misalignment:
   - Using 'start' or 'left' text-anchor
   - Omitting text-anchor property
   - Manual x-offset adjustments
2. Vertical Misalignment:
   - Uneven padding above/below
   - Incorrect total height calculation
   - Not accounting for font metrics

## Best Practices

1. **Style Consistency**
   - Use shared style definitions where possible
   - Maintain consistent font sizes within groups
   - Use standard color schemes

2. **Value Formatting**
   - Define precise decimal places
   - Specify unit inclusion rules
   - Use consistent prefix patterns

3. **Position Management**
   - Define fixed x-coordinates
   - Use relative y-coordinates
   - Maintain consistent spacing

## Configuration Checklist

- [ ] Label ID follows naming convention
- [ ] All style properties defined
- [ ] Content prefix configured
- [ ] Value source specified
- [ ] Format rules defined
- [ ] Position references set
- [ ] Group components listed
- [ ] Style consistency verified
