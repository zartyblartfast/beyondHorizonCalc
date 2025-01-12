import 'package:flutter/material.dart';
import '../../services/models/calculation_result.dart';

class ResultsDisplay extends StatelessWidget {
  final CalculationResult? result;
  final bool isMetric;

  const ResultsDisplay({
    super.key,
    required this.result,
    required this.isMetric,
  });

  String _formatDistance(double? value) {
    if (value == null) return 'N/A';
    final double displayValue = isMetric ? value : value * 0.621371; // km to mi
    return '${displayValue.toStringAsFixed(2)} ${isMetric ? 'km' : 'mi'}';
  }

  String _formatHeight(double? value) {
    if (value == null) return 'N/A';
    final double displayValue = isMetric ? value : value * 0.621371; // km to mi
    return '${displayValue.toStringAsFixed(2)} ${isMetric ? 'km' : 'mi'}';
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
