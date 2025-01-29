import 'package:flutter/material.dart';
import '../services/curvature_calculator.dart';
import '../services/models/calculation_result.dart';
import '../models/line_of_sight_preset.dart';
import 'calculator/preset_selector.dart';
import 'calculator/input_fields.dart';
import 'calculator/results_display.dart';
import 'calculator/diagram_display.dart';
import 'long_line_info_dialog.dart';

class CalculatorForm extends StatefulWidget {
  const CalculatorForm({super.key});

  @override
  State<CalculatorForm> createState() => _CalculatorFormState();
}

class _CalculatorFormState extends State<CalculatorForm> {
  final _formKey = GlobalKey<FormState>();
  final _observerHeightController = TextEditingController();
  final _distanceController = TextEditingController();
  final _refractionFactorController = TextEditingController(text: '1.07');
  final _targetHeightController = TextEditingController();
  final _presetSelectorKey = GlobalKey();

  bool _isMetric = true;
  LineOfSightPreset? _selectedPreset;
  CalculationResult? _result;
  PresetSelector? _presetSelector;

  @override
  void initState() {
    super.initState();
    print('CalculatorForm - initState called');
    _initializeForm();
  }

  Future<void> _initializeForm() async {
    print('CalculatorForm - _initializeForm started');
    // Initialize with empty result to avoid null errors
    _result = const CalculationResult();

    // Load presets first
    final presets = await LineOfSightPreset.loadPresets();
    print('CalculatorForm - Loaded ${presets.length} presets');
    
    if (presets.isNotEmpty && mounted) {
      // Set initial preset
      _selectedPreset = presets.first;
      print('CalculatorForm - Setting initial preset: ${_selectedPreset?.name}');

      setState(() {
        // Initialize controllers with preset values
        final observerHeight =
            _isMetric ? _selectedPreset!.observerHeight : _selectedPreset!.observerHeight * 3.28084;
        final distance =
            _isMetric ? _selectedPreset!.distance : _selectedPreset!.distance * 0.621371;
        _observerHeightController.text = observerHeight.toStringAsFixed(1);
        _distanceController.text = distance.toStringAsFixed(1);
        _refractionFactorController.text =
            _selectedPreset!.refractionFactor.toStringAsFixed(2);
        _targetHeightController.text =
            _selectedPreset!.targetHeight?.toString() ?? '';

        print('CalculatorForm - Controllers initialized with preset values');
      });

      // Create PresetSelector with initial preset
      _presetSelector = PresetSelector(
        key: _presetSelectorKey,
        selectedPreset: _selectedPreset,  // Now this has the first preset
        onPresetChanged: _handlePresetChanged,
      );

      // Calculate initial results
      WidgetsBinding.instance.addPostFrameCallback((_) {
        print('CalculatorForm - Post-frame callback triggered');
        _handleCalculate();
      });
    } else {
      // Create PresetSelector with no selection if no presets available
      _presetSelector = PresetSelector(
        key: _presetSelectorKey,
        selectedPreset: null,
        onPresetChanged: _handlePresetChanged,
      );
    }
  }

  void _handlePresetChanged(LineOfSightPreset? preset) {
    print('CalculatorForm - Preset changed to: ${preset?.name ?? "Custom Values"}');
    setState(() {
      _selectedPreset = preset;
      if (preset != null) {
        final observerHeight =
            _isMetric ? preset.observerHeight : preset.observerHeight * 3.28084;
        final distance = _isMetric ? preset.distance : preset.distance * 0.621371;
        _observerHeightController.text = observerHeight.toStringAsFixed(1);
        _distanceController.text = distance.toStringAsFixed(1);
        _refractionFactorController.text =
            preset.refractionFactor.toStringAsFixed(2);
        _targetHeightController.text = preset.targetHeight?.toString() ?? '';
        
        print('CalculatorForm - Updated controller values:');
        print('Observer Height: ${_observerHeightController.text}');
        print('Distance: ${_distanceController.text}');
        print('Refraction Factor: ${_refractionFactorController.text}');
        print('Target Height: ${_targetHeightController.text}');
      }
    });
    
    // Always calculate, even for Custom Values
    WidgetsBinding.instance.addPostFrameCallback((_) {
      print('CalculatorForm - Calling _handleCalculate after preset change');
      _handleCalculate();
    });
  }

  void _handleMetricChanged(bool isMetric) {
    if (isMetric == _isMetric) return;

    setState(() {
      _isMetric = isMetric;
      // Convert values if needed
      if (_observerHeightController.text.isNotEmpty) {
        final double value = double.parse(_observerHeightController.text);
        final double converted = isMetric ? value * 0.3048 : value * 3.28084;
        _observerHeightController.text = converted.toStringAsFixed(1);
      }
      if (_distanceController.text.isNotEmpty) {
        final double value = double.parse(_distanceController.text);
        final double converted = isMetric ? value * 1.60934 : value * 0.621371;
        _distanceController.text = converted.toStringAsFixed(1);
      }
      if (_targetHeightController.text.isNotEmpty) {
        final double value = double.parse(_targetHeightController.text);
        final double converted = isMetric ? value * 0.3048 : value * 3.28084;
        _targetHeightController.text = converted.toStringAsFixed(1);
      }
      // Automatically calculate when units change
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _handleCalculate();
      });
    });
  }

  void _handleCalculate() {
    print('CalculatorForm - _handleCalculate called');
    if (!_formKey.currentState!.validate()) {
      print('CalculatorForm - Form validation failed');
      return;
    }

    // Get values from controllers
    final double observerHeight = double.parse(_observerHeightController.text);
    final double distance = double.parse(_distanceController.text);
    final double refractionFactor =
        double.parse(_refractionFactorController.text);
    final double? targetHeight = _targetHeightController.text.isEmpty
        ? null
        : double.parse(_targetHeightController.text);

    print('CalculatorForm - Calculation inputs:');
    print('Observer Height: $observerHeight');
    print('Distance: $distance');
    print('Refraction Factor: $refractionFactor');
    print('Target Height: $targetHeight');
    print('Is Metric: $_isMetric');

    // Pass values in their original units (meters/feet and km/miles)
    final result = CurvatureCalculator.calculate(
      observerHeight: observerHeight,
      distance: distance,
      refractionFactor: refractionFactor,
      targetHeight: targetHeight,
      isMetric: _isMetric,
    );

    print('CalculatorForm - Calculation result: $result');

    setState(() {
      _result = result;
    });
  }

  @override
  void dispose() {
    _observerHeightController.dispose();
    _distanceController.dispose();
    _refractionFactorController.dispose();
    _targetHeightController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Form(
      key: _formKey,
      child: LayoutBuilder(
        builder: (context, constraints) {
          final isWide = constraints.maxWidth > 900; // Breakpoint for wide screens
          final isMobile = constraints.maxWidth < 600; // Mobile breakpoint

          // Adjust padding based on screen size
          final contentPadding = isMobile
              ? const EdgeInsets.all(8.0)
              : const EdgeInsets.all(16.0);

          // Create a single instance of InputFields
          final inputFields = InputFields(
            observerHeightController: _observerHeightController,
            distanceController: _distanceController,
            refractionFactorController: _refractionFactorController,
            targetHeightController: _targetHeightController,
            isMetric: _isMetric,
            onMetricChanged: _handleMetricChanged,
            onCalculate: _handleCalculate,
            showCalculateButton: true,
            isCustomPreset: _selectedPreset == null,
          );

          // Create a single instance of ResultsDisplay
          final resultsDisplay = ResultsDisplay(
            result: _result,
            isMetric: _isMetric,
            targetHeight: _targetHeightController.text.isEmpty
                ? null
                : double.parse(_targetHeightController.text),
          );

          Widget content = Column(
            children: [
              // Left side - Calculator inputs and results
              Card(
                child: SingleChildScrollView(
                  padding: contentPadding,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      _presetSelector ?? const SizedBox.shrink(),
                      SizedBox(height: isMobile ? 8 : 16),
                      inputFields,
                      SizedBox(height: isMobile ? 8 : 16),
                      resultsDisplay,
                    ],
                  ),
                ),
              ),
              if (!isWide) SizedBox(height: isMobile ? 8 : 16),
              // Right side - Diagram
              Card(
                child: Padding(
                  padding: contentPadding,
                  child: DiagramDisplay(
                    result: _result,
                    targetHeight: _targetHeightController.text.isEmpty
                        ? null
                        : double.parse(_targetHeightController.text),
                    isMetric: _isMetric,
                    presetName: _selectedPreset?.name,  // Pass null for Custom Values
                  ),
                ),
              ),
            ],
          );

          if (isWide) {
            // For wide screens, use a Row layout with the same widget instances
            content = Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Card(
                    child: SingleChildScrollView(
                      padding: contentPadding,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          _presetSelector ?? const SizedBox.shrink(),
                          SizedBox(height: isMobile ? 8 : 16),
                          inputFields,
                          SizedBox(height: isMobile ? 8 : 16),
                          resultsDisplay,
                        ],
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Card(
                    child: Padding(
                      padding: contentPadding,
                      child: DiagramDisplay(
                        result: _result,
                        targetHeight: _targetHeightController.text.isEmpty
                            ? null
                            : double.parse(_targetHeightController.text),
                        isMetric: _isMetric,
                        presetName: _selectedPreset?.name,  // Pass null for Custom Values
                      ),
                    ),
                  ),
                ),
              ],
            );
          }

          return content;
        },
      ),
    );
  }
}
