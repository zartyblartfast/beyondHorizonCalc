import 'package:flutter/material.dart';
import 'dart:math' as math;
import 'earth_curve_diagram.dart';
import '../models/line_of_sight_preset.dart';
import 'long_line_info_dialog.dart';

class CalculatorForm extends StatefulWidget {
  const CalculatorForm({super.key});

  @override
  State<CalculatorForm> createState() => _CalculatorFormState();
}

class _CalculatorFormState extends State<CalculatorForm> {
  final _formKey = GlobalKey<FormState>();
  final double earthRadius = 6371000; // meters
  
  final _observerHeightController = TextEditingController();
  final _distanceController = TextEditingController();
  final _targetHeightController = TextEditingController();
  
  double observerHeight = 7015.0; // default to first preset
  double distance = 539.0; // default to first preset
  double? targetHeight; // Optional target height
  double refractionFactor = 1.07; // default average refraction
  LineOfSightPreset? selectedPreset = LineOfSightPreset.presets[0]; // default to first preset
  
  Map<String, double> results = {
    'horizonDistance': 0,
    'hiddenHeight': 0,
    'totalDistance': 0,
    'visibleDistance': 0,
    'visibleTargetHeight': 0, // New field for visible portion of target
  };

  void _calculateCurvature() {
    double radius = earthRadius * refractionFactor;
    double height = observerHeight;
    double length = distance * 1000; // convert km to meters

    // Calculate horizon distance (horizonDistance)
    double horizonDistance = math.sqrt(2 * height * radius);
    
    // Calculate remaining parameters
    double remainingLength = length - horizonDistance;
    double boxFraction = remainingLength / (2 * math.pi * radius);
    double boxAngle = 2 * math.pi * boxFraction;
    
    if (boxAngle >= math.pi / 2) {
      // Handle error case
      return;
    }

    double oppositeCenter = radius / math.cos(boxAngle);
    double baseCenter = oppositeCenter * math.sin(boxAngle);
    
    if (baseCenter <= 0) {
      // Handle error case
      return;
    }

    double xCoordinate = oppositeCenter - radius;
    double totalDistance = horizonDistance + baseCenter;
    
    // Calculate visible height of target if target height is provided
    double visibleTargetHeight = 0;
    if (targetHeight != null && targetHeight! > 0) {
      visibleTargetHeight = targetHeight! - (baseCenter / 1000); // Convert hidden height to km
      visibleTargetHeight = visibleTargetHeight < 0 ? 0 : visibleTargetHeight; // Can't be negative
    }

    setState(() {
      results = {
        'horizonDistance': horizonDistance / 1000, // convert to km
        'hiddenHeight': baseCenter / 1000, // convert to km
        'totalDistance': totalDistance / 1000, // convert to km
        'visibleDistance': xCoordinate / 1000, // convert to km
        'visibleTargetHeight': visibleTargetHeight, // already in km
      };
    });
  }

  void _showLongLineOfSightInfo() {
    showDialog(
      context: context,
      builder: (context) => const LongLineInfoDialog(),
    );
  }

  @override
  void initState() {
    super.initState();
    // Initialize controllers with default preset values
    _observerHeightController.text = observerHeight.toString();
    _distanceController.text = distance.toString();
    _targetHeightController.text = selectedPreset?.targetHeight?.toString() ?? '';
    targetHeight = selectedPreset?.targetHeight;
    _calculateCurvature();
  }

  @override
  void dispose() {
    _observerHeightController.dispose();
    _distanceController.dispose();
    _targetHeightController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Form(
      key: _formKey,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Preset Selector
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        Row(
                          children: [
                            Expanded(
                              child: DropdownButtonFormField<LineOfSightPreset>(
                                value: selectedPreset,
                                decoration: InputDecoration(
                                  labelText: 'Famous Line of Sight',
                                  border: const OutlineInputBorder(),
                                  floatingLabelBehavior: FloatingLabelBehavior.always,
                                ),
                                items: [
                                  ...LineOfSightPreset.presets.map(
                                    (preset) => DropdownMenuItem(
                                      value: preset,
                                      child: Text(preset.name),
                                    ),
                                  ),
                                  const DropdownMenuItem(
                                    value: null,
                                    child: Text('Custom Values'),
                                  ),
                                ],
                                onChanged: (preset) {
                                  setState(() {
                                    selectedPreset = preset;
                                    if (preset != null) {
                                      observerHeight = preset.observerHeight;
                                      distance = preset.distance;
                                      refractionFactor = preset.refractionFactor;
                                      targetHeight = preset.targetHeight;
                                      _observerHeightController.text = observerHeight.toString();
                                      _distanceController.text = distance.toString();
                                      _targetHeightController.text = targetHeight?.toString() ?? '';
                                      _calculateCurvature();
                                    }
                                  });
                                },
                              ),
                            ),
                            const SizedBox(width: 16),
                            ElevatedButton.icon(
                              onPressed: _showLongLineOfSightInfo,
                              icon: const Icon(Icons.info_outline),
                              label: const Text('Learn More'),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                // Input Section
                Card(
                  child: ExpansionTile(
                    title: const Text('Calculator Inputs'),
                    initiallyExpanded: true,
                    children: [
                      Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            Text(
                              selectedPreset != null 
                                ? 'Calculator Inputs - Using ${selectedPreset!.name}'
                                : 'Calculator Inputs - Custom Values (Edit as needed)',
                              style: Theme.of(context).textTheme.titleMedium,
                            ),
                            const SizedBox(height: 24),
                            TextFormField(
                              controller: _observerHeightController,
                              decoration: InputDecoration(
                                labelText: 'Observer Height',
                                suffixText: 'm',
                                border: const OutlineInputBorder(),
                                floatingLabelBehavior: FloatingLabelBehavior.always,
                                hintText: 'Height above sea level',
                              ),
                              keyboardType: TextInputType.number,
                              onChanged: (value) {
                                setState(() {
                                  observerHeight = double.tryParse(value) ?? observerHeight;
                                  _calculateCurvature();
                                });
                              },
                            ),
                            const SizedBox(height: 24),
                            TextFormField(
                              controller: _distanceController,
                              decoration: InputDecoration(
                                labelText: 'Distance',
                                suffixText: 'km',
                                border: const OutlineInputBorder(),
                                floatingLabelBehavior: FloatingLabelBehavior.always,
                                hintText: 'Distance to object',
                              ),
                              keyboardType: TextInputType.number,
                              onChanged: (value) {
                                setState(() {
                                  distance = double.tryParse(value) ?? distance;
                                  _calculateCurvature();
                                });
                              },
                            ),
                            const SizedBox(height: 24),
                            TextFormField(
                              controller: _targetHeightController,
                              decoration: InputDecoration(
                                labelText: 'Target Height (Optional)',
                                suffixText: 'm',
                                border: const OutlineInputBorder(),
                                floatingLabelBehavior: FloatingLabelBehavior.always,
                                hintText: 'Height of target object',
                              ),
                              keyboardType: TextInputType.number,
                              onChanged: (value) {
                                setState(() {
                                  targetHeight = value.isEmpty ? null : (double.tryParse(value) ?? targetHeight);
                                  _calculateCurvature();
                                });
                              },
                            ),
                            const SizedBox(height: 24),
                            DropdownButtonFormField<double>(
                              value: refractionFactor,
                              decoration: InputDecoration(
                                labelText: 'Atmospheric Refraction',
                                border: const OutlineInputBorder(),
                                floatingLabelBehavior: FloatingLabelBehavior.always,
                                hintText: 'Select refraction conditions',
                              ),
                              items: const [
                                DropdownMenuItem(value: 1.00, child: Text('No Refraction')),
                                DropdownMenuItem(value: 1.02, child: Text('Low Refraction')),
                                DropdownMenuItem(value: 1.04, child: Text('Below Average')),
                                DropdownMenuItem(value: 1.07, child: Text('Average Refraction')),
                                DropdownMenuItem(value: 1.10, child: Text('Above Average')),
                                DropdownMenuItem(value: 1.15, child: Text('High Refraction')),
                              ],
                              onChanged: (value) {
                                setState(() {
                                  refractionFactor = value ?? refractionFactor;
                                  _calculateCurvature();
                                });
                              },
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),
                // Results Section
                Card(
                  child: ExpansionTile(
                    title: const Text('Results'),
                    initiallyExpanded: true,
                    children: [
                      Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Column(
                          children: [
                            ResultCard(
                              title: 'Distance to Horizon',
                              value: results['horizonDistance']!,
                              unit: 'km',
                              description: 'Maximum visible distance',
                            ),
                            const SizedBox(height: 8),
                            ResultCard(
                              title: 'Hidden Height',
                              value: results['hiddenHeight']!,
                              unit: 'km',
                              description: 'Hidden by curvature',
                            ),
                            const SizedBox(height: 8),
                            if (targetHeight != null) ...[
                              ResultCard(
                                title: 'Visible Height',
                                value: results['visibleTargetHeight']!,
                                unit: 'km',
                                description: 'Visible portion of target',
                              ),
                              const SizedBox(height: 8),
                            ],
                            ResultCard(
                              title: 'Total Distance',
                              value: results['totalDistance']!,
                              unit: 'km',
                              description: 'To remote object',
                            ),
                            const SizedBox(height: 8),
                            ResultCard(
                              title: 'Visible Distance',
                              value: results['visibleDistance']!,
                              unit: 'km',
                              description: 'Beyond horizon',
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 32),
          // Right side - Diagram
          Expanded(
            child: Card(
              key: UniqueKey(),
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: EarthCurveDiagram(
                  observerHeight: observerHeight,
                  distanceToHorizon: results['horizonDistance']!,
                  totalDistance: results['totalDistance']!,
                  hiddenHeight: results['hiddenHeight']! * 1000, // convert back to meters
                  visibleDistance: results['visibleDistance']!,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class ResultCard extends StatelessWidget {
  final String title;
  final double value;
  final String unit;
  final String description;

  const ResultCard({
    super.key,
    required this.title,
    required this.value,
    required this.unit,
    required this.description,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 4),
            Row(
              children: [
                Text(
                  value.toStringAsFixed(2),
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    color: Theme.of(context).colorScheme.primary,
                  ),
                ),
                const SizedBox(width: 4),
                Text(
                  unit,
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
              ],
            ),
            const SizedBox(height: 4),
            Text(
              description,
              style: Theme.of(context).textTheme.bodySmall,
            ),
          ],
        ),
      ),
    );
  }
}
