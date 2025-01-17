import 'package:flutter/material.dart';
import '../../services/models/calculation_result.dart';

class DiagramDisplay extends StatelessWidget {
  final CalculationResult? result;
  final double? targetHeight;

  const DiagramDisplay({
    super.key,
    required this.result,
    this.targetHeight,
  });

  String _getDiagramAsset() {
    if (result == null) return 'assets/images/BTH_1.png';

    // If target height is null or 0, show BTH_1
    if (targetHeight == null || targetHeight == 0) {
      return 'assets/images/BTH_1.png';
    }

    // Get h2 (XC) from the hiddenHeight (convert from km to m)
    final double? h2 = result!.hiddenHeight;
    if (h2 == null) return 'assets/images/BTH_1.png';

    final h2InMeters = h2 * 1000; // Convert km to m

    // Compare target height with h2
    if (targetHeight! < h2InMeters) {
      return 'assets/images/BTH_2.png';
    } else if ((targetHeight! - h2InMeters).abs() < 0.000001) {
      // Use small epsilon for floating point comparison
      return 'assets/images/BTH_3.png';
    } else {
      return 'assets/images/BTH_4.png';
    }
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedSwitcher(
      duration: const Duration(milliseconds: 500),
      layoutBuilder: (Widget? currentChild, List<Widget> previousChildren) {
        return Stack(
          alignment: Alignment.center,
          children: <Widget>[
            ...previousChildren,
            if (currentChild != null) currentChild,
          ],
        );
      },
      transitionBuilder: (Widget child, Animation<double> animation) {
        return FadeTransition(
          opacity: CurvedAnimation(
            parent: animation,
            curve: const Interval(0.0, 0.6, curve: Curves.easeOut),
            reverseCurve: const Interval(0.4, 1.0, curve: Curves.easeOut),
          ),
          child: child,
        );
      },
      child: Image.asset(
        _getDiagramAsset(),
        key: ValueKey<String>(_getDiagramAsset()),
        fit: BoxFit.contain,
      ),
    );
  }
}
