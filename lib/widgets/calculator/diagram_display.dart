import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import '../../services/models/calculation_result.dart';
import 'diagram/diagram_label_service.dart';
import 'diagram/horizon_diagram_view_model.dart';
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
      // Load SVG content
      final String svgPath = _getDiagramAsset();
      final String rawSvg = await rootBundle.loadString(svgPath);
      
      // Create view model and update labels
      final viewModel = HorizonDiagramViewModel(
        result: widget.result,
        targetHeight: widget.targetHeight,
        isMetric: widget.isMetric,
        presetName: widget.presetName,
      );
      
      // Update SVG with new labels
      final updatedSvg = _labelService.updateLabels(rawSvg, viewModel);
      
      if (mounted) {
        setState(() {
          _svgContent = updatedSvg;
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
    _loadAndUpdateSvg();
  }

  @override
  Widget build(BuildContext context) {
    return Card(
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
    );
  }
}
