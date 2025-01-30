# Beyond The Horizon - Diagram Architecture

## Overview
This document describes the current architecture of the Beyond Horizon Calculator's diagram system, focusing on the key components and their relationships.

## Core Components

### 1. Configuration Layer
```json
Configuration/
├── diagram_spec.json     # Diagram specifications and measurements
├── field_info.json      # Input field configurations
├── presets.json         # Preset scenarios
└── menu_items.json      # Menu structure
```

#### Key Configuration Areas:
- Measurement group specifications
- Label positions and styles
- Dynamic element properties
- Input field validation rules

### 2. View Models

#### Base Classes
```dart
DiagramViewModel
├── HorizonDiagramViewModel
└── MountainDiagramViewModel
```

#### Group View Models
```dart
GroupViewModel
├── SkyGroupViewModel
├── ObserverGroupViewModel
└── MountainGroupViewModel
```

### 3. Services

#### Label Service
```dart
DiagramLabelService
├── Label configuration loading
├── Dynamic label updates
└── Label group management
```

#### SVG Management
```dart
SvgElementUpdater
├── Element positioning
├── Style management
└── Visibility control
```

### 4. SVG Assets

#### Template Structure
```
assets/
├── BTH_1.svg           # Simple diagram template
└── BTH_viewBox.svg     # Complex diagram with measurements
```

## Implementation Patterns

### 1. Measurement Groups
Each measurement (h1, h2, h3, XZ) follows a standard pattern:
```dart
MeasurementGroup
├── Configuration (diagram_spec.json)
├── Value Source (view model)
├── Position Calculation
└── Element Management
```

### 2. View Model Hierarchy
```
DiagramViewModel
├── Result management
├── Unit conversion
└── Label formatting
    
GroupViewModel
├── Element positioning
├── Visibility control
└── Group-specific calculations
```

### 3. Dynamic Updates
```dart
updateDynamicElements()
├── Calculate positions
├── Update labels
└── Manage visibility
```

## Key Files

### 1. View Models
- diagram_view_model.dart
- mountain_diagram_view_model.dart
- horizon_diagram_view_model.dart

### 2. Group Handlers
- mountain_group_view_model.dart
- observer_group_view_model.dart
- sky_group_view_model.dart

### 3. Services
- diagram_label_service.dart
- svg_element_updater.dart
- svg_text_style.dart

## Data Flow

```
User Input → CalculationResult
     ↓
DiagramViewModel
     ↓
Group View Models
     ↓
SVG Updates
```

## Configuration Example

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

## Related Documentation
- [Coordinate System Guide](coordinate_system.md)
- [Datum Lines Reference](datum_lines.md)
- [Geometric Model](geometric_model.md)
- [Implementation Guide](../implementation/measurement_group_guide.md)
