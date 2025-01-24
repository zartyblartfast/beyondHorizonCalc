# SVG Requirements for Flutter Integration

## Essential Requirements
1. **Structure**
   - Group related elements with `<g id="meaningful-name">`
   - Use absolute coordinates (M, L, C) not relative
   - Keep paths simple - minimal control points
   - Separate major components into distinct paths

2. **Technical Specs**
   - viewBox format: `viewBox="<min-x> <min-y> <width> <height>"`
   - All four parameters work together to define both coordinate space AND scaling:
     - min-x/y: Starting point of coordinate system
     - width/height: Total units in each dimension
     - Example: viewBox="-300 0 600 1000" means:
       - Coordinates from -300 to +300 horizontally (600 units total)
       - Coordinates from 0 to 1000 vertically
   - Changes to viewBox parameters affect both positioning AND scaling
   - Must match configuration in diagram_spec.json exactly

3. **Example Structure**
```svg
<svg viewBox="-300 0 600 300">
  <g id="main-structure">
    <!-- Core content in -200 to +200 range -->
    <path id="base-line" d="M-200,200 L200,200"/>
    <!-- Labels can use full -300 to +300 range -->
    <text x="-250" y="150">Label</text>
  </g>
</svg>
```

## BTH Diagram Requirements

### ViewBox Configuration
- Format: `viewBox="<min-x> <min-y> <width> <height>"`
- Current values: `-200 0 500 1000`
- These parameters define both coordinate space and scaling
- Must match configuration in diagram_spec.json
- Changing these values affects both positioning and scaling

### Coordinate Space
- Core diagram area: -200 to +200 horizontally (400 units)
- Right margin: +200 to +300 (100 units for labels)
- Height: 0 to 1000 units vertically
- All element coordinates must be within this space

### Adding Left Margin
To add a left margin while maintaining diagram proportions:
1. Update SVG viewBox to: `-300 0 500 1000`
2. Update diagram_spec.json to match these exact parameters
3. Do not modify the core diagram area (-200 to +200)
4. New left margin space: -300 to -200 (100 units for labels)
