import 'package:flutter/material.dart';

import '../../models/line_of_sight_preset.dart';
import '../common/info_icon.dart';

class PresetSelector extends StatefulWidget {
  final LineOfSightPreset? selectedPreset;
  final ValueChanged<LineOfSightPreset?> onPresetChanged;
  final bool isMetric;
  final ValueChanged<bool> onMetricChanged;

  const PresetSelector({
    super.key,
    required this.selectedPreset,
    required this.onPresetChanged,
    required this.isMetric,
    required this.onMetricChanged,
  });

  @override
  State<PresetSelector> createState() => _PresetSelectorState();
}

class _PresetSelectorState extends State<PresetSelector> {
  List<LineOfSightPreset> _presets = const [];
  LineOfSightPreset? _lastSelectedPreset;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _lastSelectedPreset = widget.selectedPreset;
    _loadPresets();
  }

  @override
  void didUpdateWidget(PresetSelector oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.selectedPreset != null) {
      _lastSelectedPreset = widget.selectedPreset;
    }
  }

  Future<void> _loadPresets() async {
    final presets = await LineOfSightPreset.loadPresets(includeHidden: false);
    if (!mounted) return;

    setState(() {
      _presets = presets;
      _isLoading = false;
      _lastSelectedPreset ??=
          widget.selectedPreset ?? (presets.isEmpty ? null : presets.first);
    });
  }

  void _setExampleMode(bool useExample) {
    if (!useExample) {
      widget.onPresetChanged(null);
      return;
    }

    final preset =
        _lastSelectedPreset ?? (_presets.isEmpty ? null : _presets.first);
    if (preset != null) widget.onPresetChanged(preset);
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    final isExampleMode = widget.selectedPreset != null;

    return LayoutBuilder(
      builder: (context, constraints) {
        final isNarrow = constraints.maxWidth < 600;
        final sourceSelector = _buildSelector<bool>(
          key: const ValueKey('preset_mode_selector'),
          selected: isExampleMode,
          firstValue: true,
          firstLabel: 'Example scenario',
          secondValue: false,
          secondLabel: 'My own values',
          onChanged: _setExampleMode,
        );
        final unitsSelector = _buildSelector<bool>(
          key: const ValueKey('units_selector'),
          selected: widget.isMetric,
          firstValue: true,
          firstLabel: 'Metric',
          secondValue: false,
          secondLabel: 'Imperial',
          onChanged: widget.onMetricChanged,
        );

        return Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            if (isNarrow) ...[
              _labelledControl('Start with', sourceSelector),
              const SizedBox(height: 16),
              _labelledControl('Units', unitsSelector),
            ] else
              Row(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Expanded(
                      child: _labelledControl('Start with', sourceSelector)),
                  const SizedBox(width: 16),
                  _labelledControl('Units', unitsSelector),
                ],
              ),
            if (isExampleMode) ...[
              const SizedBox(height: 16),
              Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Expanded(
                    child: DropdownButtonFormField<LineOfSightPreset>(
                      key: const ValueKey('preset_dropdown'),
                      isExpanded: true,
                      value: widget.selectedPreset,
                      decoration: const InputDecoration(
                        labelText: 'Example scenario',
                        border: OutlineInputBorder(),
                      ),
                      items: _presets
                          .map(
                            (preset) => DropdownMenuItem(
                              value: preset,
                              child: Text(
                                preset.name,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          )
                          .toList(),
                      onChanged: (preset) {
                        if (preset == null) return;
                        _lastSelectedPreset = preset;
                        widget.onPresetChanged(preset);
                      },
                    ),
                  ),
                  const SizedBox(width: 8),
                  const InfoIcon(infoKey: 'presets', size: 20),
                ],
              ),
              Align(
                alignment: Alignment.centerRight,
                child: TextButton.icon(
                  onPressed: () => widget.onPresetChanged(null),
                  icon: const Icon(Icons.edit_outlined, size: 18),
                  label: const Text('Edit these values'),
                ),
              ),
            ] else ...[
              const SizedBox(height: 12),
              Text(
                'Enter your own observer, distance, surface and target values below.',
                style: Theme.of(context).textTheme.bodySmall,
              ),
            ],
            const SizedBox(height: 8),
            const Divider(),
          ],
        );
      },
    );
  }

  Widget _labelledControl(String label, Widget control) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(fontWeight: FontWeight.w600)),
        const SizedBox(height: 6),
        control,
      ],
    );
  }

  Widget _buildSelector<T>({
    required Key key,
    required T selected,
    required T firstValue,
    required String firstLabel,
    required T secondValue,
    required String secondLabel,
    required ValueChanged<T> onChanged,
  }) {
    return SegmentedButton<T>(
      key: key,
      showSelectedIcon: false,
      segments: [
        ButtonSegment(value: firstValue, label: Text(firstLabel)),
        ButtonSegment(value: secondValue, label: Text(secondLabel)),
      ],
      selected: {selected},
      onSelectionChanged: (values) => onChanged(values.first),
    );
  }
}
