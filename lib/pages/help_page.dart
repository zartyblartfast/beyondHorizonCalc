import 'package:flutter/material.dart';
import '../widgets/slides_viewer.dart';
import '../models/line_of_sight_preset.dart';

class HelpPage extends StatefulWidget {
  const HelpPage({super.key});

  @override
  State<HelpPage> createState() => _HelpPageState();
}

class _HelpPageState extends State<HelpPage> {
  List<LineOfSightPreset> _presets = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadPresets();
  }

  Future<void> _loadPresets() async {
    print('HelpPage - Loading presets');
    // Load only visible presets
    final presets = await LineOfSightPreset.loadPresets(includeHidden: false);
    print('HelpPage - Loaded ${presets.length} visible presets');
    
    if (mounted) {
      setState(() {
        _presets = presets;
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Help'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SlidesViewer(),
            const SizedBox(height: 32),
            const Text(
              'Notable Long Lines of Sight',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            if (_isLoading)
              const Center(child: CircularProgressIndicator())
            else
              ..._presets.map((preset) => Card(
                    margin: const EdgeInsets.only(bottom: 16),
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            preset.name,
                            style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(preset.description),
                          const SizedBox(height: 8),
                          Text(
                            'Distance: ${preset.distance.toStringAsFixed(1)} km',
                            style: const TextStyle(fontStyle: FontStyle.italic),
                          ),
                        ],
                      ),
                    ),
                  )),
            const SizedBox(height: 16),
            const Card(
              child: Padding(
                padding: EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'How to Use',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(height: 8),
                    Text(
                      '1. Enter the observer height in meters\n'
                      '2. Enter the distance to target in kilometers\n'
                      '3. Optionally enter target height in meters\n'
                      '4. Click Calculate to see results',
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
