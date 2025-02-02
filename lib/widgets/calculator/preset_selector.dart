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
    print('PresetSelector - initState with selectedPreset: ${widget.selectedPreset?.name}');
    _loadPresets();
  }

  Future<void> _loadPresets() async {
    print('PresetSelector - Loading presets');
    final presets = await LineOfSightPreset.loadPresets();
    print('PresetSelector - Loaded ${presets.length} presets');
    
    if (mounted) {
      setState(() {
        _presets = presets;
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    print('PresetSelector - Building with selectedPreset: ${widget.selectedPreset?.name}');

    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    // Create dropdown items during build
    final dropdownItems = [
      ..._presets.map((preset) => DropdownMenuItem<LineOfSightPreset?>(
            value: preset,
            child: Text(
              preset.name,
              overflow: TextOverflow.ellipsis,
            ),
          )),
      const DropdownMenuItem<LineOfSightPreset?>(
        value: null,
        child: Text('Custom Values'),
      ),
    ];

    return LayoutBuilder(
      builder: (context, constraints) {
        final isNarrow = constraints.maxWidth < 600;
        print('PresetSelector - Layout width: ${constraints.maxWidth}');
        
        final contentPadding = isNarrow 
            ? const EdgeInsets.all(8.0)
            : const EdgeInsets.all(16.0);
        final dropdownPadding = isNarrow 
            ? const EdgeInsets.symmetric(horizontal: 8, vertical: 12)
            : const EdgeInsets.symmetric(horizontal: 12, vertical: 16);

        return Card(
          child: Padding(
            padding: contentPadding,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Expanded(
                      child: Container(
                        width: double.infinity,
                        padding: dropdownPadding,
                        child: DropdownButtonFormField<LineOfSightPreset?>(
                          key: const ValueKey('preset_dropdown'),
                          isExpanded: true,
                          value: widget.selectedPreset,
                          decoration: InputDecoration(
                            labelText: 'Notable Line of Sight',
                            border: const OutlineInputBorder(),
                            floatingLabelBehavior: FloatingLabelBehavior.always,
                            contentPadding: isNarrow 
                                ? const EdgeInsets.symmetric(horizontal: 8, vertical: 12)
                                : const EdgeInsets.symmetric(horizontal: 12, vertical: 16),
                          ),
                          items: dropdownItems,
                          onChanged: widget.onPresetChanged,
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),  
                    SizedBox(
                      width: 24,
                      height: isNarrow ? 40 : 48,
                      child: Center(
                        child: InfoIcon(
                          infoKey: 'presets',
                          size: 20,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
