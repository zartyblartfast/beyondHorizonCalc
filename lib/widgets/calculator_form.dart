import 'package:flutter/material.dart';
import '../services/scenario_comparison.dart';
import 'calculator/comparison_dialog.dart';
import 'package:flutter/foundation.dart';
import '../services/custom_scenario_store.dart';
import '../services/custom_scenario_storage.dart';
import '../services/curvature_calculator.dart';
import '../services/models/calculation_result.dart';
import '../models/line_of_sight_preset.dart';
import 'calculator/preset_selector.dart';
import 'calculator/input_fields.dart';
import 'calculator/results_display.dart';
import 'calculator/diagram_display.dart';
import 'calculator/share_result_dialog.dart';

class CalculatorForm extends StatefulWidget {
  const CalculatorForm({super.key, this.scenarioStore});

  final CustomScenarioStore? scenarioStore;

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
  // Preserve the surface section and its controllers across responsive layouts.
  var _inputFieldsKey = GlobalKey();

  late final CustomScenarioStore _scenarioStore;
  Map<String, Object>? _savedCustom;
  bool _customRestored = false;
  String _otherTargetHeight = '';
  String _customDraftOtherTarget = '';
  Map<String, Object>? _customDraft;
  bool _surfaceAboveSeaLevel = false;

  bool _isMetric = true;
  TargetInputType _targetInputType = TargetInputType.elevation;
  LineOfSightPreset? _selectedPreset;
  CalculationResult? _result;
  bool _inputsDirty = false;
  bool _hasCalculated = false;
  // Keep display metadata with the last successful result while inputs change.
  bool _resultIsMetric = true;
  double? _resultTargetHeight;
  TargetInputType _resultTargetInputType = TargetInputType.elevation;
  String? _resultPresetName;

  @override
  void initState() {
    super.initState();
    _scenarioStore = widget.scenarioStore ?? browserCustomScenarioStore();
    _savedCustom = _scenarioStore.load();
    for (final controller in [
      _observerHeightController,
      _interveningSurfaceElevationController,
      _distanceController,
      _refractionFactorController,
      _targetHeightController,
      _targetBaseElevationController,
    ]) {
      var previousText = controller.text;
      controller.addListener(() {
        if (controller.text == previousText) return;
        previousText = controller.text;
        _markInputsDirty();
      });
    }
    _initializeForm();
  }

  void _markInputsDirty() {
    if (!_hasCalculated || _inputsDirty) return;
    setState(() => _inputsDirty = true);
  }

  Future<void> _initializeForm() async {
    // Initialize with empty result to avoid null errors
    _result = const CalculationResult();

    if (_savedCustom != null) {
      _restoreCustom(_savedCustom!);
      WidgetsBinding.instance
          .addPostFrameCallback((_) => _handleCalculate(saveCustom: false));
      return;
    }

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
        _interveningSurfaceElevationController.text = (_isMetric
                ? _selectedPreset!.interveningSurfaceElevation
                : _selectedPreset!.interveningSurfaceElevation * 3.28084)
            .toStringAsFixed(1);
        _surfaceAboveSeaLevel =
            _selectedPreset!.interveningSurfaceElevation != 0;
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

  void _restoreCustom(Map<String, Object> saved) {
    _selectedPreset = null;
    _isMetric = saved['isMetric'] as bool;
    _targetInputType =
        TargetInputType.values.byName(saved['targetInputType'] as String);
    _surfaceAboveSeaLevel = saved['surfaceAboveSeaLevel'] as bool;
    _observerHeightController.text = saved['observerHeight'] as String;
    _interveningSurfaceElevationController.text =
        saved['surfaceElevation'] as String;
    _distanceController.text = saved['distance'] as String;
    _refractionFactorController.text = saved['refractionFactor'] as String;
    _targetHeightController.text = saved['targetHeight'] as String;
    _targetBaseElevationController.text =
        saved['targetBaseElevation'] as String;
    _customRestored = true;
  }

  void _handlePresetChanged(LineOfSightPreset? preset,
      {bool copyExample = false}) {
    if (_selectedPreset == null && preset != null) {
      _customDraft = _snapshot();
      _customDraftOtherTarget = _otherTargetHeight;
    }
    _markInputsDirty();
    setState(() {
      _otherTargetHeight = '';
      _selectedPreset = preset;
      _customRestored = false;
      if (preset == null && !copyExample) {
        final own = _customDraft ?? _savedCustom;
        if (own != null) {
          _restoreCustom(own);
          if (identical(own, _customDraft)) {
            _otherTargetHeight = _customDraftOtherTarget;
          }
          _customRestored =
              _savedCustom != null && mapEquals(own, _savedCustom);
        } else {
          _resetWorkingValues();
        }
      }
      if (preset != null) {
        _surfaceAboveSeaLevel = false;
        final observerHeight =
            _isMetric ? preset.observerHeight : preset.observerHeight * 3.28084;
        final distance =
            _isMetric ? preset.distance : preset.distance * 0.621371;
        _observerHeightController.text = observerHeight.toStringAsFixed(1);
        _distanceController.text = distance.toStringAsFixed(1);
        _refractionFactorController.text =
            preset.refractionFactor.toStringAsFixed(2);
        _targetInputType = preset.targetInputType;
        _interveningSurfaceElevationController.text = (_isMetric
                ? _selectedPreset!.interveningSurfaceElevation
                : _selectedPreset!.interveningSurfaceElevation * 3.28084)
            .toStringAsFixed(1);
        _surfaceAboveSeaLevel =
            _selectedPreset!.interveningSurfaceElevation != 0;
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

    // Mode changes recalculate for display, but do not replace saved inputs.
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_observerHeightController.text.isNotEmpty &&
          _distanceController.text.isNotEmpty) {
        _handleCalculate(saveCustom: false);
      }
    });
  }

  void _handleMetricChanged(bool isMetric) {
    if (isMetric == _isMetric) return;
    _markInputsDirty();

    setState(() {
      _isMetric = isMetric;
      // Leave incomplete text for validation instead of throwing on unit change.
      for (final controller in [
        _observerHeightController,
        _interveningSurfaceElevationController,
        _targetHeightController,
        _targetBaseElevationController,
      ]) {
        final value = double.tryParse(controller.text);
        if (value == null) continue;
        final converted = isMetric ? value * 0.3048 : value * 3.28084;
        controller.text = converted.toStringAsFixed(1);
      }
      final distance = double.tryParse(_distanceController.text);
      if (distance != null) {
        final converted = isMetric ? distance * 1.60934 : distance * 0.621371;
        _distanceController.text = converted.toStringAsFixed(1);
      }
      final other = double.tryParse(_otherTargetHeight);
      if (other != null) {
        _otherTargetHeight =
            (isMetric ? other * 0.3048 : other * 3.28084).toStringAsFixed(1);
      }
      // Automatically calculate when units change
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _handleCalculate();
      });
    });
  }

  void _handleTargetInputTypeChanged(TargetInputType inputType) {
    if (inputType == _targetInputType) return;
    _markInputsDirty();
    setState(() {
      final previous = _targetHeightController.text;
      _targetHeightController.text = _otherTargetHeight;
      _otherTargetHeight = previous;
      _targetInputType = inputType;
      if (inputType == TargetInputType.structure &&
          _targetBaseElevationController.text.isEmpty) {
        _targetBaseElevationController.text = '0';
      }
    });
  }

  bool _handleCalculate({bool saveCustom = true}) {
    if (!mounted || !(_formKey.currentState?.validate() ?? false)) {
      return false;
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
      _resultIsMetric = _isMetric;
      _resultTargetHeight = enteredTargetHeight;
      _resultTargetInputType = _targetInputType;
      _resultPresetName = _selectedPreset?.name;
      _hasCalculated = true;
      _inputsDirty = false;
    });
    if (saveCustom && _selectedPreset == null) {
      final snapshot = <String, Object>{
        'version': 1,
        'isMetric': _isMetric,
        'targetInputType': _targetInputType.name,
        'surfaceAboveSeaLevel': _surfaceAboveSeaLevel,
        'observerHeight': _observerHeightController.text,
        'surfaceElevation': _interveningSurfaceElevationController.text,
        'distance': _distanceController.text,
        'refractionFactor': _refractionFactorController.text,
        'targetHeight': _targetHeightController.text,
        'targetBaseElevation': _targetBaseElevationController.text,
      };
      if (_scenarioStore.save(snapshot)) {
        _savedCustom = snapshot;
      }
    }
    return true;
  }

  void _showComparison() {
    if (!(_formKey.currentState?.validate() ?? false)) return;
    // Snapshot current edits, not an earlier result. Never write to controllers
    // or save/recalculate the main scenario from the comparison window.
    final entered = double.tryParse(_targetHeightController.text);
    final base =
        entered != null && _targetInputType == TargetInputType.structure
            ? double.parse(_targetBaseElevationController.text)
            : 0.0;
    final inputs = ComparisonInputs(
      observerElevation: double.parse(_observerHeightController.text),
      surfaceElevation:
          double.parse(_interveningSurfaceElevationController.text),
      distance: double.parse(_distanceController.text),
      refractionFactor: double.parse(_refractionFactorController.text),
      isMetric: _isMetric,
      targetBase: base,
      targetTop: entered == null ? null : base + entered,
    );
    showDialog<void>(
        context: context, builder: (_) => ComparisonDialog(inputs: inputs));
  }

  void _showShareResult() {
    if (!_handleCalculate()) return;
    final result = _result;
    if (result == null) return;

    // Capture inputs now, not when the dialog route later builds.
    final dialog = ShareResultDialog(
      scenarioName: _selectedPreset?.name ?? 'My own values',
      observerHeight: _observerHeightController.text,
      surfaceElevation: _interveningSurfaceElevationController.text,
      distance: _distanceController.text,
      refractionFactor: _refractionFactorController.text,
      targetHeight: _targetHeightController.text,
      targetBaseElevation: _targetBaseElevationController.text,
      targetInputType: _targetInputType,
      result: result,
      isMetric: _isMetric,
    );
    showDialog<void>(
      context: context,
      builder: (context) => dialog,
    );
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

  Map<String, Object> _snapshot() => {
        'version': 1,
        'isMetric': _isMetric,
        'targetInputType': _targetInputType.name,
        'surfaceAboveSeaLevel': _surfaceAboveSeaLevel,
        'observerHeight': _observerHeightController.text,
        'surfaceElevation': _interveningSurfaceElevationController.text,
        'distance': _distanceController.text,
        'refractionFactor': _refractionFactorController.text,
        'targetHeight': _targetHeightController.text,
        'targetBaseElevation': _targetBaseElevationController.text,
      };

  void _resetWorkingValues() {
    _inputFieldsKey = GlobalKey();
    _observerHeightController.clear();
    _distanceController.clear();
    _targetHeightController.clear();
    _targetBaseElevationController.text = '0';
    _interveningSurfaceElevationController.text = '0';
    _refractionFactorController.text = '1.07';
    _targetInputType = TargetInputType.elevation;
    _otherTargetHeight = '';
    _surfaceAboveSeaLevel = false;
    _customRestored = false;
    _result = null;
    _hasCalculated = false;
    _inputsDirty = false;
  }

  void _clearSavedCustom() {
    if (_scenarioStore.clear()) {
      setState(() {
        _savedCustom = null;
        _customRestored = false;
      });
    } else {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
        content: Text('Saved values could not be cleared in this browser.'),
      ));
    }
  }

  Widget _buildPresetSelector() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        if (_customRestored) ...[
          Text('Previous custom values restored',
              style: Theme.of(context).textTheme.bodySmall),
          Align(
            alignment: Alignment.centerLeft,
            child: TextButton(
              onPressed: _clearSavedCustom,
              child: const Text('Clear saved values'),
            ),
          ),
        ],
        if (_selectedPreset == null)
          Align(
              alignment: Alignment.centerRight,
              child: TextButton(
                onPressed: () => setState(() {
                  _customDraft = null;
                  _resetWorkingValues();
                }),
                child: const Text('Start fresh'),
              )),
        PresetSelector(
          key: _presetSelectorKey,
          selectedPreset: _selectedPreset,
          onPresetChanged: _handlePresetChanged,
          onEditValues: () => _handlePresetChanged(null, copyExample: true),
          isMetric: _isMetric,
          onMetricChanged: _handleMetricChanged,
        ),
      ],
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
          final targetHeight = _resultTargetHeight;

          // Adjust padding based on screen size
          final contentPadding =
              isMobile ? const EdgeInsets.all(8.0) : const EdgeInsets.all(16.0);

          // Create a single instance of InputFields
          final inputFields = InputFields(
            key: _inputFieldsKey,
            surfaceAboveSeaLevel: _surfaceAboveSeaLevel,
            onSurfaceChanged: (above) {
              _markInputsDirty();
              setState(() => _surfaceAboveSeaLevel = above);
            },
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
            onShare: _observerHeightController.text.isEmpty
                ? null
                : _showShareResult,
            onCompare:
                _observerHeightController.text.isEmpty ? null : _showComparison,
            showCalculateButton: true,
            isCustomPreset: _selectedPreset == null,
          );

          // Create a single instance of ResultsDisplay
          final resultsDisplay = Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              if (_inputsDirty)
                Text('Inputs changed — recalculate',
                    style: Theme.of(context).textTheme.bodySmall),
              ResultsDisplay(
                result: _result,
                isMetric: _resultIsMetric,
                targetHeight: targetHeight,
              ),
            ],
          );

          final inputsPanel = Card(
              child: Padding(
                  padding: contentPadding,
                  child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        _buildPresetSelector(),
                        const SizedBox(height: 16),
                        inputFields,
                      ])));
          final answerPanel = Card(
              child: Padding(
                  padding: contentPadding,
                  child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        resultsDisplay,
                        if (_result != null)
                          DiagramDisplay(
                              result: _result,
                              targetHeight: targetHeight,
                              isMetric: _resultIsMetric,
                              isStructureTarget: _resultTargetInputType ==
                                  TargetInputType.structure,
                              presetName: _resultPresetName),
                      ])));
          final content = isWide
              ? Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  Expanded(child: inputsPanel),
                  const SizedBox(width: 16),
                  Expanded(child: answerPanel)
                ])
              : Column(children: [
                  inputsPanel,
                  const SizedBox(height: 8),
                  answerPanel
                ]);

          return content;
        },
      ),
    );
  }
}
