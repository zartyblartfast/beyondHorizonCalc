# BeyondHorizonCalc Refactoring Plan

## Overview
This document outlines a step-by-step plan to refactor the calculator_form.dart file to improve maintainability, testability, and code organization. The plan is designed to be incremental and safe, with each step being independently verifiable.

## Goals
- Separate business logic from UI components
- Improve testability
- Reduce file size and complexity
- Make changes less error-prone
- Maintain existing functionality throughout the process

## Phase 1: Setup and Preparation
1. Create new branch for refactoring
   ```bash
   git checkout -b refactor/calculator-form
   ```

2. Add necessary test dependencies to pubspec.yaml
   - flutter_test
   - mockito (for mocking in tests)

3. Create initial test files:
   ```
   test/
   ├── services/
   │   └── curvature_calculator_test.dart
   └── widgets/
       └── calculator_form_test.dart
   ```

## Phase 2: Extract Calculation Logic
1. Create new service directory and files:
   ```
   lib/
   └── services/
       ├── models/
       │   └── calculation_result.dart
       └── curvature_calculator.dart
   ```

2. Steps:
   a. Create CalculationResult model class
   b. Implement CurvatureCalculator service
   c. Write tests for calculator service
   d. Modify calculator_form.dart to use new service
   e. Verify all calculations still work
   f. Commit changes

## Phase 3: Widget Decomposition
1. Create new widget files:
   ```
   lib/widgets/
   ├── calculator/
   │   ├── preset_selector.dart
   │   ├── input_fields.dart
   │   └── results_display.dart
   └── calculator_form.dart
   ```

2. Extract PresetSelector (First Widget)
   a. Create widget file and tests
   b. Move preset selection logic
   c. Update calculator_form.dart
   d. Verify functionality
   e. Commit changes

3. Extract InputFields (Second Widget)
   a. Create widget file and tests
   b. Move form fields logic
   c. Update calculator_form.dart
   d. Verify functionality
   e. Commit changes

4. Extract ResultsDisplay (Third Widget)
   a. Move existing ResultCard
   b. Create container widget
   c. Update calculator_form.dart
   d. Verify functionality
   e. Commit changes

## Phase 4: State Management
1. Create state management files:
   ```
   lib/
   └── state/
       └── calculator_state.dart
   ```

2. Steps:
   a. Implement state management class
   b. Move state from calculator_form.dart
   c. Update widgets to use state
   d. Write tests for state management
   e. Verify functionality
   f. Commit changes

## Testing Strategy
1. Unit Tests:
   - CurvatureCalculator service
   - CalculationResult model
   - State management

2. Widget Tests:
   - Individual widgets
   - Form validation
   - User interactions

3. Integration Tests:
   - Complete form workflow
   - Preset selection
   - Calculation accuracy

## Safety Measures
1. Git Checkpoints:
   - Commit after each successful extraction
   - Use meaningful commit messages
   - Tag important milestones

2. Feature Flags:
   ```dart
   const bool USE_NEW_CALCULATOR = true;
   ```
   - Toggle between old and new implementations
   - Easy rollback if issues arise

3. Documentation:
   - Update comments and documentation
   - Mark deprecated code
   - Document breaking changes

## Verification Steps
For each phase:
1. Run all tests
2. Manual testing of:
   - All form inputs
   - Preset selection
   - Calculations
   - Error states
3. Visual inspection of UI
4. Performance check

## Rollback Plan
1. Keep original code in separate branch
2. Document all changes in commits
3. Create restore points at key milestones
4. Maintain list of dependent components

## Timeline
1. Phase 1: 1 day
2. Phase 2: 2-3 days
3. Phase 3: 3-4 days
4. Phase 4: 2-3 days

Total estimated time: 8-11 days

## Success Criteria
- All tests passing
- No regression in functionality
- Improved code organization
- Smaller, more focused files
- Better test coverage
- Maintained or improved performance

## Future Considerations
1. Additional refactoring opportunities:
   - Input validation
   - Error handling
   - Accessibility improvements
   - Internationalization

2. Technical debt to address:
   - Constants organization
   - Configuration management
   - Documentation updates
