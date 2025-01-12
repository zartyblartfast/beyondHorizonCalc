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
    'visibleTargetHeight': 0, // Actual visible height (CZ)
    'apparentVisibleHeight': 0, // Apparent visible height (CD)
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
    double hiddenHeight = 0;
    double apparentVisibleHeight = 0;
    if (targetHeight != null && targetHeight! > 0) {
      // All calculations in meters for consistency
      double targetHeightMeters = targetHeight! * 1000; // Convert target height to meters
      
      // Calculate hidden height using earth curvature formula: h = d²/(2R)
      // where d is the distance beyond horizon (baseCenter)
      hiddenHeight = (baseCenter * baseCenter) / (2 * radius);
      
      // Actual visible height is target height minus hidden height
      visibleTargetHeight = targetHeightMeters - hiddenHeight;
      visibleTargetHeight = visibleTargetHeight < 0 ? 0 : visibleTargetHeight;

      // Calculate apparent visible height (CD)
      if (visibleTargetHeight > 0) {
        // Calculate angle between horizon line (BC) and vertical at target (CZ)
        // This is the same as the angle between OX and OB
        double verticalAngle = math.atan2(baseCenter, radius);
        
        // CD = CZ * cos(angle)
        // where CZ is visibleTargetHeight and angle is between BC and CZ
        apparentVisibleHeight = visibleTargetHeight * math.cos(verticalAngle);
      }
    }

    setState(() {
      results = {
        'horizonDistance': horizonDistance / 1000, // convert to km
        'hiddenHeight': hiddenHeight / 1000, // convert to km
        'totalDistance': totalDistance / 1000, // convert to km
        'visibleDistance': xCoordinate / 1000, // convert to km
        'visibleTargetHeight': visibleTargetHeight / 1000, // convert to km
        'apparentVisibleHeight': apparentVisibleHeight / 1000, // convert to km
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
      child: GestureDetector(
        onTap: () => FocusScope.of(context).unfocus(),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: Column(
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
                                  decoration: const InputDecoration(
                                    labelText: 'Famous Line of Sight',
                                    border: OutlineInputBorder(),
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
                              Focus(
                                autofocus: false,
                                child: TextFormField(
                                  controller: _observerHeightController,
                                  decoration: const InputDecoration(
                                    labelText: 'Observer Height (meters)',
                                    hintText: 'Enter height in meters',
                                  ),
                                  keyboardType: TextInputType.number,
                                  onChanged: (value) {
                                    setState(() {
                                      observerHeight = double.tryParse(value) ?? observerHeight;
                                      _calculateCurvature();
                                    });
                                  },
                                ),
                              ),
                              const SizedBox(height: 24),
                              Focus(
                                autofocus: false,
                                child: TextFormField(
                                  controller: _distanceController,
                                  decoration: const InputDecoration(
                                    labelText: 'Distance (kilometers)',
                                    hintText: 'Enter distance in kilometers',
                                  ),
                                  keyboardType: TextInputType.number,
                                  onChanged: (value) {
                                    setState(() {
                                      distance = double.tryParse(value) ?? distance;
                                      _calculateCurvature();
                                    });
                                  },
                                ),
                              ),
                              const SizedBox(height: 24),
                              Focus(
                                autofocus: false,
                                child: TextFormField(
                                  controller: _targetHeightController,
                                  decoration: const InputDecoration(
                                    labelText: 'Target Height (meters)',
                                    hintText: 'Enter target height in meters (optional)',
                                  ),
                                  keyboardType: TextInputType.number,
                                  onChanged: (value) {
                                    setState(() {
                                      targetHeight = value.isEmpty ? null : (double.tryParse(value) ?? targetHeight);
                                      _calculateCurvature();
                                    });
                                  },
                                ),
                              ),
                              const SizedBox(height: 24),
                              DropdownButtonFormField<double>(
                                value: refractionFactor,
                                decoration: const InputDecoration(
                                  labelText: 'Atmospheric Refraction',
                                  border: OutlineInputBorder(),
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
                            crossAxisAlignment: CrossAxisAlignment.stretch,
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
                                unit: 'm',
                                description: 'Hidden by curvature',
                              ),
                              const SizedBox(height: 8),
                              if (targetHeight != null) ...[
                                ResultCard(
                                  title: 'Actual Visible Height',
                                  value: results['visibleTargetHeight']!,
                                  unit: 'm',
                                  description: 'True vertical height above horizon (CZ)',
                                ),
                                const SizedBox(height: 8),
                                ResultCard(
                                  title: 'Apparent Visible Height',
                                  value: results['apparentVisibleHeight']!,
                                  unit: 'm',
                                  description: 'Height as seen by observer, adjusted for perspective (CD)',
                                ),
                                const SizedBox(height: 8),
                              ],
                              ResultCard(
                                title: 'Total Distance',
                                value: results['totalDistance']!,
                                unit: 'km',
                                description: 'To remote object',
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
              child: EarthCurveDiagram(
                observerHeight: observerHeight,
                distanceToHorizon: results['horizonDistance']!,
                totalDistance: results['totalDistance']!,
                hiddenHeight: results['hiddenHeight']!, 
                visibleDistance: results['visibleDistance']!,
              ),
            ),
          ],
        ),
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
