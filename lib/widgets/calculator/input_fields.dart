import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../core/constants/range_limits.dart';
import '../../models/line_of_sight_preset.dart';
import '../common/info_icon.dart';
import 'input_help_dialog.dart';

class InputFields extends StatelessWidget {
  final TextEditingController observerHeightController;
  final TextEditingController interveningSurfaceElevationController;
  final TextEditingController distanceController;
  final TextEditingController refractionFactorController;
  final TextEditingController targetHeightController;
  final TextEditingController targetBaseElevationController;
  final TargetInputType targetInputType;
  final bool isMetric;
  final ValueChanged<bool> onMetricChanged;
  final ValueChanged<TargetInputType> onTargetInputTypeChanged;
  final VoidCallback onCalculate;
  final VoidCallback? onShare;
  final VoidCallback? onCompare;
  final bool showCalculateButton;
  final bool isCustomPreset;
  final bool? surfaceAboveSeaLevel;
  final ValueChanged<bool>? onSurfaceChanged;

  const InputFields({
    super.key,
    required this.observerHeightController,
    required this.interveningSurfaceElevationController,
    required this.distanceController,
    required this.refractionFactorController,
    required this.targetHeightController,
    required this.targetBaseElevationController,
    required this.targetInputType,
    required this.isMetric,
    required this.onMetricChanged,
    required this.onTargetInputTypeChanged,
    required this.onCalculate,
    this.onShare,
    this.onCompare,
    this.showCalculateButton = false,
    this.isCustomPreset = true,
    this.surfaceAboveSeaLevel,
    this.onSurfaceChanged,
  });

  @override
  Widget build(BuildContext context) => Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _buildInputField(
              controller: observerHeightController,
              label: 'Observer eye elevation',
              suffix: isMetric ? 'm AMSL' : 'ft AMSL',
              validator: _validateObserverHeight,
              enabled: isCustomPreset,
              infoKey: 'observer_height'),
          const SizedBox(height: 12),
          _buildInputField(
              controller: distanceController,
              label: 'Surface distance to target',
              suffix: isMetric ? 'km' : 'mi',
              validator: _validateDistance,
              enabled: isCustomPreset,
              infoKey: 'distance'),
          const SizedBox(height: 12),
          if (targetInputType == TargetInputType.structure) ...[
            _buildTargetBaseElevationField(),
            const SizedBox(height: 12),
          ],
          _buildTargetHeightField(),
          if (isCustomPreset)
            Row(children: [
              Expanded(child: _buildTargetInputTypeSelector()),
              const InputHelpButton(target: true)
            ]),
          const SizedBox(height: 12),
          _buildRefractionDropdown(),
          const SizedBox(height: 12),
          const Divider(),
          _SurfaceSection(
              key: const ValueKey('horizon_surface_section'),
              surfaceAboveSeaLevel: surfaceAboveSeaLevel,
              onSurfaceChanged: onSurfaceChanged,
              observerHeightController: observerHeightController,
              surfaceElevationController: interveningSurfaceElevationController,
              isMetric: isMetric,
              isEditable: isCustomPreset,
              onCalculate: onCalculate,
              validator: _validateInterveningSurfaceElevation),
          if (showCalculateButton) ...[
            const SizedBox(height: 16),
            Wrap(
                alignment: WrapAlignment.spaceBetween,
                spacing: 12,
                runSpacing: 8,
                children: [
                  ElevatedButton(
                      onPressed: onCalculate,
                      child: const Text('Calculate visibility')),
                  if (onShare != null)
                    TextButton.icon(
                        onPressed: onShare,
                        icon: const Icon(Icons.ios_share),
                        label: const Text('Share result')),
                  if (onCompare != null)
                    OutlinedButton.icon(
                        onPressed: onCompare,
                        icon: const Icon(Icons.table_chart_outlined),
                        label: const Text('Compare scenarios')),
                ]),
          ],
        ],
      );

  Widget _buildInputField({
    required TextEditingController controller,
    required String label,
    required String suffix,
    required String? Function(String?) validator,
    required String infoKey,
    bool enabled = true,
  }) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final isMobile = MediaQuery.sizeOf(context).width < 900;

        return Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            if (!isMobile)
              SizedBox(width: constraints.maxWidth * 0.45, child: Text(label)),
            Expanded(
              child: TextFormField(
                key: ValueKey(label),
                controller: controller,
                enabled: true,
                readOnly: !enabled,
                style: TextStyle(
                  color: Theme.of(context).colorScheme.onSurface,
                ),
                decoration: InputDecoration(
                  labelText: isMobile ? label : null,
                  suffixText: suffix,
                  border: const OutlineInputBorder(),
                  contentPadding: isMobile
                      ? const EdgeInsets.symmetric(horizontal: 8, vertical: 12)
                      : const EdgeInsets.symmetric(
                          horizontal: 12, vertical: 12),
                ),
                keyboardType:
                    const TextInputType.numberWithOptions(decimal: true),
                inputFormatters: [
                  FilteringTextInputFormatter.allow(RegExp(r'^\d*\.?\d*')),
                ],
                validator: validator,
                onFieldSubmitted: (_) => onCalculate(),
              ),
            ),
            const SizedBox(width: 8),
            SizedBox(
              width: 24,
              height: isMobile ? 40 : 48,
              child: Center(
                child: InfoIcon(
                  infoKey: infoKey,
                  size: 20,
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildTargetHeightField() {
    return _buildInputField(
      controller: targetHeightController,
      label: targetInputType == TargetInputType.elevation
          ? 'Target top elevation (optional)'
          : 'Height above base (optional)',
      suffix: targetInputType == TargetInputType.elevation
          ? (isMetric ? 'm AMSL' : 'ft AMSL')
          : (isMetric ? 'm' : 'ft'),
      validator: _validateTargetHeight,
      enabled: isCustomPreset,
      infoKey: 'target_height',
    );
  }

  Widget _buildTargetBaseElevationField() {
    return _buildInputField(
      controller: targetBaseElevationController,
      label: 'Base elevation',
      suffix: isMetric ? 'm AMSL' : 'ft AMSL',
      validator: _validateTargetBaseElevation,
      enabled: isCustomPreset,
      infoKey: 'target_base_elevation',
    );
  }

  Widget _buildTargetInputTypeSelector() => Align(
        alignment: Alignment.centerLeft,
        child: TextButton(
          key: const ValueKey('target_measurement_selector'),
          onPressed: () => onTargetInputTypeChanged(
              targetInputType == TargetInputType.elevation
                  ? TargetInputType.structure
                  : TargetInputType.elevation),
          child: Text(targetInputType == TargetInputType.elevation
              ? 'Use base elevation + height instead'
              : 'Use top elevation instead'),
        ),
      );

  Widget _buildRefractionDropdown() {
    return LayoutBuilder(
      builder: (context, constraints) {
        final isMobile = MediaQuery.sizeOf(context).width < 900;

        if (!isCustomPreset) {
          return Row(children: [
            const Expanded(child: Text('Refraction')),
            Text(refractionFactorController.text)
          ]);
        }
        return Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            if (!isMobile)
              SizedBox(
                  width: constraints.maxWidth * 0.45,
                  child: const Text('Refraction')),
            Expanded(
              child: SizedBox(
                height: 56,
                child: DropdownButtonFormField<String>(
                  isExpanded: true,
                  value: _getRefractionKey(refractionFactorController.text),
                  decoration: InputDecoration(
                    labelText: isMobile ? 'Refraction' : null,
                    border: const OutlineInputBorder(),
                    contentPadding: isMobile
                        ? const EdgeInsets.symmetric(
                            horizontal: 8, vertical: 12)
                        : const EdgeInsets.symmetric(
                            horizontal: 12, vertical: 12),
                  ),
                  items: const [
                    DropdownMenuItem(value: 'none', child: Text('None (1.00)')),
                    DropdownMenuItem(value: 'low', child: Text('Low (1.02)')),
                    DropdownMenuItem(
                        value: 'below_average',
                        child: Text('Below Avg (1.04)')),
                    DropdownMenuItem(
                        value: 'average', child: Text('Average (1.07)')),
                    DropdownMenuItem(
                        value: 'above_average',
                        child: Text('Above Avg (1.10)')),
                    DropdownMenuItem(value: 'high', child: Text('High (1.15)')),
                    DropdownMenuItem(
                        value: 'very_high', child: Text('Very High (1.20)')),
                    DropdownMenuItem(
                        value: 'extremely_high',
                        child: Text('Extremely High (1.25)')),
                  ],
                  onChanged: (value) {
                    if (value != null) {
                      refractionFactorController.text =
                          _getRefractionValue(value);
                    }
                  },
                ),
              ),
            ),
            const SizedBox(width: 8),
            SizedBox(
              width: 24,
              height: isMobile ? 40 : 48,
              child: Center(
                child: InfoIcon(
                  infoKey: 'refraction',
                  size: 20,
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  String _getRefractionKey(String value) {
    final double refraction = double.tryParse(value) ?? 1.07;
    switch (refraction.toStringAsFixed(2)) {
      case '1.00':
        return 'none';
      case '1.02':
        return 'low';
      case '1.04':
        return 'below_average';
      case '1.07':
        return 'average';
      case '1.10':
        return 'above_average';
      case '1.15':
        return 'high';
      case '1.20':
        return 'very_high';
      case '1.25':
        return 'extremely_high';
      default:
        // Find closest match
        final List<double> values = [
          1.00,
          1.02,
          1.04,
          1.07,
          1.10,
          1.15,
          1.20,
          1.25
        ];
        double closest = values.reduce(
            (a, b) => (a - refraction).abs() < (b - refraction).abs() ? a : b);
        return _getRefractionKey(closest.toString());
    }
  }

  String _getRefractionValue(String label) {
    switch (label) {
      case 'none':
        return '1.00';
      case 'low':
        return '1.02';
      case 'below_average':
        return '1.04';
      case 'average':
        return '1.07';
      case 'above_average':
        return '1.10';
      case 'high':
        return '1.15';
      case 'very_high':
        return '1.20';
      case 'extremely_high':
        return '1.25';
      default:
        return '1.07';
    }
  }

  String? _validateObserverHeight(String? value) {
    if (value == null || value.isEmpty) {
      return 'Please enter observer height';
    }
    final height = double.tryParse(value);
    if (height == null) {
      return 'Please enter a valid number';
    }
    if (height <= 0) {
      return 'Height must be greater than 0';
    }
    final maxHeight = isMetric
        ? RangeLimits.maxObserverHeight
        : RangeLimits.maxObserverHeight * 3.28084;
    if (height > maxHeight) {
      return 'Height must be less than ${maxHeight.toStringAsFixed(0)}${isMetric ? 'm' : 'ft'}';
    }
    return null;
  }

  String? _validateInterveningSurfaceElevation(String? value) {
    if (value == null || value.isEmpty) {
      return 'Please enter the intervening surface elevation';
    }
    final elevation = double.tryParse(value);
    if (elevation == null) return 'Please enter a valid number';
    if (elevation < 0) return 'Elevation cannot be negative';

    final observerElevation = double.tryParse(observerHeightController.text);
    if (observerElevation != null && elevation > observerElevation) {
      return 'Elevation cannot exceed observer eye elevation';
    }
    return null;
  }

  String? _validateDistance(String? value) {
    if (value == null || value.isEmpty) {
      return 'Please enter distance';
    }
    final distance = double.tryParse(value);
    if (distance == null) {
      return 'Please enter a valid number';
    }
    if (distance <= 0) {
      return 'Distance must be greater than 0';
    }
    final maxDist =
        isMetric ? RangeLimits.maxDistance : RangeLimits.maxDistance * 0.621371;
    if (distance > maxDist) {
      return 'Distance must be less than ${maxDist.toStringAsFixed(0)}${isMetric ? 'km' : 'mi'}';
    }
    return null;
  }

  String? _validateTargetHeight(String? value) {
    if (value == null || value.isEmpty) {
      return null; // Target height is optional
    }
    final height = double.tryParse(value);
    if (height == null) {
      return 'Please enter a valid number';
    }
    if (height < 0) {
      return 'Height cannot be negative';
    }

    // Convert input to meters if in imperial
    final heightInMeters = isMetric ? height : height / 3.28084;

    if (heightInMeters > RangeLimits.maxTargetHeight) {
      final maxDisplay = isMetric
          ? RangeLimits.maxTargetHeight
          : RangeLimits.maxTargetHeight * 3.28084;
      return 'Height must be less than ${maxDisplay.toStringAsFixed(0)}${isMetric ? 'm' : 'ft'}';
    }
    return null;
  }

  String? _validateTargetBaseElevation(String? value) {
    if (targetInputType != TargetInputType.structure) return null;
    if (targetHeightController.text.isEmpty) return null;
    if (value == null || value.isEmpty) {
      return 'Please enter the ground/base elevation';
    }
    final elevation = double.tryParse(value);
    if (elevation == null) return 'Please enter a valid number';
    if (elevation < 0) return 'Elevation cannot be negative';

    final elevationInMeters = isMetric ? elevation : elevation / 3.28084;
    if (elevationInMeters > RangeLimits.maxTargetHeight) {
      final maxDisplay = isMetric
          ? RangeLimits.maxTargetHeight
          : RangeLimits.maxTargetHeight * 3.28084;
      return 'Elevation must be less than ${maxDisplay.toStringAsFixed(0)}${isMetric ? 'm' : 'ft'}';
    }
    return null;
  }
}

class _SurfaceSection extends StatefulWidget {
  final TextEditingController observerHeightController;
  final TextEditingController surfaceElevationController;
  final bool isMetric;
  final bool isEditable;
  final bool? surfaceAboveSeaLevel;
  final ValueChanged<bool>? onSurfaceChanged;
  final VoidCallback onCalculate;
  final String? Function(String?) validator;

  const _SurfaceSection({
    super.key,
    required this.observerHeightController,
    required this.surfaceElevationController,
    required this.isMetric,
    required this.isEditable,
    this.surfaceAboveSeaLevel,
    this.onSurfaceChanged,
    required this.onCalculate,
    required this.validator,
  });

  @override
  State<_SurfaceSection> createState() => _SurfaceSectionState();
}

class _SurfaceSectionState extends State<_SurfaceSection> {
  bool _editorOpen = false;
  @override
  void initState() {
    super.initState();
    widget.observerHeightController.addListener(_refresh);
    widget.surfaceElevationController.addListener(_refresh);
  }

  void _refresh() {
    if (mounted) setState(() {});
  }

  @override
  void didUpdateWidget(_SurfaceSection oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.isEditable != widget.isEditable ||
        (oldWidget.surfaceAboveSeaLevel == true &&
            widget.surfaceAboveSeaLevel == false)) {
      _editorOpen = false;
    }
  }

  @override
  void dispose() {
    widget.observerHeightController.removeListener(_refresh);
    widget.surfaceElevationController.removeListener(_refresh);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final active =
        (double.tryParse(widget.surfaceElevationController.text) ?? 0) != 0;
    return Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
      Wrap(crossAxisAlignment: WrapCrossAlignment.center, children: [
        Text(active
            ? 'Intervening surface: ${widget.surfaceElevationController.text} ${widget.isMetric ? 'm' : 'ft'} AMSL'
            : 'Intervening surface: sea level'),
        if (widget.isEditable)
          TextButton(
              onPressed: () => setState(() => _editorOpen = !_editorOpen),
              child: Text(_editorOpen
                  ? 'Close surface settings'
                  : active
                      ? 'Edit'
                      : 'Change for an elevated lake')),
        const InputHelpButton(target: false),
        if (active && widget.isEditable)
          TextButton(
              onPressed: () {
                widget.surfaceElevationController.text = '0';
                widget.onSurfaceChanged?.call(false);
                setState(() => _editorOpen = false);
              },
              child: const Text('Reset to sea level')),
      ]),
      if (!_editorOpen)
        FormField<String>(
          validator: (_) =>
              widget.validator(widget.surfaceElevationController.text),
          builder: (state) => state.hasError
              ? Text(state.errorText!,
                  style: TextStyle(color: Theme.of(context).colorScheme.error))
              : const SizedBox.shrink(),
        ),
      if (_editorOpen && widget.isEditable) ...[
        TextFormField(
            controller: widget.surfaceElevationController,
            decoration: InputDecoration(
                labelText: 'Horizon surface elevation',
                suffixText: widget.isMetric ? 'm AMSL' : 'ft AMSL',
                border: const OutlineInputBorder()),
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
            inputFormatters: [
              FilteringTextInputFormatter.allow(RegExp(r'^\d*\.?\d*'))
            ],
            validator: widget.validator,
            onChanged: (_) => widget.onSurfaceChanged?.call(true),
            onFieldSubmitted: (_) => widget.onCalculate()),
        const SizedBox(height: 8),
        _derivedHeightSummary(context),
      ],
    ]);
  }

  Widget _derivedHeightSummary(BuildContext context) {
    final observer = double.tryParse(widget.observerHeightController.text) ?? 0;
    final surface =
        double.tryParse(widget.surfaceElevationController.text) ?? 0;
    final height = observer - surface;
    final unit = widget.isMetric ? 'm' : 'ft';

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(10),
      ),
      child: Row(
        children: [
          const Icon(Icons.straighten_outlined, size: 20),
          const SizedBox(width: 10),
          const Expanded(
            child: Text(
              'Eye height above surface (h1)',
              style: TextStyle(fontWeight: FontWeight.w600),
            ),
          ),
          Text(
            '${height.toStringAsFixed(1)} $unit',
            style: const TextStyle(fontWeight: FontWeight.w700),
          ),
        ],
      ),
    );
  }
}
