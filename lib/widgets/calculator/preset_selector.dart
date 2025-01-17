import 'package:flutter/material.dart';
import '../../models/line_of_sight_preset.dart';
import '../common/info_icon.dart';

class PresetSelector extends StatefulWidget {
  final LineOfSightPreset? selectedPreset;
  final ValueChanged<LineOfSightPreset?> onPresetChanged;

  const PresetSelector({
    super.key,
    required this.selectedPreset,
    required this.onPresetChanged,
  });

  @override
  State<PresetSelector> createState() => _PresetSelectorState();
}

class _PresetSelectorState extends State<PresetSelector> {
  List<LineOfSightPreset> _presets = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadPresets();
  }

  Future<void> _loadPresets() async {
    final presets = await LineOfSightPreset.loadPresets();
    if (mounted) {
      setState(() {
        _presets = presets;
        // If no preset is selected and we have presets, select the first one
        if (widget.selectedPreset == null && presets.isNotEmpty) {
          widget.onPresetChanged(presets.first);
        }
        _isLoading = false;
      });
    }
  }

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
                  flex: 3,
                  child: _isLoading
                      ? const Center(child: CircularProgressIndicator())
                      : DropdownButtonFormField<LineOfSightPreset>(
                          value: widget.selectedPreset,
                          decoration: const InputDecoration(
                            labelText: 'Famous Line of Sight',
                            border: OutlineInputBorder(),
                            floatingLabelBehavior: FloatingLabelBehavior.always,
                          ),
                          items: [
                            const DropdownMenuItem(
                              value: null,
                              child: Text('Custom Values'),
                            ),
                            ..._presets.map(
                              (preset) => DropdownMenuItem(
                                value: preset,
                                child: Text(
                                  preset.name,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                            ),
                          ],
                          onChanged: widget.onPresetChanged,
                        ),
                ),
                const SizedBox(width: 8),
                const InfoIcon(infoKey: 'presets'),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
