import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import '../../services/models/calculation_result.dart';

class DiagramDisplay extends StatelessWidget {
  final CalculationResult? result;
  final double? targetHeight;
  final bool isMetric;

  const DiagramDisplay({
    super.key,
    required this.result,
    this.targetHeight,
    required this.isMetric,
  });

  String _getDiagramAsset() {
    if (result == null) return 'assets/svg/BTH_1.svg';
    
    // If target height is null or 0, show BTH_1
    if (targetHeight == null || targetHeight == 0) {
      return 'assets/svg/BTH_1.svg';
    }
    
    // Get h2 (XC) from the hiddenHeight (convert from km to m or ft)
    final double? h2 = result!.hiddenHeight;
    if (h2 == null) return 'assets/svg/BTH_1.svg';

    // Convert h2 from km to m or ft
    final double h2InUnits = isMetric ? h2 * 1000 : h2 * 3280.84;
    
    // Compare target height with h2
    if (targetHeight! < h2InUnits) {
      return 'assets/svg/BTH_2.svg';
    } else if ((targetHeight! - h2InUnits).abs() < 0.1) { // Use slightly larger epsilon for m/ft comparison
      return 'assets/svg/BTH_3.svg';
    } else {
      return 'assets/svg/BTH_4.svg';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: AspectRatio(
          aspectRatio: 2.0,  // Width is twice the height
          child: SvgPicture.asset(
            _getDiagramAsset(),
            fit: BoxFit.contain,
          ),
        ),
      ),
    );
  }
}
