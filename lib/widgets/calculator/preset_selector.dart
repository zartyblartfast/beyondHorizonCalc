import 'package:flutter/material.dart';
import '../../models/line_of_sight_preset.dart';
import '../long_line_info_dialog.dart';

class PresetSelector extends StatelessWidget {
  final LineOfSightPreset? selectedPreset;
  final ValueChanged<LineOfSightPreset?> onPresetChanged;
  final VoidCallback onInfoPressed;

  const PresetSelector({
    super.key,
    required this.selectedPreset,
    required this.onPresetChanged,
    required this.onInfoPressed,
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
                const SizedBox(width: 16),
                Expanded(
                  flex: 1,
                  child: ElevatedButton.icon(
                    onPressed: onInfoPressed,
                    icon: const Icon(Icons.info_outline),
                    label: const Text('Learn More'),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
