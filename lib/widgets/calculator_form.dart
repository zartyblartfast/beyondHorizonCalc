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

  bool _isMetric = true;
  LineOfSightPreset? _selectedPreset;
  CalculationResult? _result;

  @override
  void initState() {
    super.initState();
    _initializeForm();
  }

  Future<void> _initializeForm() async {
    // Initialize with empty result to avoid null errors
    _result = const CalculationResult();

    // Load presets and set default values
    final presets = await LineOfSightPreset.loadPresets();
    if (presets.isNotEmpty) {
      setState(() {
        _selectedPreset = presets.first;
        // Initialize controllers with default preset values
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

        // Calculate initial results after setting values
        WidgetsBinding.instance.addPostFrameCallback((_) {
          _handleCalculate();
        });
      });
    }
  }

  @override
  void dispose() {
    _observerHeightController.dispose();
    _distanceController.dispose();
    _refractionFactorController.dispose();
    _targetHeightController.dispose();
    super.dispose();
  }

  void _handlePresetChanged(LineOfSightPreset? preset) {
    setState(() {
      _selectedPreset = preset;
      if (preset != null) {
        final observerHeight =
            _isMetric ? preset.observerHeight : preset.observerHeight * 3.28084;
        final distance =
            _isMetric ? preset.distance : preset.distance * 0.621371;
        _observerHeightController.text = observerHeight.toStringAsFixed(1);
        _distanceController.text = distance.toStringAsFixed(1);
        _refractionFactorController.text = preset.refractionFactor.toStringAsFixed(2);
        _targetHeightController.text = preset.targetHeight?.toString() ?? '';
        // Automatically calculate when preset changes
        WidgetsBinding.instance.addPostFrameCallback((_) {
          _handleCalculate();
        });
      }
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
    if (!_formKey.currentState!.validate()) return;

    // Get values from controllers
    final double observerHeight = double.parse(_observerHeightController.text);
    final double distance = double.parse(_distanceController.text);
    final double refractionFactor =
        double.parse(_refractionFactorController.text);
    final double? targetHeight = _targetHeightController.text.isEmpty
        ? null
        : double.parse(_targetHeightController.text);

    // Pass values in their original units (meters/feet and km/miles)
    final result = CurvatureCalculator.calculate(
      observerHeight: observerHeight,
      distance: distance,
      refractionFactor: refractionFactor,
      targetHeight: targetHeight,
      isMetric: _isMetric,
    );

    setState(() {
      _result = result;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Form(
      key: _formKey,
      child: LayoutBuilder(
        builder: (context, constraints) {
          final isWide =
              constraints.maxWidth > 900; // Breakpoint for wide screens

          Widget content = Column(
            children: [
              // Left side - Calculator inputs and results
              Card(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      PresetSelector(
                        selectedPreset: _selectedPreset,
                        onPresetChanged: _handlePresetChanged,
                      ),
                      const SizedBox(height: 16),
                      InputFields(
                        observerHeightController: _observerHeightController,
                        distanceController: _distanceController,
                        refractionFactorController: _refractionFactorController,
                        targetHeightController: _targetHeightController,
                        isMetric: _isMetric,
                        onMetricChanged: _handleMetricChanged,
                        onCalculate: _handleCalculate,
                        showCalculateButton: _selectedPreset == null,
                        isCustomPreset: _selectedPreset == null,
                      ),
                      const SizedBox(height: 16),
                      ResultsDisplay(
                        result: _result,
                        isMetric: _isMetric,
                        targetHeight: _targetHeightController.text.isEmpty
                            ? null
                            : double.parse(_targetHeightController.text),
                      ),
                    ],
                  ),
                ),
              ),
              if (!isWide) const SizedBox(height: 16),
              // Right side - Diagram
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: DiagramDisplay(
                    result: _result,
                    targetHeight: _targetHeightController.text.isEmpty
                        ? null
                        : double.parse(_targetHeightController.text),
                  ),
                ),
              ),
            ],
          );

          if (isWide) {
            // For wide screens, use a Row layout
            content = Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Card(
                    child: SingleChildScrollView(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          PresetSelector(
                            selectedPreset: _selectedPreset,
                            onPresetChanged: _handlePresetChanged,
                          ),
                          const SizedBox(height: 16),
                          InputFields(
                            observerHeightController: _observerHeightController,
                            distanceController: _distanceController,
                            refractionFactorController:
                                _refractionFactorController,
                            targetHeightController: _targetHeightController,
                            isMetric: _isMetric,
                            onMetricChanged: _handleMetricChanged,
                            onCalculate: _handleCalculate,
                            showCalculateButton: _selectedPreset == null,
                            isCustomPreset: _selectedPreset == null,
                          ),
                          const SizedBox(height: 16),
                          ResultsDisplay(
                            result: _result,
                            isMetric: _isMetric,
                            targetHeight: _targetHeightController.text.isEmpty
                                ? null
                                : double.parse(_targetHeightController.text),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 32),
                Expanded(
                  child: Card(
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: DiagramDisplay(
                        result: _result,
                        targetHeight: _targetHeightController.text.isEmpty
                            ? null
                            : double.parse(_targetHeightController.text),
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
