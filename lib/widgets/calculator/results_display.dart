import 'package:flutter/material.dart';
import '../../services/models/calculation_result.dart';

class ResultsDisplay extends StatelessWidget {
  final CalculationResult? result;
  final bool isMetric;
  final double? targetHeight;

  const ResultsDisplay({
    super.key,
    required this.result,
    required this.isMetric,
    this.targetHeight,
  });

  String _formatDistance(double? value) {
    if (value == null) return 'N/A';
    final double displayValue = isMetric ? value : value * 0.621371; // km to mi
    return '${displayValue.toStringAsFixed(2)} ${isMetric ? 'km' : 'mi'}';
  }

  String _formatHeight(double? value) {
    if (value == null) return 'N/A';
    final double displayValue = isMetric ? value : value * 3.28084; // m to ft
    return '${displayValue.toStringAsFixed(2)} ${isMetric ? 'm' : 'ft'}';
  }

  String _getDiagramAsset() {
    if (result == null) return 'assets/images/BTH_1.png';
    
    // If target height is null or 0, show BTH_1
    if (targetHeight == null || targetHeight == 0) {
      return 'assets/images/BTH_1.png';
    }
    
    // Get h2 (XC) from the hiddenHeight
    final double? h2 = result!.hiddenHeight;
    if (h2 == null) return 'assets/images/BTH_1.png';
    
    // Compare target height with h2
    if (targetHeight! < h2) {
      return 'assets/images/BTH_2.png';
    } else if ((targetHeight! - h2).abs() < 0.000001) { // Use small epsilon for floating point comparison
      return 'assets/images/BTH_3.png';
    } else {
      return 'assets/images/BTH_4.png';
    }
  }

  Widget _buildResultRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: const TextStyle(fontWeight: FontWeight.bold),
          ),
          Text(value),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (result == null) return const SizedBox.shrink();

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _buildResultRow(
              'Distance to Horizon:',
              _formatDistance(result!.horizonDistance),
            ),
            _buildResultRow(
              'Hidden Height:',
              _formatHeight(result!.hiddenHeight),
            ),
            _buildResultRow(
              'Total Distance:',
              _formatDistance(result!.totalDistance),
            ),
            _buildResultRow(
              'Visible Distance:',
              _formatDistance(result!.visibleDistance),
            ),
            if (result!.visibleTargetHeight != null) ...[
              _buildResultRow(
                'Visible Target Height:',
                _formatHeight(result!.visibleTargetHeight),
              ),
              _buildResultRow(
                'Apparent Visible Height:',
                _formatHeight(result!.apparentVisibleHeight),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
