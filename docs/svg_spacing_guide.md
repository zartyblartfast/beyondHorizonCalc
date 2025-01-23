# SVG Spacing Configuration Guide

## Current Configuration

### SVG Viewbox Setup
The diagram maintains a critical working area from x=-200 to x=400 and y=0 to y=1000, with x=0 being the exact vertical center. This is achieved through careful configuration of both the SVG and Dart code.

```xml
<!-- BTH_viewBox_diagram1.svg -->
<svg
   width="500"
   height="1000"
   viewBox="-200 0 600 1000"
   version="1.1"
   id="svg5"
   inkscape:version="1.2.2 (732a01da63, 2022-12-09)"
   xmlns="http://www.w3.org/2000/svg"
   xmlns:svg="http://www.w3.org/2000/svg">
```

### Dart Implementation
The scaling and positioning is handled in overHorizon.dart:

```dart
void paint(Canvas canvas, Size size) {
  // First flip the Y axis since SVG and Flutter use opposite Y directions
  canvas.scale(1, -1);
  canvas.translate(0, -size.height);
  
  // Calculate independent scales for x and y
  double scaleX = size.width / 500;
  double scaleY = size.height / 1000;
  
  // Center horizontally and account for viewBox x-offset
  double xOffset = 0;  // No need to center since we're using exact scaling
  canvas.translate(xOffset - (-200 * scaleX), 0);  // Adjust for viewBox x-offset
  
  // Apply independent scaling
  canvas.scale(scaleX, scaleY);
}
```

## How to Modify Spacing

### Increasing Right Spacing to 200
To increase the right spacing to 200 units while maintaining the center point and working area:

1. Modify the SVG viewBox:
```xml
<!-- Change viewBox to add 100 more units to the width -->
<svg
   width="500"
   height="1000"
   viewBox="-200 0 700 1000"  <!-- Changed from 600 to 700 -->
   ...
>
```

2. Update the scaling calculation in overHorizon.dart:
```dart
// Update the width scaling factor
double scaleX = size.width / 600;  // Changed from 500 to 600
```

### Adding Left Spacing (100 or 200 units)
To add spacing on the left while maintaining the center point:

1. Modify the SVG viewBox:
```xml
<!-- For 100 units left spacing -->
<svg
   width="500"
   height="1000"
   viewBox="-300 0 700 1000"  <!-- Start at -300 instead of -200 -->
   ...
>

<!-- For 200 units left spacing -->
<svg
   width="500"
   height="1000"
   viewBox="-400 0 800 1000"  <!-- Start at -400 instead of -200 -->
   ...
>
```

2. Update the scaling calculation in overHorizon.dart:
```dart
// For 100 units left spacing
double scaleX = size.width / 600;  // Total width now 600

// For 200 units left spacing
double scaleX = size.width / 700;  // Total width now 700

// The translate call remains the same as it uses the viewBox x-offset:
canvas.translate(xOffset - (viewBoxStartX * scaleX), 0);
```

## Important Considerations

1. **Maintaining Center Point**: The x=0 point must remain at the vertical center of the working area. This is crucial for proper diagram rendering.

2. **Scaling**: When modifying the viewBox, always update the scaling factors in the Dart code to match the new total width.

3. **Working Area**: Never modify the core working area (-200 to 400 x 0 to 1000). Only add space outside this range.

4. **Aspect Ratio**: The height (1000) and vertical scaling should remain unchanged to maintain proper proportions.

5. **ViewBox Calculation**:
   - Total width = |left extent| + right extent
   - For right spacing: increase the third viewBox parameter
   - For left spacing: decrease the first viewBox parameter and increase the third parameter accordingly

This configuration ensures that the diagram maintains its proper center point and scaling while allowing flexible spacing on either side.
