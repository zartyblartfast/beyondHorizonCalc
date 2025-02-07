# BeyondHorizonCalc Field Reference

## Input Fields

### Required Fields
- Observer Height (h1) [meters/feet]
  - Range: 2 to 9,000 meters (or 6.56 to 29,527.56 feet)
  - Must be greater than 0

- Distance (L0) [kilometers/miles]
  - Range: 5 to 600 kilometers (or 3.11 to 372.82 miles)
  - Must be greater than 0

- Refraction Factor (default: 1.07)
  - Preset values:
    - None (1.00)
    - Low (1.02)
    - Below Average (1.04)
    - Average (1.07) - default
    - Above Average (1.10)
    - High (1.15)
    - Very High (1.20)
    - Extremely High (1.25)

### Optional Fields
- Target Height (XZ) [meters/feet]
  - Range: 0 to 9,000 meters (or 0 to 29,527.56 feet)
  - Optional field - can be left empty

### Units Toggle
- Metric (meters, kilometers)
- Imperial (feet, miles)
  - Automatic conversion:
    - Heights: 1m = 3.28084ft
    - Distances: 1km = 0.621371mi

## Results Display

### Basic Results (Always Shown)
- Distance to Horizon (D1) [km/mi]
- Horizon Dip Angle [degrees]
- Hidden Height (h2, XC) [m/ft]

### Additional Results (When Target Height is Provided)
- Visible Height (h3) [m/ft]
- Apparent Visible Height (CD) [m/ft]
- Perspective Scaled Apparent Visible Height [m/ft]

### Visual Indicators
- Dynamic diagram showing the line of sight scenario:
  - BTH_1.svg: Basic horizon view (no target height)
  - BTH_2.svg: Target fully hidden
  - BTH_3.svg: Target at horizon
  - BTH_4.svg: Target partially visible

## Preset Controls
- Preset Selection Dropdown
  - Loads predefined observer/target configurations
  - Updates all input fields automatically
- Info Button ('i')
  - Shows preset details
  - Displays images and sources
  - Shows location details
- Report Generation
  - Creates detailed PDF report with calculations and diagrams

## Notes
- All height measurements can be toggled between meters and feet
- All distance measurements can be toggled between kilometers and miles
- Refraction factor affects the curvature calculations
- Custom values can be entered when no preset is selected
