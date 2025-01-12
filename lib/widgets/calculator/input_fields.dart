import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class InputFields extends StatelessWidget {
  final TextEditingController observerHeightController;
  final TextEditingController distanceController;
  final TextEditingController refractionFactorController;
  final TextEditingController targetHeightController;
  final bool isMetric;
  final ValueChanged<bool> onMetricChanged;
  final VoidCallback onCalculate;

  const InputFields({
    super.key,
    required this.observerHeightController,
    required this.distanceController,
    required this.refractionFactorController,
    required this.targetHeightController,
    required this.isMetric,
    required this.onMetricChanged,
    required this.onCalculate,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              children: [
                Expanded(
                  child: TextFormField(
                    controller: observerHeightController,
                    decoration: InputDecoration(
                      labelText: 'Observer Height',
                      border: const OutlineInputBorder(),
                      suffixText: isMetric ? 'm' : 'ft',
                    ),
                    keyboardType: const TextInputType.numberWithOptions(decimal: true),
                    inputFormatters: [
                      FilteringTextInputFormatter.allow(RegExp(r'^\d*\.?\d*')),
                    ],
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: TextFormField(
                    controller: distanceController,
                    decoration: InputDecoration(
                      labelText: 'Distance',
                      border: const OutlineInputBorder(),
                      suffixText: isMetric ? 'km' : 'mi',
                    ),
                    keyboardType: const TextInputType.numberWithOptions(decimal: true),
                    inputFormatters: [
                      FilteringTextInputFormatter.allow(RegExp(r'^\d*\.?\d*')),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: DropdownButtonFormField<String>(
                    value: _getRefractionLabel(refractionFactorController.text),
                    decoration: const InputDecoration(
                      labelText: 'Atmospheric Refraction',
                      border: OutlineInputBorder(),
                    ),
                    items: const [
                      DropdownMenuItem(value: 'none', child: Text('No Refraction (1.00)')),
                      DropdownMenuItem(value: 'low', child: Text('Low Refraction (1.02)')),
                      DropdownMenuItem(value: 'below_average', child: Text('Below Average (1.04)')),
                      DropdownMenuItem(value: 'average', child: Text('Average Refraction (1.07)')),
                      DropdownMenuItem(value: 'above_average', child: Text('Above Average (1.10)')),
                      DropdownMenuItem(value: 'high', child: Text('High Refraction (1.15)')),
                    ],
                    onChanged: (value) {
                      if (value != null) {
                        refractionFactorController.text = _getRefractionValue(value);
                      }
                    },
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: TextFormField(
                    controller: targetHeightController,
                    decoration: InputDecoration(
                      labelText: 'Target Height (Optional)',
                      border: const OutlineInputBorder(),
                      suffixText: isMetric ? 'm' : 'ft',
                    ),
                    keyboardType: const TextInputType.numberWithOptions(decimal: true),
                    inputFormatters: [
                      FilteringTextInputFormatter.allow(RegExp(r'^\d*\.?\d*')),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    const Text('Units:'),
                    const SizedBox(width: 8),
                    ToggleButtons(
                      isSelected: [isMetric, !isMetric],
                      onPressed: (index) => onMetricChanged(index == 0),
                      children: const [
                        Padding(
                          padding: EdgeInsets.symmetric(horizontal: 12),
                          child: Text('Metric'),
                        ),
                        Padding(
                          padding: EdgeInsets.symmetric(horizontal: 12),
                          child: Text('Imperial'),
                        ),
                      ],
                    ),
                  ],
                ),
                ElevatedButton(
                  onPressed: onCalculate,
                  child: const Text('Calculate'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  String _getRefractionLabel(String value) {
    switch (value) {
      case '1.00':
        return 'none';
      case '1.02':
        return 'low';
      case '1.04':
        return 'below_average';
      case '1.07':
        return 'average';
      case '1.10':
        return 'above_average';
      case '1.15':
        return 'high';
      default:
        return 'average';
    }
  }

  String _getRefractionValue(String label) {
    switch (label) {
      case 'none':
        return '1.00';
      case 'low':
        return '1.02';
      case 'below_average':
        return '1.04';
      case 'average':
        return '1.07';
      case 'above_average':
        return '1.10';
      case 'high':
        return '1.15';
      default:
        return '1.07';
    }
  }
}
