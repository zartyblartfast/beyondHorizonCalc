# SVG Requirements for Flutter Integration

## Essential Requirements
1. **Structure**
   - Group related elements with `<g id="meaningful-name">`
   - Use absolute coordinates (M, L, C) not relative
   - Keep paths simple - minimal control points
   - Separate major components into distinct paths

2. **Technical Specs**
   - viewBox: Use round numbers, reasonable scale (e.g., 0 0 600 300)
   - No embedded styles or colors
   - No unnecessary metadata
   - Clean, optimized paths

3. **Example Structure**
```svg
<svg viewBox="0 0 600 300">
  <g id="main-structure">
    <path id="base-line" d="M100,200 L500,200"/>
  </g>
  <g id="measurements">
    <circle id="point-a" cx="100" cy="200" r="2"/>
  </g>
</svg>
```

Questions? Contact: [Your Contact Info]
