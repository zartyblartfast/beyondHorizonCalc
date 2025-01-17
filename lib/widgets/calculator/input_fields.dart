import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../core/constants/range_limits.dart';
import '../common/info_icon.dart';

class InputFields extends StatelessWidget {
  final TextEditingController observerHeightController;
  final TextEditingController distanceController;
  final TextEditingController refractionFactorController;
  final TextEditingController targetHeightController;
  final bool isMetric;
  final ValueChanged<bool> onMetricChanged;
  final VoidCallback onCalculate;
  final bool showCalculateButton;
  final bool isCustomPreset;

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
    this.isCustomPreset = true,
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
                      label: 'Observer Height (h1)',
                      suffix: isMetric ? 'm' : 'ft',
                      validator: _validateObserverHeight,
                      enabled: isCustomPreset,
                      infoKey: 'observer_height',
                    ),
                    const SizedBox(height: 16),
                    _buildInputField(
                      controller: distanceController,
                      label: 'Distance (L0)',
                      suffix: isMetric ? 'km' : 'mi',
                      validator: _validateDistance,
                      enabled: isCustomPreset,
                      infoKey: 'distance',
                    ),
                    const SizedBox(height: 16),
                    _buildRefractionDropdown(),
                    const SizedBox(height: 16),
                    _buildInputField(
                      controller: targetHeightController,
                      label: 'Target height - optional (XZ)',
                      suffix: isMetric ? 'm' : 'ft',
                      validator: _validateTargetHeight,
                      enabled: isCustomPreset,
                      infoKey: 'target_height',
                    ),
                  ] else ...[
                    // Horizontal layout for wider screens
                    Row(
                      children: [
                        Expanded(
                          child: _buildInputField(
                            controller: observerHeightController,
                            label: 'Observer Height (h1)',
                            suffix: isMetric ? 'm' : 'ft',
                            validator: _validateObserverHeight,
                            enabled: isCustomPreset,
                            infoKey: 'observer_height',
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: _buildInputField(
                            controller: distanceController,
                            label: 'Distance (L0)',
                            suffix: isMetric ? 'km' : 'mi',
                            validator: _validateDistance,
                            enabled: isCustomPreset,
                            infoKey: 'distance',
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
                            label: 'Target height - optional (XZ)',
                            suffix: isMetric ? 'm' : 'ft',
                            validator: _validateTargetHeight,
                            enabled: isCustomPreset,
                            infoKey: 'target_height',
                          ),
                        ),
                      ],
                    ),
                  ],
                  const SizedBox(height: 16),
                  // Units toggle and Calculate buttons
                  Wrap(
                    spacing: 16,
                    runSpacing: 16,
                    alignment: WrapAlignment.spaceBetween,
                    crossAxisAlignment: WrapCrossAlignment.center,
                    children: [
                      Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Text('Imperial'),
                          Switch(
                            value: isMetric,
                            onChanged: onMetricChanged,
                          ),
                          const Text('Metric'),
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
    required String infoKey,
    bool enabled = true,
  }) {
    return Row(
      children: [
        Expanded(
          child: TextFormField(
            controller: controller,
            decoration: InputDecoration(
              labelText: label,
              border: const OutlineInputBorder(),
              enabled: enabled,
              labelStyle: TextStyle(color: enabled ? null : Colors.black87),
              suffixText: suffix,
              suffixStyle: TextStyle(color: enabled ? null : Colors.black87),
            ),
            style: TextStyle(color: enabled ? null : Colors.black87),
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
            inputFormatters: [
              FilteringTextInputFormatter.allow(RegExp(r'[0-9.]')),
            ],
            validator: validator,
            enabled: enabled,
          ),
        ),
        Padding(
          padding: const EdgeInsets.only(left: 8.0),
          child: InfoIcon(
            infoKey: infoKey,
            size: 20,
          ),
        ),
      ],
    );
  }

  Widget _buildRefractionDropdown() {
    return Row(
      children: [
        Expanded(
          child: DropdownButtonFormField<String>(
            value: _getRefractionKey(refractionFactorController.text),
            decoration: const InputDecoration(
              labelText: 'Refraction Factor',
              border: OutlineInputBorder(),
            ),
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
          ),
        ),
        Padding(
          padding: const EdgeInsets.only(left: 8.0),
          child: InfoIcon(
            infoKey: 'refraction',
            size: 20,
          ),
        ),
      ],
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

  String _getRefractionKey(String value) {
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

  String? _validateObserverHeight(String? value) {
    if (value == null || value.isEmpty) {
      return 'Please enter observer height';
    }
    final height = double.tryParse(value);
    if (height == null) {
      return 'Please enter a valid number';
    }
    if (height <= 0) {
      return 'Height must be greater than 0';
    }
    final maxHeight = isMetric
        ? RangeLimits.maxObserverHeight
        : RangeLimits.maxObserverHeight * 3.28084;
    if (height > maxHeight) {
      return 'Height must be less than ${maxHeight.toStringAsFixed(0)}${isMetric ? 'm' : 'ft'}';
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
    if (distance <= 0) {
      return 'Distance must be greater than 0';
    }
    final maxDist =
        isMetric ? RangeLimits.maxDistance : RangeLimits.maxDistance * 0.621371;
    if (distance > maxDist) {
      return 'Distance must be less than ${maxDist.toStringAsFixed(0)}${isMetric ? 'km' : 'mi'}';
    }
    return null;
  }

  String? _validateTargetHeight(String? value) {
    if (value == null || value.isEmpty) {
      return null; // Target height is optional
    }
    final height = double.tryParse(value);
    if (height == null) {
      return 'Please enter a valid number';
    }
    if (height < 0) {
      return 'Height cannot be negative';
    }

    // Convert input to meters if in imperial
    final heightInMeters = isMetric ? height : height / 3.28084;

    if (heightInMeters > RangeLimits.maxTargetHeight) {
      final maxDisplay = isMetric
          ? RangeLimits.maxTargetHeight
          : RangeLimits.maxTargetHeight * 3.28084;
      return 'Height must be less than ${maxDisplay.toStringAsFixed(0)}${isMetric ? 'm' : 'ft'}';
    }
    return null;
  }
}
