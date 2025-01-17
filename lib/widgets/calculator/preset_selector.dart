import 'package:flutter/material.dart';
import '../../models/line_of_sight_preset.dart';
import '../common/info_icon.dart';

class PresetSelector extends StatelessWidget {
  final LineOfSightPreset? selectedPreset;
  final ValueChanged<LineOfSightPreset?> onPresetChanged;

  const PresetSelector({
    super.key,
    required this.selectedPreset,
    required this.onPresetChanged,
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
                  flex: 3,
                  child: DropdownButtonFormField<LineOfSightPreset>(
                    value: selectedPreset,
                    decoration: const InputDecoration(
                      labelText: 'Famous Line of Sight',
                      border: OutlineInputBorder(),
                      floatingLabelBehavior: FloatingLabelBehavior.always,
                    ),
                    items: [
                      ...LineOfSightPreset.presets.map(
                        (preset) => DropdownMenuItem(
                          value: preset,
                          child: Text(
                            preset.name,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ),
                      const DropdownMenuItem(
                        value: null,
                        child: Text('Custom Values'),
                      ),
                    ],
                    onChanged: onPresetChanged,
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
