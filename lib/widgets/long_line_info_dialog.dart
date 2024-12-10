import 'package:flutter/material.dart';
import '../models/line_of_sight_preset.dart';
import 'slides_viewer.dart';

class LongLineInfoDialog extends StatelessWidget {
  const LongLineInfoDialog({super.key});

  @override
  Widget build(BuildContext context) {
    return Dialog(
      child: Container(
        constraints: const BoxConstraints(maxWidth: 1000, maxHeight: 800),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            AppBar(
              title: const Text('Understanding Earth\'s Curvature'),
              centerTitle: true,
              automaticallyImplyLeading: false,
              actions: [
                IconButton(
                  icon: const Icon(Icons.close),
                  onPressed: () => Navigator.of(context).pop(),
                ),
              ],
            ),
            Expanded(
              child: SingleChildScrollView(
                child: Column(
                  children: [
                    const Padding(
                      padding: EdgeInsets.all(16.0),
                      child: SlidesViewer(),
                    ),
                    Padding(
                      padding: const EdgeInsets.all(24.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Famous Lines of Sight',
                            style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 16),
                          for (final preset in LineOfSightPreset.presets) ...[
                            Text(
                              preset.name,
                              style: Theme.of(context).textTheme.titleLarge,
                            ),
                            const SizedBox(height: 8),
                            Text(preset.description),
                            const SizedBox(height: 8),
                            Text(
                              'Observer Height: ${preset.observerHeight.toStringAsFixed(0)} meters',
                              style: Theme.of(context).textTheme.bodyLarge,
                            ),
                            Text(
                              'Distance: ${preset.distance.toStringAsFixed(0)} kilometers',
                              style: Theme.of(context).textTheme.bodyLarge,
                            ),
                            const SizedBox(height: 24),
                          ],
                          const SizedBox(height: 16),
                          Text(
                            'Note: These observations take into account atmospheric refraction, which can bend light and allow us to see slightly beyond the geometric horizon.',
                            style: Theme.of(context).textTheme.bodySmall,
                          ),
                        ],
                      ),
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
