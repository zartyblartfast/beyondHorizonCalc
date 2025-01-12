import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../core/constants/range_limits.dart';

class InputFields extends StatelessWidget {
  final TextEditingController observerHeightController;
  final TextEditingController distanceController;
  final TextEditingController refractionFactorController;
  final TextEditingController targetHeightController;
  final bool isMetric;
  final ValueChanged<bool> onMetricChanged;
  final VoidCallback onCalculate;
  final bool showCalculateButton;

  const InputFields({
    super.key,
    required this.observerHeightController,
    required this.distanceController,
    required this.refractionFactorController,
    required this.targetHeightController,
    required this.isMetric,
    required this.onMetricChanged,
    required this.onCalculate,
    this.showCalculateButton = false,
  });

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final isNarrow = constraints.maxWidth < 600;

        return SingleChildScrollView(
          child: Card(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  if (isNarrow) ...[
                    // Vertical layout for narrow screens
                    _buildInputField(
                      controller: observerHeightController,
                      label: 'Observer Height',
                      suffix: isMetric ? 'm' : 'ft',
                      validator: _validateObserverHeight,
                    ),
                    const SizedBox(height: 16),
                    _buildInputField(
                      controller: distanceController,
                      label: 'Distance',
                      suffix: isMetric ? 'km' : 'mi',
                      validator: _validateDistance,
                    ),
                    const SizedBox(height: 16),
                    _buildRefractionDropdown(),
                    const SizedBox(height: 16),
                    _buildInputField(
                      controller: targetHeightController,
                      label: 'Target Height (Optional)',
                      suffix: isMetric ? 'm' : 'ft',
                      validator: _validateTargetHeight,
                    ),
                  ] else ...[
                    // Horizontal layout for wider screens
                    Row(
                      children: [
                        Expanded(
                          child: _buildInputField(
                            controller: observerHeightController,
                            label: 'Observer Height',
                            suffix: isMetric ? 'm' : 'ft',
                            validator: _validateObserverHeight,
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: _buildInputField(
                            controller: distanceController,
                            label: 'Distance',
                            suffix: isMetric ? 'km' : 'mi',
                            validator: _validateDistance,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    Row(
                      children: [
                        Expanded(child: _buildRefractionDropdown()),
                        const SizedBox(width: 16),
                        Expanded(
                          child: _buildInputField(
                            controller: targetHeightController,
                            label: 'Target Height (Optional)',
                            suffix: isMetric ? 'm' : 'ft',
                            validator: _validateTargetHeight,
                          ),
                        ),
                      ],
                    ),
                  ],
                  const SizedBox(height: 16),
                  Wrap(
                    spacing: 16,
                    runSpacing: 16,
                    alignment: WrapAlignment.spaceBetween,
                    crossAxisAlignment: WrapCrossAlignment.center,
                    children: [
                      Wrap(
                        spacing: 8,
                        children: [
                          const Text('Units:'),
                          ConstrainedBox(
                            constraints: const BoxConstraints(maxWidth: 200),
                            child: IntrinsicWidth(
                              child: ToggleButtons(
                                isSelected: [isMetric, !isMetric],
                                onPressed: (index) => onMetricChanged(index == 0),
                                constraints: const BoxConstraints(
                                  minWidth: 60,
                                  minHeight: 36,
                                ),
                                children: const [
                                  Padding(
                                    padding: EdgeInsets.symmetric(horizontal: 8),
                                    child: Text('Metric'),
                                  ),
                                  Padding(
                                    padding: EdgeInsets.symmetric(horizontal: 8),
                                    child: Text('Imperial'),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                      if (showCalculateButton)
                        ElevatedButton(
                          onPressed: onCalculate,
                          child: const Text('Calculate'),
                        ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildInputField({
    required TextEditingController controller,
    required String label,
    required String suffix,
    required String? Function(String?) validator,
  }) {
    return TextFormField(
      controller: controller,
      decoration: InputDecoration(
        labelText: label,
        border: const OutlineInputBorder(),
        suffixText: suffix,
      ),
      keyboardType: const TextInputType.numberWithOptions(decimal: true),
      inputFormatters: [
        FilteringTextInputFormatter.allow(RegExp(r'^\d*\.?\d*')),
      ],
      validator: validator,
    );
  }

  Widget _buildRefractionDropdown() {
    return DropdownButtonFormField<String>(
      value: _getRefractionLabel(refractionFactorController.text),
      decoration: const InputDecoration(
        labelText: 'Refraction',
        border: OutlineInputBorder(),
        isCollapsed: true,
        contentPadding: EdgeInsets.symmetric(horizontal: 10, vertical: 12),
      ),
      isDense: true,
      items: const [
        DropdownMenuItem(value: 'none', child: Text('None (1.00)')),
        DropdownMenuItem(value: 'low', child: Text('Low (1.02)')),
        DropdownMenuItem(value: 'below_average', child: Text('Below Avg (1.04)')),
        DropdownMenuItem(value: 'average', child: Text('Avg (1.07)')),
        DropdownMenuItem(value: 'above_average', child: Text('Above Avg (1.10)')),
        DropdownMenuItem(value: 'high', child: Text('High (1.15)')),
      ],
      onChanged: (value) {
        if (value != null) {
          refractionFactorController.text = _getRefractionValue(value);
        }
      },
    );
  }

  String? _validateObserverHeight(String? value) {
    if (value == null || value.isEmpty) {
      return 'Please enter observer height';
    }
    final height = double.tryParse(value);
    if (height == null) {
      return 'Please enter a valid number';
    }
    if (height < RangeLimits.minObserverHeight) {
      return 'Height must be at least ${RangeLimits.minObserverHeight} ${isMetric ? 'm' : 'ft'}';
    }
    if (height > RangeLimits.maxObserverHeight) {
      return 'Height cannot exceed ${RangeLimits.maxObserverHeight} ${isMetric ? 'm' : 'ft'}';
    }
    return null;
  }

  String? _validateDistance(String? value) {
    if (value == null || value.isEmpty) {
      return 'Please enter distance';
    }
    final distance = double.tryParse(value);
    if (distance == null) {
      return 'Please enter a valid number';
    }
    if (distance < RangeLimits.minDistance) {
      return 'Distance must be at least ${RangeLimits.minDistance} ${isMetric ? 'km' : 'mi'}';
    }
    if (distance > RangeLimits.maxDistance) {
      return 'Distance cannot exceed ${RangeLimits.maxDistance} ${isMetric ? 'km' : 'mi'}';
    }
    return null;
  }

  String? _validateTargetHeight(String? value) {
    if (value == null || value.isEmpty) {
      return null; // Optional field
    }
    final height = double.tryParse(value);
    if (height == null) {
      return 'Please enter a valid number';
    }
    if (height > RangeLimits.maxTargetHeight) {
      return 'Height cannot exceed ${RangeLimits.maxTargetHeight} ${isMetric ? 'm' : 'ft'}';
    }
    return null;
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
