# Measurement Group Implementation Guide

## Overview

This guide details the code implementation patterns for measurement groups, using C_Height (2_*) as the reference implementation.

## Related Documentation
- [1_measurement_groups_guide.md](1_measurement_groups_guide.md) - Main guide
- [1_1_measurement_config_guide.md](1_1_measurement_config_guide.md) - Configuration guide
- [1_3_measurement_testing_guide.md](1_3_measurement_testing_guide.md) - Testing guide

## Core Components

### 1. Label Group Handler

```dart
// Standard usage pattern
updatedSvg = LabelGroupHandler.updateTextElement(
  updatedSvg,
  '2_2_C_Height',
  {
    'x': '$xCoord',
    'y': '${positions['labelY']}',
  },
  'heightMeasurement',  // Group name for consistent styling
);
```

Key points:
- Use LabelGroupHandler for all text updates
- Specify measurement group for consistent styling
- Handle position updates through standard coordinate map

### 2. Position Calculation

```dart
Map<String, double> calculatePositions(double height) {
  if (!hasSufficientSpace(height)) {
    return {'visible': 0.0};
  }
  
  return {
    'visible': 1.0,
    'labelY': calculateLabelY(height),
    'topArrowY': calculateTopY(height),
    'bottomArrowY': calculateBottomY(height)
  };
}
```

Key points:
- Centralize position calculations in dedicated method
- Include visibility flag
- Return all positions in single map
- Handle insufficient space cases

### 3. Visibility Management

```dart
bool hasSufficientSpace(double height) {
  return height >= TOTAL_REQUIRED_HEIGHT;
}

void updateVisibility(List<String> elements, bool isVisible) {
  for (final elementId in elements) {
    updatedSvg = isVisible
      ? SvgElementUpdater.showElement(updatedSvg, elementId)
      : SvgElementUpdater.hideElement(updatedSvg, elementId);
  }
}
```

Key points:
- Define clear space requirements
- Handle group visibility together
- Use consistent show/hide methods

### 4. Debug Support

```dart
if (kDebugMode) {
  debugPrint('Height elements hidden due to insufficient space');
  debugPrint('Current height: $height');
  debugPrint('Required height: $REQUIRED_HEIGHT');
}
```

Key points:
- Use kDebugMode for conditional logging
- Log key measurements
- Include visibility decision factors

## Implementation Process

1. **Setup**
   - Define group constants
   - Set up position calculation methods
   - Implement visibility checks

2. **Label Value Handling**
   - Implement getLabelValues()
   - Read prefix from config
   - Format values consistently

3. **Position Updates**
   - Calculate all positions
   - Update elements as group
   - Maintain relative positioning

4. **Visibility Management**
   - Check space requirements
   - Update group visibility
   - Handle edge cases

## Best Practices

1. **Code Organization**
   - Group related methods together
   - Use clear naming conventions
   - Maintain consistent patterns

2. **Error Handling**
   - Validate config values
   - Provide fallbacks
   - Log issues in debug mode

3. **Performance**
   - Minimize SVG updates
   - Cache calculations where possible
   - Use efficient update methods

## Implementation Checklist

- [ ] Constants defined
- [ ] Position calculations implemented
- [ ] Visibility checks added
- [ ] Label values handled
- [ ] Debug logging setup
- [ ] Error handling in place
- [ ] Performance optimizations applied
