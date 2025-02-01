import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'dart:convert';
import '../../services/models/calculation_result.dart';
import 'diagram/diagram_label_service.dart';
import 'diagram/horizon_diagram_view_model.dart';
import 'diagram/mountain_diagram_view_model.dart';
import 'diagram/test_diagram_view_model.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'dart:developer' as developer;

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
  MountainDiagramViewModel? _mountainViewModel;

  @override
  void didUpdateWidget(DiagramDisplay oldWidget) {
    super.didUpdateWidget(oldWidget);
    developer.log('DiagramDisplay - didUpdateWidget called', name: 'DiagramDisplay');
    developer.log('Old preset: ${oldWidget.presetName}, New preset: ${widget.presetName}', name: 'DiagramDisplay');
    developer.log('Old result: ${oldWidget.result}, New result: ${widget.result}', name: 'DiagramDisplay');
    developer.log('Old target height: ${oldWidget.targetHeight}, New target height: ${widget.targetHeight}', name: 'DiagramDisplay');
    developer.log('Old isMetric: ${oldWidget.isMetric}, New isMetric: ${widget.isMetric}', name: 'DiagramDisplay');

    if (oldWidget.result != widget.result ||
        oldWidget.targetHeight != widget.targetHeight ||
        oldWidget.isMetric != widget.isMetric ||
        oldWidget.presetName != widget.presetName) {
      developer.log('DiagramDisplay - Props changed, calling _loadAndUpdateSvg', name: 'DiagramDisplay');
      _loadAndUpdateSvg();
    } else {
      developer.log('DiagramDisplay - Widget updated, but no relevant changes detected', name: 'DiagramDisplay');
    }
  }

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
      developer.log('_loadAndUpdateSvg started', name: 'DiagramDisplay');
      developer.log('Current preset: ${widget.presetName}', name: 'DiagramDisplay');
      developer.log('Observer height: ${widget.result?.h1}', name: 'DiagramDisplay');
      developer.log('Target height: ${widget.targetHeight}', name: 'DiagramDisplay');
      developer.log('Is metric: ${widget.isMetric}', name: 'DiagramDisplay');

      Map<String, dynamic> diagramSpec;
      try {
        // Load diagram spec configuration
        final String specJson = await rootBundle.loadString('assets/info/diagram_spec.json');
        developer.log('Raw diagram spec JSON: $specJson', name: 'DiagramDisplay');
        diagramSpec = json.decode(specJson) as Map<String, dynamic>;
        developer.log('Parsed diagram spec: $diagramSpec', name: 'DiagramDisplay');
        developer.log('ViewBox height from spec: ${diagramSpec['metadata']?['svgSpec']?['viewBox']?['height']}', name: 'DiagramDisplay');
        if (diagramSpec.isEmpty) {
          developer.log('Warning: Diagram spec is empty', name: 'DiagramDisplay');
        }
      } catch (e, stackTrace) {
        developer.log('Error loading diagram spec: $e', name: 'DiagramDisplay', error: e);
        developer.log('Stack trace: $stackTrace', name: 'DiagramDisplay');
        // Provide empty config, view model will use defaults
        diagramSpec = {};
      }

      // Load SVG content for original diagram
      final String svgPath = _getDiagramAsset();
      developer.log('Loading SVG from path: $svgPath', name: 'DiagramDisplay');
      final String rawSvg = await rootBundle.loadString(svgPath);

      developer.log('Original SVG loaded', name: 'DiagramDisplay');

      // Extract defs section to preserve markers
      final defsMatch = RegExp(r'(<defs[^>]*>.*?</defs>)', dotAll: true).firstMatch(rawSvg);
      final defs = defsMatch?.group(1) ?? '';
      
      // Create view model and update labels for original diagram
      final viewModel = HorizonDiagramViewModel(
        result: widget.result,
        targetHeight: widget.targetHeight,
        isMetric: widget.isMetric,
        presetName: widget.presetName,
      );
      
      // Update SVG with new labels
      var updatedSvg = _labelService.updateLabels(rawSvg, viewModel);

      developer.log('Original SVG updated with labels', name: 'DiagramDisplay');

      // Ensure defs section is preserved
      if (!updatedSvg.contains('<defs') && defs.isNotEmpty) {
        updatedSvg = updatedSvg.replaceFirst('</svg>', '$defs</svg>');
      }

      // Load and update mountain diagram
      String mountainSvgPath;
      try {
        mountainSvgPath = 'assets/svg/${diagramSpec['metadata']?['svgSpec']?['files']?['mountainDiagram'] ?? 'BTH_viewBox_diagram2.svg'}';
        developer.log('Mountain diagram path from spec: $mountainSvgPath', name: 'DiagramDisplay');
      } catch (e) {
        developer.log('Error getting mountain diagram path: $e', name: 'DiagramDisplay');
        mountainSvgPath = 'assets/svg/BTH_viewBox_diagram2.svg';
      }
      
      final String rawMountainSvg = await rootBundle.loadString(mountainSvgPath);
      developer.log('Mountain SVG loaded', name: 'DiagramDisplay');

      // Extract defs section from mountain SVG
      final mountainDefsMatch = RegExp(r'(<defs[^>]*>.*?</defs>)', dotAll: true).firstMatch(rawMountainSvg);
      final mountainDefs = mountainDefsMatch?.group(1) ?? '';
      
      // Create mountain view model and update labels
      _mountainViewModel = MountainDiagramViewModel(
        result: widget.result,
        targetHeight: widget.targetHeight,
        isMetric: widget.isMetric,
        presetName: widget.presetName,
        diagramSpec: diagramSpec,
      );
      
      // Update mountain SVG with new labels and dynamic elements
      var updatedMountainSvg = _labelService.updateLabels(rawMountainSvg, _mountainViewModel!);
      updatedMountainSvg = _mountainViewModel!.updateDynamicElements(updatedMountainSvg);

      developer.log('Mountain SVG updated with labels and dynamic elements', name: 'DiagramDisplay');

      // Ensure defs section is preserved in mountain SVG
      if (!updatedMountainSvg.contains('<defs') && mountainDefs.isNotEmpty) {
        updatedMountainSvg = updatedMountainSvg.replaceFirst('</svg>', '$mountainDefs</svg>');
      }
      
      if (mounted) {
        setState(() {
          _svgContent = updatedSvg;
          _mountainSvgContent = updatedMountainSvg;
        });
        developer.log('State updated with new SVG content', name: 'DiagramDisplay');
      }
    } catch (e) {
      developer.log('Error updating SVG labels: $e', name: 'DiagramDisplay', error: e);
    }
  }

  @override
  void initState() {
    super.initState();
    _testViewModel = TestDiagramViewModel(isMetric: widget.isMetric);
    _loadAndUpdateSvg();
  }

  @override
  void dispose() {
    super.dispose();
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
                      key: ValueKey(_svgContent.hashCode),
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
          child: Card(
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: LayoutBuilder(
                builder: (context, constraints) {
                  final spec = _mountainViewModel?.diagramSpec['metadata']?['svgSpec'];
                  final workingArea = spec?['viewBox']?['scaling']?['workingArea'];
                  final workingWidth = workingArea?['width'] ?? 400;
                  final workingHeight = workingArea?['height'] ?? 1000;
                  final displayScale = spec?['viewBox']?['scaling']?['displayScale'] ?? 0.6;
                  
                  final scaledWidth = constraints.maxWidth * displayScale;
                  final height = (scaledWidth * workingHeight) / workingWidth;
                  
                  print('Diagram scaling: width=$scaledWidth, height=$height');
                  print('Working area: width=$workingWidth, height=$workingHeight');
                  print('Constraints: ${constraints.toString()}');
                  
                  return SizedBox(
                    width: scaledWidth,
                    height: height,
                    child: SvgPicture.string(
                      _mountainSvgContent!,
                      key: ValueKey(_mountainSvgContent.hashCode),
                      fit: BoxFit.fill,
                      alignment: Alignment.topCenter,
                    ),
                  );
                }
              ),
            ),
          ),
        ),
      ],
    );
  }
}
