# Guide to Modifying the OverHorizon Diagram

## Documentation Structure

1. **Core Documentation**
   - [1_measurement_groups_guide.md](1_measurement_groups_guide.md) - Main guide for measurement groups
   - [Geometric Model Reference](measurement_groups/technical/geometric_model.md) - Complete geometric model and mathematical relationships
   - [Diagram Architecture](measurement_groups/technical/diagram_architecture.md) - Complete system architecture

2. **Implementation Guides**
   - [1_1_measurement_config_guide.md](1_1_measurement_config_guide.md) - Configuration patterns
   - [1_2_measurement_implementation_guide.md](1_2_measurement_implementation_guide.md) - Code patterns
   - [1_3_measurement_testing_guide.md](1_3_measurement_testing_guide.md) - Testing requirements

3. **Reference Implementations**
   - [2_1_c_height_implementation.md](2_1_c_height_implementation.md) - C-Height (reference)
   - [2_2_z_height_implementation.md](2_2_z_height_implementation.md) - Z-Height

## Quick Start

1. **Understand the Geometry**
   - Read [Geometric Model Reference](measurement_groups/technical/geometric_model.md) for the mathematical model
   - Key points: Observer (A), Horizon (B), Target (X), Hidden Height (XC)

2. **Follow Implementation Standards**
   - Start with [1_measurement_groups_guide.md](1_measurement_groups_guide.md)
   - Use C-Height as reference: [2_1_c_height_implementation.md](2_1_c_height_implementation.md)
   - Follow configuration patterns: [1_1_measurement_config_guide.md](1_1_measurement_config_guide.md)

3. **Locate the Code**
   - Main implementation: `lib/widgets/calculator/diagram_display.dart`
   - SVG assets: `assets/svg/BTH_*.svg`
   - Configuration: `assets/info/diagram_spec.json`

4. **Implementation Details**
   - The diagram uses `flutter_svg` to render SVG files
   - SVG files are loaded and modified dynamically based on calculations
   - Labels are updated using `DiagramLabelService`
   - Aspect ratio must be maintained at 500:1000 (including right margin)

## Coordinate System and Scaling

### Core Diagram Area
- **Working Area**: 400x1000 units (-200 to +200 horizontally)
- **Purpose**: Contains all main diagram elements and calculations
- **Origin**: Center-aligned at (0,0)

### ViewBox Configuration
```json
{
  "metadata": {
    "svgSpec": {
      "viewBox": {
        "width": 500,    // Total width including right margin
        "height": 1000,
        "scaling": {
          "preserveAspectRatio": true
        }
      }
    }
  }
}
```

> **Critical**: When implementing scaling or layout:
> 1. Always use the full viewBox dimensions from config (`metadata.svgSpec.viewBox`)
> 2. Never hard-code dimensions like 500 or 1000
> 3. The aspect ratio must be maintained using viewBox.width:viewBox.height
> 4. Example: `height = (containerWidth * viewBoxHeight) / viewBoxWidth`
> 5. The viewBox dimensions define the SVG's coordinate space - all elements (paths, text, etc.) are positioned relative to this space
> 6. Changing these values will affect the entire diagram's layout and proportions

### SVG Coordinate Space
- **Total Width**: 500 units
  - Core diagram area: 400 units (-200 to +200)
  - Right margin: 100 units (400 to 500)
  - All X-coordinates are relative to this 500-unit space
- **Total Height**: 1000 units
  - All Y-coordinates use this full height
  - Vertical zones must maintain their relative positions
  - Text and shape proportions depend on this scale

### Implementation Details
- SVG rendering is handled in `diagram_display.dart`
- Diagram config is loaded from `assets/info/diagram_spec.json`
- Access config via `MountainDiagramViewModel.diagramSpec`
- All scaling calculations should use full viewBox dimensions
- When modifying the diagram:
  1. Check the config values first
  2. Use relative positioning based on viewBox dimensions
  3. Test with different container sizes to verify scaling

### Margin Areas
- **Right Margin**: 100 units (400 to 500)
  - Purpose: Space for 'X' and 'Z' labels
  - Labels must stay anchored to their corresponding elements
- **Left Margin**: (Future) 100 units (-300 to -200)
  - Will provide space for additional labels
  - Must maintain diagram proportions

### Scaling Behavior
1. **Aspect Ratio**
   - Must be preserved to prevent vertical stretching
   - Based on working area (400x1000) not total viewBox
   - Configured via `preserveAspectRatio` in diagram_spec.json

2. **Margin Handling**
   - Margins don't affect core diagram scaling
   - Labels in margins stay anchored to their reference points
   - Adding margins should not stretch or distort the diagram

### Common Pitfalls
1. **Incorrect Scaling**
   - ❌ Using viewBox width (500) for aspect ratio calculations
   - ❌ Applying independent horizontal and vertical scaling
   - ✅ Use working area (400x1000) for consistent proportions

2. **Margin Issues**
   - ❌ Adding vertical space when extending horizontally
   - ❌ Changing core diagram scale when adding margins
   - ✅ Maintain core 400x1000 proportions regardless of margins

### Implementation Notes
- Scaling is handled in `diagram_display.dart`
- Configuration in `diagram_spec.json` controls behavior
- Changes to margins should not affect core diagram proportions
- Always test with various screen sizes to verify scaling

## Common Modification Patterns

### 1. Adding a New Line
```dart
// In DiagramDisplay.paint():
Path newLine = Path();
newLine.moveTo(startX, startY);  // Use viewBox coordinates directly
newLine.lineTo(endX, endY);

final paint = Paint()
  ..color = lineColor
  ..style = PaintingStyle.stroke
  ..strokeWidth = 2;
canvas.drawPath(newLine, paint);
```

### 2. Positioning Relative to Reference Points
```dart
// Reference points are in viewBox coordinates
final cPointY = _getConfigDouble(['metadata', 'svgSpec', 'cPointY'], 342.0);

// Position elements relative to these points
Path elementPath = Path();
elementPath.moveTo(-200, cPointY + offset);  // offset from reference point
```

### 3. Adding Labels
```dart
// Labels are positioned in viewBox coordinates
final textStyle = TextStyle(
  color: Color(0xFF800080),
  fontSize: 16,
  fontWeight: FontWeight.bold,
);

TextPainter labelPainter = TextPainter(
  text: TextSpan(text: 'Label Text', style: textStyle),
  textDirection: TextDirection.ltr,
);
labelPainter.layout();
labelPainter.paint(canvas, Offset(x, y));
```

## Key Implementation Details

### ViewBox Coordinates
- The viewBox is our "common language"
- Use coordinates directly from the geometric calculations
- No need for manual transformations
- Only Y-axis is flipped for Flutter's coordinate system

### Dynamic Updates
- Elements update automatically through CustomPainter
- Position changes are driven by configuration values
- No need for manual refresh calls

### Layer Organization
- Keep elements in their appropriate layer groups
- Sky: Labels and upper elements (y: 0-342)
- Observer: Critical reference elements (y: 342-474)
- Mountain: Dynamic elements (y: 474-1000)

## Common Pitfalls

1. **Coordinate System**
   - ✅ Use viewBox coordinates directly
   - ❌ Don't try to transform coordinates manually

2. **Element Positioning**
   - ✅ Position relative to reference points (like C_Point_Line)
   - ❌ Don't use hardcoded positions

3. **Layer Management**
   - ✅ Keep elements in their appropriate layer groups
   - ❌ Don't mix elements between groups

## Debugging Tips

1. **Visual Issues**
   - Check the layer group boundaries
   - Verify reference point positions
   - Ensure paths are using viewBox coordinates

2. **Dynamic Updates**
   - Verify configuration values are being read correctly
   - Check that elements are positioned relative to reference points

3. **Performance**
   - Keep path operations simple
   - Use appropriate stroke widths for the scale

## Example: Adding a Distance Line

```dart
void paint(Canvas canvas, Size size) {
  // ... existing setup code ...

  // Add a distance line in the Mountain group
  final mountainBaseY = 474.0;  // Mountain group start
  
  Path distanceLine = Path();
  distanceLine.moveTo(-90, mountainBaseY);  // Mountain base left
  distanceLine.lineTo(90, mountainBaseY);   // Mountain base right
  
  final distancePaint = Paint()
    ..color = lineColor
    ..style = PaintingStyle.stroke
    ..strokeWidth = 2;
  canvas.drawPath(distanceLine, distancePaint);
  
  // Add a label
  TextPainter distanceLabel = TextPainter(
    text: TextSpan(text: 'Distance', style: textStyle),
    textDirection: TextDirection.ltr,
  );
  distanceLabel.layout();
  distanceLabel.paint(canvas, Offset(0, mountainBaseY + 10));
}
