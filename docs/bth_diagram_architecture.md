# Beyond The Horizon - Diagram Architecture

> For detailed implementation patterns and code examples for modifying the diagram, see [diagram_modification_guide.md](./diagram_modification_guide.md).

graph TB
    %% Title
    title[Beyond The Horizon - Diagram Architecture]
    style title fill:none,stroke:none

    %% Configuration Package
    subgraph Configuration
        diagram_spec[diagram_spec.json]
        field_info[field_info.json]
        presets[presets.json]
        menu_items[menu_items.json]
        
        configNote["Configuration split across multiple files:
        - Diagram specifications
        - Field configurations
        - Preset values
        - Menu structure"]
    end
    style diagram_spec fill:#90EE90
    style field_info fill:#90EE90
    style presets fill:#90EE90
    style menu_items fill:#90EE90

    %% Models Package
    subgraph Models
        CalcResult["CalculationResult
        --
        +horizonDistance
        +hiddenHeight
        +totalDistance
        +visibleDistance
        +visibleTargetHeight
        +apparentVisibleHeight
        +perspectiveScaledHeight
        +inputDistance
        +h1
        +toMap()"]

        InfoContent["InfoContent
        --
        +title
        +content"]

        LineOfSightPreset["LineOfSightPreset
        --
        +name
        +description
        +parameters"]

        MenuItem["MenuItem
        --
        +title
        +route"]
    end

    %% SVG Assets Package
    subgraph SVGAssets["SVG Assets"]
        SimpleSVG["Simple SVG Templates
        --
        BTH_1.svg to BTH_4.svg
        - Basic structure
        - Static elements"]
        
        ComplexSVG["Complex SVG Template
        --
        BTH_viewBox_diagram1.svg
        - ViewBox coordinates
        - Complex paths
        - Label positions"]
    end
    style SimpleSVG fill:#ADD8E6
    style ComplexSVG fill:#ADD8E6

    %% View Package - Simple Diagram
    subgraph SimpleDiagramView["Simple Diagram Implementation"]
        EarthCurve["EarthCurveDiagram
        --
        +observerHeight
        +distanceToHorizon
        +totalDistance
        +hiddenHeight
        +visibleDistance
        --
        +build()"]

        SvgHelper["SvgHelper
        --
        +loadSvgAsset()
        +loadSvg()"]

        simpleNote["Uses Flutter SVG package
        for direct SVG rendering"]
    end

    %% View Package - Complex Diagram
    subgraph ComplexDiagramView["Complex Diagram Implementation"]
        OverHorizon["OverHorizon
        --
        -size
        -earthColor
        -lineColor
        -groundColor
        --
        +build()"]

        OverHorizonPainter["OverHorizonPainter
        --
        -earthColor
        -lineColor
        -groundColor
        --
        +paint()
        +shouldRepaint()
        -drawPaths()
        -drawLabels()"]

        complexNote["Custom painting with:
        - Path drawing
        - ViewBox transforms
        - Dynamic labels"]
    end

    %% Design Rules Note
    designRules["Design Rules:
    1. Two-Tier Diagram Approach
        - Simple: Direct SVG rendering for basic diagrams
        - Complex: Custom painting for advanced visualizations

    2. SVG Integration
        - Simple diagrams use Flutter SVG package
        - Complex diagrams use custom painting
        - SVG files serve as templates/coordinates

    3. Configuration
        - All configurable values in JSON
        - Separate configs for different aspects

    4. Implementation Patterns
        - Simple: SvgHelper → EarthCurveDiagram
        - Complex: OverHorizon → OverHorizonPainter
        - Both consume calculation results"]

    %% Relationships
    SimpleSVG --> SvgHelper
    SvgHelper --> EarthCurve
    ComplexSVG --> OverHorizonPainter
    OverHorizon --> OverHorizonPainter
    
    diagram_spec -.-> EarthCurve
    diagram_spec -.-> OverHorizon
    
    CalcResult -.-> EarthCurve
    CalcResult -.-> OverHorizon
    
    EarthCurve -.-> simpleNote
    OverHorizonPainter -.-> complexNote
