# Beyond Horizon Calculator

An interactive calculator for visualizing and computing Earth curvature effects on visibility and measurements.

## Features

- **Interactive Diagrams**: Dynamic SVG-based visualizations of Earth curvature effects
- **Height Measurements**: Calculate observer height, hidden portions, and visible target heights
- **Distance Calculations**: Compute horizon distance and total arc distance
- **Presets**: Common scenarios ready to use with one click
- **Refraction**: Account for atmospheric refraction in calculations

## Quick Start

1. Install Flutter SDK (latest stable version)
2. Clone and run:
   ```bash
   git clone https://github.com/your-username/BeyondHorizonCalc.git
   cd BeyondHorizonCalc
   flutter pub get
   flutter run
   ```
3. Select a preset scenario to get started immediately

## Project Structure

```
BeyondHorizonCalc/
├── lib/                    # Source code
│   ├── widgets/           # UI components
│   ├── models/           # Data models
│   └── services/         # Business logic
├── assets/               # SVG diagrams
└── docs/                # Documentation
```

## Technical Documentation

- [Diagram Architecture](docs/bth_diagram_architecture.md)
- [Geometric Model](docs/measurement_groups/technical/geometric_model.md)
- [SVG Requirements](docs/svg_requirements.md)
- [Terminology Reference](docs/terminology_alignment.md)

## Future Development

- Enhanced UI help with 'i' icons for each diagram component
- Interactive tooltips explaining measurements and calculations
- More preset scenarios for common use cases

## Dependencies

- flutter_svg: ^latest_version
- provider: ^latest_version

## License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.
