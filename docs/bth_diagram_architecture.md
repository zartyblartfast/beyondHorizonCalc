# Beyond The Horizon - Diagram Architecture

## Overview
This document describes the architecture of the Beyond Horizon Calculator's diagram system, covering all components from configuration to rendering.

## System Components

### 1. Configuration Layer
```json
Configuration/
├── diagram_spec.json     # Core diagram specifications
│   ├── measurements/     # Measurement group configs
│   ├── labels/          # Label positions and styles
│   └── elements/        # SVG element properties
├── field_info.json      # Input field configurations
├── presets.json         # Preset scenarios
└── menu_items.json      # Menu structure
```

### 2. Core View Models

#### Diagram View Models
```dart
DiagramViewModel
├── HorizonDiagramViewModel     # Simple horizon view
└── MountainDiagramViewModel    # Complex mountain view
    ├── Result management
    ├── Unit conversion
    └── Label formatting
```

#### Group View Models
```dart
GroupViewModel
├── SkyGroupViewModel          # Sky and background
├── ObserverGroupViewModel     # Observer position
└── MountainGroupViewModel     # Mountain and measurements
```

### 3. Services

#### Diagram Services
```dart
DiagramLabelService            # Label management
├── Configuration loading
├── Dynamic updates
└── Group management

SvgElementUpdater             # SVG manipulation
├── Element positioning
├── Style management
└── Visibility control

CurvatureCalculator          # Core calculations
├── Earth curvature effects
├── Refraction adjustments
└── Height calculations
```

### 4. Asset Management

#### SVG Templates
```
assets/
├── BTH_1.svg                # Simple diagram
│   ├── Basic structure
│   └── Static elements
└── BTH_viewBox.svg         # Complex diagram
    ├── ViewBox coordinates
    ├── Complex paths
    └── Measurement points
```

## Implementation Patterns

### 1. Diagram Organization
```
Three-Layer Structure
├── Sky Layer       # Background and atmosphere
├── Observer Layer  # Observer position and horizon
└── Ground Layer    # Earth surface and target
```

### 2. Measurement System
```dart
MeasurementGroups
├── C-Height (h₁)   # Observer height
├── H-Height (h₂)   # Hidden portion
├── V-Height (h₃)   # Visible portion
└── Z-Height (XZ)   # Total height
```

### 3. Dynamic Updates
```dart
Update Flow
├── Input changes
├── Recalculate positions
├── Update measurements
└── Refresh display
```

## Key Files

### 1. Core Components
```
lib/widgets/calculator/diagram/
├── diagram_view_model.dart         # Base view model
├── mountain_diagram_view_model.dart # Complex diagram
└── horizon_diagram_view_model.dart  # Simple diagram
```

### 2. Group Components
```
lib/widgets/calculator/diagram/
├── mountain_group_view_model.dart   # Mountain features
├── observer_group_view_model.dart   # Observer elements
└── sky_group_view_model.dart        # Background elements
```

### 3. Services
```
lib/services/
├── diagram_label_service.dart       # Label management
├── svg_element_updater.dart         # SVG updates
└── curvature_calculator.dart        # Core math
```

## Data Flow

```
User Input → Calculator
     ↓
CalculationResult
     ↓
DiagramViewModel
     ↓
Group View Models
     ↓
SVG Updates
```

## Configuration Examples

### 1. Measurement Group
```json
{
  "measurements": {
    "h1": {
      "x": -250,
      "style": "bold",
      "elements": [
        "2_1_C_Height_Top_arrow",
        "2_2_C_Height",
        "2_3_C_Height_Bottom_arrow"
      ]
    }
  }
}
```

### 2. Label Configuration
```json
{
  "labels": {
    "points": [
      {
        "id": "2_2_C_Height",
        "type": "text",
        "prefix": "h1: ",
        "suffix": "m"
      }
    ]
  }
}
```

## Related Documentation
- [Geometric Model](diagram_explanation.md)
- [Measurement Groups](measurement_groups/technical/measurement_types.md)
- [SVG Requirements](svg_requirements.md)
- [Earth Curvature Calculations](earth_curvature_calculations.md)
