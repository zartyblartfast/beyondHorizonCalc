# Measurement Group Testing Guide

## Overview

This guide outlines testing requirements and patterns for measurement groups, using C_Height (2_*) as the reference implementation.

## Configuration Testing

### 1. JSON Loading Tests

```dart
test('loads configuration correctly', () {
  final config = loadConfig();
  expect(config['labels']['points']['2_2_C_Height'], isNotNull);
  expect(config['labels']['points']['2_2_C_Height']['prefix'], equals('h1: '));
});
```

Key points:
- Verify all required config elements
- Test fallback values
- Validate style properties

### 2. Style Application Tests

```dart
test('applies styles correctly', () {
  final updatedSvg = updateElement(svg, elementId);
  expect(updatedSvg, contains('font-family="Calibri"'));
  expect(updatedSvg, contains('font-size="12.0877px"'));
});
```

Key points:
- Test style application
- Verify text properties
- Check position attributes

## Functional Testing

### 1. Value Display Tests

```dart
test('formats values correctly', () {
  final labels = getLabelValues();
  expect(labels['2_2_C_Height'], matches(r'h1: \d+\.\d km'));
});
```

Key points:
- Test value formatting
- Verify prefix usage
- Check unit display

### 2. Visibility Tests

```dart
test('handles visibility correctly', () {
  expect(hasSufficientSpace(50), isFalse);
  expect(hasSufficientSpace(150), isTrue);
});
```

Key points:
- Test space calculations
- Verify visibility rules
- Check group behavior

### 3. Position Tests

```dart
test('calculates positions correctly', () {
  final positions = calculatePositions(100);
  expect(positions['labelY'], isNotNull);
  expect(positions['topArrowY'], lessThan(positions['labelY']));
});
```

Key points:
- Test position calculations
- Verify relative positioning
- Check boundary conditions

## Visual Testing

### 1. Element Placement

- Verify arrow alignment
- Check label centering
- Test spacing consistency

### 2. Style Consistency

- Verify font rendering
- Check color application
- Test text alignment

### 3. Animation Testing

- Verify smooth transitions
- Test position updates
- Check visibility changes

## Debug Testing

### 1. Log Verification

```dart
test('logs debug information', () {
  final logs = captureDebugLogs(() {
    updateElements(insufficientSpace: true);
  });
  expect(logs, contains('Height elements hidden'));
});
```

Key points:
- Verify debug messages
- Test logging conditions
- Check error reporting

## Testing Checklist

- [ ] Configuration loading tests
- [ ] Style application tests
- [ ] Value formatting tests
- [ ] Visibility rule tests
- [ ] Position calculation tests
- [ ] Visual verification tests
- [ ] Debug logging tests
- [ ] Edge case tests
