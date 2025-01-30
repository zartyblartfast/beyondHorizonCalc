# Measurement Testing Guide

## Overview
This guide provides a comprehensive testing approach for measurement groups in the Beyond Horizon Calculator. Following these testing procedures ensures reliable and accurate measurements.

## Test Categories

### 1. Value Accuracy Tests

#### Unit Conversions
- [ ] Kilometer to meter conversion
- [ ] Kilometer to feet conversion
- [ ] Proper rounding in display values
- [ ] Consistent unit handling across changes

#### Mathematical Relationships
- [ ] XZ = h2 + h3 (Total height = Hidden + Visible)
- [ ] h1 affects h2 calculation correctly
- [ ] Distance affects h2 calculation correctly
- [ ] All heights are non-negative

### 2. Visual Tests

#### Element Positioning
- [ ] Correct x-coordinate for measurement group
- [ ] Proper vertical alignment of elements
- [ ] Label centered between arrows
- [ ] No overlap with other measurement groups

#### Style Conformance
- [ ] Arrow style matches specification
- [ ] Text font and size are correct
- [ ] Colors match design requirements
- [ ] Consistent spacing and padding

#### Visibility Management
- [ ] Elements hide when insufficient space
- [ ] Elements show when space is sufficient
- [ ] Smooth transitions between states
- [ ] No partial visibility states

### 3. Input Response Tests

#### Observer Height Changes
- [ ] C-Height updates correctly
- [ ] H-Height recalculates properly
- [ ] V-Height adjusts appropriately
- [ ] All transitions are smooth

#### Target Height Changes
- [ ] Z-Height updates correctly
- [ ] V-Height recalculates properly
- [ ] H-Height adjusts if needed
- [ ] Maintains mathematical relationships

#### Distance Changes
- [ ] H-Height updates correctly
- [ ] V-Height recalculates properly
- [ ] Z-Height remains constant
- [ ] C-Height remains constant

### 4. Edge Case Tests

#### Zero Values
- [ ] Observer at sea level (h1 = 0)
- [ ] No hidden portion (h2 = 0)
- [ ] No visible portion (h3 = 0)
- [ ] Zero target height (XZ = 0)

#### Extreme Values
- [ ] Very large target heights
- [ ] Very small target heights
- [ ] Maximum observer heights
- [ ] Maximum distances

#### Special Cases
- [ ] Target fully hidden
- [ ] Target fully visible
- [ ] Observer higher than target
- [ ] Equal visible and hidden portions

## Test Procedures

### 1. Value Verification
```dart
void testHeightCalculations() {
  // Test unit conversions
  expect(convertFromKm(1.0), equals(1000.0));  // To meters
  
  // Test mathematical relationships
  expect(result.visibleTargetHeight + result.hiddenHeight,
         closeTo(targetHeight / 1000.0, 0.001));  // In km
         
  // Test non-negative constraints
  expect(result.hiddenHeight, greaterThanOrEqualTo(0.0));
  expect(result.visibleTargetHeight, greaterThanOrEqualTo(0.0));
}
```

### 2. Position Verification
```dart
void testPositionCalculations() {
  // Test sufficient space check
  expect(hasSufficientSpace(topY, bottomY), isTrue);
  
  // Test position calculations
  final positions = calculatePositions(topY, bottomY);
  expect(positions['labelY'],
         closeTo((topY + bottomY) / 2.0, 0.001));
         
  // Test visibility management
  expect(positions['visible'], equals(1.0));
}
```

### 3. Style Verification
```dart
void testStyleConformance() {
  // Test arrow style
  expect(getArrowStyle(),
         contains('stroke-width="1.99598"'));
         
  // Test text style
  expect(getLabelStyle(),
         contains('font-size="12.0877px"'));
}
```

## Test Data Sets

### 1. Standard Cases
```dart
final standardTests = [
  {'h1': 2.0, 'XZ': 100.0, 'distance': 10.0},
  {'h1': 5.0, 'XZ': 50.0, 'distance': 5.0},
  {'h1': 10.0, 'XZ': 200.0, 'distance': 15.0},
];
```

### 2. Edge Cases
```dart
final edgeCases = [
  {'h1': 0.0, 'XZ': 100.0, 'distance': 10.0},  // Observer at sea level
  {'h1': 2.0, 'XZ': 0.0, 'distance': 10.0},    // Zero target height
  {'h1': 2.0, 'XZ': 100.0, 'distance': 0.0},   // Zero distance
];
```

### 3. Extreme Cases
```dart
final extremeCases = [
  {'h1': 1000.0, 'XZ': 10000.0, 'distance': 100.0},  // Very large values
  {'h1': 0.1, 'XZ': 0.1, 'distance': 0.1},           // Very small values
];
```

## Testing Workflow

1. **Setup Phase**
   - Initialize calculator with test data
   - Verify initial state
   - Record starting conditions

2. **Execution Phase**
   - Run through test cases
   - Capture measurements
   - Record visual state

3. **Verification Phase**
   - Compare results with expected values
   - Verify visual positioning
   - Check mathematical relationships

4. **Documentation Phase**
   - Record test results
   - Document any issues
   - Update test cases if needed

## Common Issues and Solutions

### 1. Value Mismatches
**Problem**: Calculated values don't match expected results  
**Solution**: Verify unit conversions and calculations
```dart
// Add debug logging
debugPrint('Input (km): $heightInKm');
debugPrint('Converted (m): ${convertFromKm(heightInKm)}');
```

### 2. Position Errors
**Problem**: Elements not properly positioned  
**Solution**: Check coordinate calculations
```dart
// Add position validation
assert(labelY > topY && labelY < bottomY);
assert(topArrowEnd < labelY);
assert(bottomArrowStart > labelY);
```

### 3. Style Inconsistencies
**Problem**: Visual elements don't match specification  
**Solution**: Verify style properties
```dart
// Validate style properties
expect(element.style.fontFamily, equals('Calibri'));
expect(element.style.fontSize, equals('12.0877px'));
```

## Best Practices

1. Test systematically and thoroughly
2. Document all test cases and results
3. Include edge cases and extreme values
4. Verify both calculations and visuals
5. Maintain test data sets
6. Update tests when adding features
7. Automate tests where possible

## Related Documentation
- [Measurement Types](../technical/measurement_types.md)
- [Coordinate System](../technical/coordinate_system.md)
- [Implementation Guide](../implementation/measurement_group_guide.md)
