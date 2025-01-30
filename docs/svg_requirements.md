# SVG Requirements for Beyond Horizon Calculator

> For overall system architecture and implementation patterns, see [bth_diagram_architecture.md](./bth_diagram_architecture.md).

## Essential Requirements

### 1. Structure
- Group related elements with meaningful IDs:
  ```svg
  <g id="measurement-group-h1">
    <g id="arrows">...</g>
    <g id="labels">...</g>
  </g>
  ```
- Use absolute coordinates (M, L, C) not relative ones (m, l, c)
- Keep paths simple - minimize control points
- Separate major components into distinct paths

### 2. Technical Specifications

#### ViewBox Configuration
```svg
viewBox="<min-x> <min-y> <width> <height>"
```
- Current values: `-300 0 600 1000`
- These parameters define both coordinate space and scaling
- Must match configuration in `diagram_spec.json` exactly
- Changing these values affects both positioning and scaling

#### Coordinate Space
```
Horizontal Space (-300 to +300):
├── Left margin:  -300 to -250  (50 units, labels)
├── Left area:    -250 to -50   (200 units, measurements)
├── Center:       -50 to +50    (100 units, observer)
├── Right area:   +50 to +250   (200 units, measurements)
└── Right margin: +250 to +300  (50 units, labels)

Vertical Space (0 to 1000):
├── Sky area:     0 to 200      (200 units)
├── Main area:    200 to 800    (600 units)
└── Ground area:  800 to 1000   (200 units)
```

### 3. Element Requirements

#### Paths
```svg
<path 
  id="2_1_C_Height_Top_arrow"
  d="M-200,300 L-150,300"
  stroke="#000000"
  stroke-width="2"
/>
```
- Use descriptive IDs matching configuration
- Keep paths simple and flat where possible
- Use absolute coordinates
- Define visual properties inline

#### Text Elements
```svg
<text
  id="2_2_C_Height"
  x="-250"
  y="300"
  text-anchor="end"
  font-family="Arial"
  font-size="14"
>h₁</text>
```
- Position in margin areas when possible
- Use consistent font properties
- Align text appropriately with text-anchor

### 4. Measurement Groups

#### C-Height (h₁)
```svg
<g id="c-height-group">
  <!-- Top arrow -->
  <path id="2_1_C_Height_Top_arrow" d="M-200,200 L-150,200"/>
  <!-- Vertical line -->
  <path id="2_2_C_Height" d="M-175,200 L-175,400"/>
  <!-- Bottom arrow -->
  <path id="2_3_C_Height_Bottom_arrow" d="M-200,400 L-150,400"/>
  <!-- Label -->
  <text id="2_2_C_Height_Label" x="-250" y="300">h₁</text>
</g>
```

#### H-Height (h₂)
```svg
<g id="h-height-group">
  <!-- Similar structure to C-Height -->
  <path id="3_1_H_Height_Top_arrow" d="M150,400 L200,400"/>
  <path id="3_2_H_Height" d="M175,400 L175,600"/>
  <path id="3_3_H_Height_Bottom_arrow" d="M150,600 L200,600"/>
  <text id="3_2_H_Height_Label" x="250" y="500">h₂</text>
</g>
```

## Integration with Flutter

### 1. Asset Loading
```dart
// Load SVG from assets
final String svgString = await rootBundle.loadString('assets/BTH_viewBox.svg');
```

### 2. Rendering
```dart
// Render using flutter_svg
SvgPicture.string(
  svgString,
  width: MediaQuery.of(context).size.width,
  height: 300,
)
```

### 3. Element Updates
```dart
// Update element via SvgElementUpdater
svgElementUpdater.updateElement(
  elementId: '2_2_C_Height_Label',
  text: 'h₁: 1.5m'
);
```

## Common Pitfalls

1. **Incorrect ViewBox**
   - Symptoms: Misaligned elements, wrong scaling
   - Solution: Match viewBox exactly with diagram_spec.json

2. **Relative Coordinates**
   - Symptoms: Elements shift unexpectedly
   - Solution: Use absolute coordinates (M, L, C)

3. **Complex Paths**
   - Symptoms: Poor performance, difficult updates
   - Solution: Break into simpler paths

4. **Missing IDs**
   - Symptoms: Elements can't be updated
   - Solution: Add IDs matching diagram_spec.json

## Related Documentation
- [Diagram Architecture](./bth_diagram_architecture.md)
- [Measurement Types](./measurement_groups/technical/measurement_types.md)
- [Diagram Labels](./diagram_labels_spec.md)
