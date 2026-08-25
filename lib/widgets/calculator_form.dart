import 'package:flutter/material.dart';
import '../services/curvature_calculator.dart';
import '../services/models/calculation_result.dart';
import '../models/line_of_sight_preset.dart';
import 'calculator/preset_selector.dart';
import 'calculator/input_fields.dart';
import 'calculator/results_display.dart';
import 'calculator/diagram_display.dart';

class CalculatorForm extends StatefulWidget {
  const CalculatorForm({super.key});

  @override
  State<CalculatorForm> createState() => _CalculatorFormState();
}

class _CalculatorFormState extends State<CalculatorForm> {
  final _formKey = GlobalKey<FormState>();
  final _observerHeightController = TextEditingController();
  final _interveningSurfaceElevationController =
      TextEditingController(text: '0');
  final _distanceController = TextEditingController();
  final _refractionFactorController = TextEditingController(text: '1.07');
  final _targetHeightController = TextEditingController();
  final _targetBaseElevationController = TextEditingController(text: '0');
  final _presetSelectorKey = GlobalKey();

  bool _isMetric = true;
  TargetInputType _targetInputType = TargetInputType.elevation;
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

    // Load presets first
    final presets = await LineOfSightPreset.loadPresets();

    if (presets.isNotEmpty && mounted) {
      // Set initial preset
      _selectedPreset = presets.first;

      setState(() {
        // Initialize controllers with preset values
        final observerHeight = _isMetric
            ? _selectedPreset!.observerHeight
            : _selectedPreset!.observerHeight * 3.28084;
        final distance = _isMetric
            ? _selectedPreset!.distance
            : _selectedPreset!.distance * 0.621371;
        _observerHeightController.text = observerHeight.toStringAsFixed(1);
        _distanceController.text = distance.toStringAsFixed(1);
        _refractionFactorController.text =
            _selectedPreset!.refractionFactor.toStringAsFixed(2);
        _targetInputType = _selectedPreset!.targetInputType;
        _interveningSurfaceElevationController.text = '0.0';
        final targetHeight = _selectedPreset!.targetHeight;
        _targetHeightController.text = targetHeight == null
            ? ''
            : (_isMetric ? targetHeight : targetHeight * 3.28084)
                .toStringAsFixed(1);
        final baseElevation = _selectedPreset!.targetBaseElevation;
        _targetBaseElevationController.text =
            (_isMetric ? baseElevation : baseElevation * 3.28084)
                .toStringAsFixed(1);
      });

      // Calculate initial results
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _handleCalculate();
      });
    }
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
        _refractionFactorController.text =
            preset.refractionFactor.toStringAsFixed(2);
        _targetInputType = preset.targetInputType;
        _interveningSurfaceElevationController.text = '0.0';
        final targetHeight = preset.targetHeight;
        _targetHeightController.text = targetHeight == null
            ? ''
            : (_isMetric ? targetHeight : targetHeight * 3.28084)
                .toStringAsFixed(1);
        _targetBaseElevationController.text = (_isMetric
                ? preset.targetBaseElevation
                : preset.targetBaseElevation * 3.28084)
            .toStringAsFixed(1);
      }
    });

    // Always calculate, even for Custom Values
    WidgetsBinding.instance.addPostFrameCallback((_) {
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
      if (_interveningSurfaceElevationController.text.isNotEmpty) {
        final value = double.parse(_interveningSurfaceElevationController.text);
        final converted = isMetric ? value * 0.3048 : value * 3.28084;
        _interveningSurfaceElevationController.text =
            converted.toStringAsFixed(1);
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
      if (_targetBaseElevationController.text.isNotEmpty) {
        final double value = double.parse(_targetBaseElevationController.text);
        final double converted = isMetric ? value * 0.3048 : value * 3.28084;
        _targetBaseElevationController.text = converted.toStringAsFixed(1);
      }
      // Automatically calculate when units change
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _handleCalculate();
      });
    });
  }

  void _handleTargetInputTypeChanged(TargetInputType inputType) {
    setState(() {
      _targetInputType = inputType;
      if (inputType == TargetInputType.structure &&
          _targetBaseElevationController.text.isEmpty) {
        _targetBaseElevationController.text = '0';
      }
    });
  }

  void _handleCalculate() {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    // Get values from controllers
    final double observerHeight = double.parse(_observerHeightController.text);
    final double interveningSurfaceElevation =
        double.parse(_interveningSurfaceElevationController.text);
    final double distance = double.parse(_distanceController.text);
    final double refractionFactor =
        double.parse(_refractionFactorController.text);
    final double? enteredTargetHeight = _targetHeightController.text.isEmpty
        ? null
        : double.parse(_targetHeightController.text);
    final double targetBaseElevation = enteredTargetHeight != null &&
            _targetInputType == TargetInputType.structure
        ? double.tryParse(_targetBaseElevationController.text) ?? 0
        : 0;
    final double? targetTopElevation = enteredTargetHeight == null
        ? null
        : _targetInputType == TargetInputType.structure
            ? targetBaseElevation + enteredTargetHeight
            : enteredTargetHeight;

    // Pass values in their original units (meters/feet and km/miles)
    final result = CurvatureCalculator.calculate(
      observerHeight: observerHeight,
      interveningSurfaceElevation: interveningSurfaceElevation,
      distance: distance,
      refractionFactor: refractionFactor,
      targetHeight: targetTopElevation,
      targetBaseElevation: targetBaseElevation,
      isMetric: _isMetric,
    );

    setState(() {
      _result = result;
    });
  }

  @override
  void dispose() {
    _observerHeightController.dispose();
    _interveningSurfaceElevationController.dispose();
    _distanceController.dispose();
    _refractionFactorController.dispose();
    _targetHeightController.dispose();
    _targetBaseElevationController.dispose();
    super.dispose();
  }

  Widget _buildPresetSelector() {
    return PresetSelector(
      key: _presetSelectorKey,
      selectedPreset: _selectedPreset,
      onPresetChanged: _handlePresetChanged,
      isMetric: _isMetric,
      onMetricChanged: _handleMetricChanged,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Form(
      key: _formKey,
      child: LayoutBuilder(
        builder: (context, constraints) {
          final isWide =
              constraints.maxWidth > 900; // Breakpoint for wide screens
          final isMobile = constraints.maxWidth < 600; // Mobile breakpoint
          final targetHeight = double.tryParse(_targetHeightController.text);

          // Adjust padding based on screen size
          final contentPadding =
              isMobile ? const EdgeInsets.all(8.0) : const EdgeInsets.all(16.0);

          // Create a single instance of InputFields
          final inputFields = InputFields(
            observerHeightController: _observerHeightController,
            interveningSurfaceElevationController:
                _interveningSurfaceElevationController,
            distanceController: _distanceController,
            refractionFactorController: _refractionFactorController,
            targetHeightController: _targetHeightController,
            targetBaseElevationController: _targetBaseElevationController,
            targetInputType: _targetInputType,
            isMetric: _isMetric,
            onMetricChanged: _handleMetricChanged,
            onTargetInputTypeChanged: _handleTargetInputTypeChanged,
            onCalculate: _handleCalculate,
            showCalculateButton: true,
            isCustomPreset: _selectedPreset == null,
          );

          // Create a single instance of ResultsDisplay
          final resultsDisplay = ResultsDisplay(
            result: _result,
            isMetric: _isMetric,
            targetHeight: targetHeight,
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
                      _buildPresetSelector(),
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
                    targetHeight: targetHeight,
                    isMetric: _isMetric,
                    isStructureTarget:
                        _targetInputType == TargetInputType.structure,
                    presetName:
                        _selectedPreset?.name, // Pass null for Custom Values
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
                          _buildPresetSelector(),
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
                        targetHeight: targetHeight,
                        isMetric: _isMetric,
                        isStructureTarget:
                            _targetInputType == TargetInputType.structure,
                        presetName: _selectedPreset
                            ?.name, // Pass null for Custom Values
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
