import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'dart:convert';
import '../../services/models/calculation_result.dart';
import 'diagram/diagram_label_service.dart';
import 'diagram/horizon_diagram_view_model.dart';
import 'diagram/mountain_diagram_view_model.dart';
import 'diagram/test_diagram_view_model.dart';
import 'package:flutter/services.dart' show rootBundle;

class DiagramDisplay extends StatefulWidget {
  final CalculationResult? result;
  final double? targetHeight;
  final bool isMetric;
  final String? presetName;

  const DiagramDisplay({
    super.key,
    required this.result,
    this.targetHeight,
    required this.isMetric,
    this.presetName,
  });

  @override
  State<DiagramDisplay> createState() => _DiagramDisplayState();
}

class _DiagramDisplayState extends State<DiagramDisplay> {
  final DiagramLabelService _labelService = DiagramLabelService();
  String? _svgContent;
  String? _mountainSvgContent;
  TestDiagramViewModel? _testViewModel;
  
  String _getDiagramAsset() {
    if (widget.result == null) return 'assets/svg/BTH_1.svg';
    
    // If target height is null or 0, show BTH_1
    if (widget.targetHeight == null || widget.targetHeight == 0) {
      return 'assets/svg/BTH_1.svg';
    }
    
    // Get h2 (XC) from the hiddenHeight (convert from km to m or ft)
    final double? h2 = widget.result!.hiddenHeight;
    if (h2 == null) return 'assets/svg/BTH_1.svg';

    // Convert h2 from km to m or ft
    final double h2InUnits = widget.isMetric ? h2 * 1000 : h2 * 3280.84;
    
    // Compare target height with h2
    if (widget.targetHeight! < h2InUnits) {
      return 'assets/svg/BTH_2.svg';
    } else if ((widget.targetHeight! - h2InUnits).abs() < 0.1) { // Use slightly larger epsilon for m/ft comparison
      return 'assets/svg/BTH_3.svg';
    } else {
      return 'assets/svg/BTH_4.svg';
    }
  }

  Future<void> _loadAndUpdateSvg() async {
    try {
      Map<String, dynamic> diagramSpec;
      try {
        // Load diagram spec configuration
        final String specJson = await rootBundle.loadString('assets/info/diagram_spec.json');
        diagramSpec = json.decode(specJson) as Map<String, dynamic>;
      } catch (e) {
        debugPrint('Error loading diagram spec: $e');
        // Provide empty config, view model will use defaults
        diagramSpec = {};
      }

      // Load SVG content for original diagram
      final String svgPath = _getDiagramAsset();
      final String rawSvg = await rootBundle.loadString(svgPath);
      
      // Create view model and update labels for original diagram
      final viewModel = HorizonDiagramViewModel(
        result: widget.result,
        targetHeight: widget.targetHeight,
        isMetric: widget.isMetric,
        presetName: widget.presetName,
      );
      
      // Update SVG with new labels
      final updatedSvg = _labelService.updateLabels(rawSvg, viewModel);

      // Load and update mountain diagram
      final String mountainSvgPath = 'assets/svg/BTH_viewBox_diagram1.svg';
      final String rawMountainSvg = await rootBundle.loadString(mountainSvgPath);
      debugPrint('Loaded mountain SVG length: ${rawMountainSvg.length}');
      debugPrint('Mountain SVG contains Observer_SL_Line: ${rawMountainSvg.contains('Observer_SL_Line')}');
      
      // Create mountain view model and update labels
      final mountainViewModel = MountainDiagramViewModel(
        result: widget.result,
        targetHeight: widget.targetHeight,
        isMetric: widget.isMetric,
        presetName: widget.presetName,
        diagramSpec: diagramSpec,
      );
      
      // Update mountain SVG with new labels and dynamic elements
      var updatedMountainSvg = _labelService.updateLabels(rawMountainSvg, mountainViewModel);
      updatedMountainSvg = mountainViewModel.updateDynamicElements(updatedMountainSvg);
      
      if (mounted) {
        setState(() {
          _svgContent = updatedSvg;
          _mountainSvgContent = updatedMountainSvg;
        });
      }
    } catch (e) {
      debugPrint('Error updating SVG labels: $e');
    }
  }

  @override
  void didUpdateWidget(DiagramDisplay oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.result != widget.result ||
        oldWidget.targetHeight != widget.targetHeight ||
        oldWidget.isMetric != widget.isMetric ||
        oldWidget.presetName != widget.presetName) {
      _loadAndUpdateSvg();
    }
  }

  @override
  void initState() {
    super.initState();
    _testViewModel = TestDiagramViewModel(isMetric: widget.isMetric);
    _loadAndUpdateSvg();
  }

  @override
  Widget build(BuildContext context) {
    final titleStyle = Theme.of(context).textTheme.titleMedium?.copyWith(
      fontWeight: FontWeight.bold,
    );

    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.only(bottom: 8.0),
          child: Text(
            'Not to Scale, Cross-Section: Distant Object Visibility Over Earth\'s Curvature',
            textAlign: TextAlign.center,
            style: titleStyle,
          ),
        ),
        Card(
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: AspectRatio(
              aspectRatio: 1.75,
              child: _svgContent == null
                  ? const Center(child: CircularProgressIndicator())
                  : SvgPicture.string(
                      _svgContent!,
                      fit: BoxFit.contain,
                    ),
            ),
          ),
        ),
        const SizedBox(height: 16.0),
        Padding(
          padding: const EdgeInsets.only(bottom: 8.0),
          child: Text(
            'To Scale, Vertical Perspective: Distant Object Visibility Over Earth\'s Curvature',
            textAlign: TextAlign.center,
            style: titleStyle,
          ),
        ),
        Align(
          alignment: Alignment.center,
          child: FractionallySizedBox(
            widthFactor: 0.5,
            child: Card(
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: LayoutBuilder(
                  builder: (context, constraints) {
                    // Calculate height based on width to maintain 400:1000 ratio of the main diagram area
                    // The total width is 500 (400 + 100 extra), so we adjust the ratio accordingly
                    final height = (constraints.maxWidth * 1000) / 400;
                    return SizedBox(
                      height: height,
                      child: _mountainSvgContent == null
                          ? const Center(child: CircularProgressIndicator())
                          : SvgPicture.string(
                              _mountainSvgContent!,
                              fit: BoxFit.fill,
                            ),
                    );
                  }
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}
