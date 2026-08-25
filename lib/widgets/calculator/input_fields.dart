import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../core/constants/range_limits.dart';
import '../../models/line_of_sight_preset.dart';
import '../common/info_icon.dart';

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
  final bool showCalculateButton;
  final bool isCustomPreset;

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
    this.showCalculateButton = false,
    this.isCustomPreset = true,
  });

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final isNarrow = constraints.maxWidth < 600;
        final observerField = _buildInputField(
          controller: observerHeightController,
          label: 'Observer eye elevation',
          suffix: isMetric ? 'm AMSL' : 'ft AMSL',
          validator: _validateObserverHeight,
          enabled: isCustomPreset,
          infoKey: 'observer_height',
        );
        final distanceField = _buildInputField(
          controller: distanceController,
          label: 'Distance to target',
          suffix: isMetric ? 'km' : 'mi',
          validator: _validateDistance,
          enabled: isCustomPreset,
          infoKey: 'distance',
        );

        return Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _buildSectionHeader(
              context,
              'Observer and viewing path',
              'Start with where the viewer is and how far away the target is.',
            ),
            const SizedBox(height: 16),
            _buildResponsivePair(
              isNarrow: isNarrow,
              first: observerField,
              second: distanceField,
            ),
            const SizedBox(height: 24),
            const Divider(),
            const SizedBox(height: 16),
            _buildSectionHeader(
              context,
              'Horizon-forming surface',
              'Choose the water or broadly level surface between observer and target.',
            ),
            const SizedBox(height: 16),
            _SurfaceSection(
              observerHeightController: observerHeightController,
              surfaceElevationController: interveningSurfaceElevationController,
              isMetric: isMetric,
              isEditable: isCustomPreset,
              onCalculate: onCalculate,
              validator: _validateInterveningSurfaceElevation,
            ),
            const SizedBox(height: 24),
            const Divider(),
            const SizedBox(height: 16),
            _buildSectionHeader(
              context,
              'Target',
              'Optionally describe the target to show how much remains visible.',
            ),
            if (isCustomPreset) ...[
              const SizedBox(height: 16),
              _buildTargetInputTypeSelector(),
            ],
            const SizedBox(height: 16),
            _buildResponsivePair(
              isNarrow: isNarrow,
              first: _buildTargetHeightField(),
              second: targetInputType == TargetInputType.structure
                  ? _buildTargetBaseElevationField()
                  : null,
            ),
            const SizedBox(height: 24),
            const Divider(),
            const SizedBox(height: 16),
            _buildSectionHeader(
              context,
              'Atmosphere',
              'Choose how strongly atmospheric refraction bends the line of sight.',
            ),
            const SizedBox(height: 16),
            _buildRefractionDropdown(),
            if (showCalculateButton) ...[
              const SizedBox(height: 24),
              Align(
                alignment: Alignment.centerRight,
                child: ElevatedButton(
                  onPressed: onCalculate,
                  child: const Text('Calculate visibility'),
                ),
              ),
            ],
          ],
        );
      },
    );
  }

  Widget _buildSectionHeader(
    BuildContext context,
    String title,
    String description,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w700,
              ),
        ),
        const SizedBox(height: 4),
        Text(description, style: Theme.of(context).textTheme.bodySmall),
      ],
    );
  }

  Widget _buildResponsivePair({
    required bool isNarrow,
    required Widget first,
    Widget? second,
  }) {
    if (isNarrow) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          first,
          if (second != null) ...[
            const SizedBox(height: 12),
            second,
          ],
        ],
      );
    }

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(child: first),
        const SizedBox(width: 16),
        Expanded(child: second ?? const SizedBox.shrink()),
      ],
    );
  }

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
        final isMobile = constraints.maxWidth < 600;

        return Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Expanded(
              child: TextFormField(
                controller: controller,
                enabled: true,
                readOnly: !enabled,
                style: TextStyle(
                  color: Theme.of(context).colorScheme.onSurface,
                ),
                decoration: InputDecoration(
                  labelText: label,
                  suffixText: suffix,
                  border: const OutlineInputBorder(),
                  contentPadding: isMobile
                      ? const EdgeInsets.symmetric(horizontal: 8, vertical: 12)
                      : const EdgeInsets.symmetric(
                          horizontal: 12, vertical: 16),
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
          : 'Structure height (optional)',
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

  Widget _buildTargetInputTypeSelector() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Target measurement',
          style: TextStyle(fontWeight: FontWeight.w600),
        ),
        const SizedBox(height: 6),
        SegmentedButton<TargetInputType>(
          key: const ValueKey('target_measurement_selector'),
          showSelectedIcon: false,
          expandedInsets: EdgeInsets.zero,
          segments: const [
            ButtonSegment(
              value: TargetInputType.elevation,
              label: Text('Top elevation', textAlign: TextAlign.center),
            ),
            ButtonSegment(
              value: TargetInputType.structure,
              label: Text(
                'Structure height + base elevation',
                textAlign: TextAlign.center,
              ),
            ),
          ],
          selected: {targetInputType},
          onSelectionChanged: isCustomPreset
              ? (values) => onTargetInputTypeChanged(values.first)
              : null,
        ),
      ],
    );
  }

  Widget _buildRefractionDropdown() {
    return LayoutBuilder(
      builder: (context, constraints) {
        final isMobile = constraints.maxWidth < 600;

        return Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Expanded(
              child: SizedBox(
                height: isMobile ? 60 : 68,
                child: DropdownButtonFormField<String>(
                  isExpanded: true,
                  value: _getRefractionKey(refractionFactorController.text),
                  decoration: InputDecoration(
                    labelText: 'Refraction',
                    border: const OutlineInputBorder(),
                    contentPadding: isMobile
                        ? const EdgeInsets.symmetric(
                            horizontal: 8, vertical: 12)
                        : const EdgeInsets.symmetric(
                            horizontal: 12, vertical: 16),
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
  final VoidCallback onCalculate;
  final String? Function(String?) validator;

  const _SurfaceSection({
    required this.observerHeightController,
    required this.surfaceElevationController,
    required this.isMetric,
    required this.isEditable,
    required this.onCalculate,
    required this.validator,
  });

  @override
  State<_SurfaceSection> createState() => _SurfaceSectionState();
}

class _SurfaceSectionState extends State<_SurfaceSection> {
  bool _usesSurfaceAboveSeaLevel = false;
  late String _savedSurfaceElevation;

  @override
  void initState() {
    super.initState();
    _savedSurfaceElevation = widget.surfaceElevationController.text;
    widget.surfaceElevationController.text = '0.0';
    widget.observerHeightController.addListener(_refreshDerivedHeight);
    widget.surfaceElevationController.addListener(_refreshDerivedHeight);
  }

  @override
  void didUpdateWidget(_SurfaceSection oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.observerHeightController != widget.observerHeightController) {
      oldWidget.observerHeightController.removeListener(_refreshDerivedHeight);
      widget.observerHeightController.addListener(_refreshDerivedHeight);
    }
    if (oldWidget.surfaceElevationController !=
        widget.surfaceElevationController) {
      oldWidget.surfaceElevationController
          .removeListener(_refreshDerivedHeight);
      widget.surfaceElevationController.addListener(_refreshDerivedHeight);
    }
    if (!widget.isEditable && _usesSurfaceAboveSeaLevel) {
      _savedSurfaceElevation = widget.surfaceElevationController.text;
      widget.surfaceElevationController.text = '0.0';
      _usesSurfaceAboveSeaLevel = false;
    }
  }

  @override
  void dispose() {
    widget.observerHeightController.removeListener(_refreshDerivedHeight);
    widget.surfaceElevationController.removeListener(_refreshDerivedHeight);
    super.dispose();
  }

  void _refreshDerivedHeight() {
    if (mounted) setState(() {});
  }

  void _selectSurface(bool aboveSeaLevel) {
    if (!widget.isEditable || aboveSeaLevel == _usesSurfaceAboveSeaLevel) {
      return;
    }

    setState(() {
      if (aboveSeaLevel) {
        widget.surfaceElevationController.text = _savedSurfaceElevation;
        _usesSurfaceAboveSeaLevel = true;
      } else {
        _savedSurfaceElevation = widget.surfaceElevationController.text;
        widget.surfaceElevationController.text = '0.0';
        _usesSurfaceAboveSeaLevel = false;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final isNarrow = constraints.maxWidth < 600;
        final options = [
          _surfaceOption(
            context,
            selected: !_usesSurfaceAboveSeaLevel,
            title: 'Sea level',
            description:
                'Use 0 ${widget.isMetric ? 'm' : 'ft'} AMSL for the usual sea-level calculation.',
            onTap: () => _selectSurface(false),
          ),
          _surfaceOption(
            context,
            selected: _usesSurfaceAboveSeaLevel,
            title: 'Surface above sea level',
            description:
                'Use the elevation of a lake or other broadly level surface.',
            onTap: () => _selectSurface(true),
          ),
        ];

        return Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            if (isNarrow)
              Column(
                children: [
                  options.first,
                  const SizedBox(height: 12),
                  options.last,
                ],
              )
            else
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(child: options.first),
                  const SizedBox(width: 12),
                  Expanded(child: options.last),
                ],
              ),
            if (_usesSurfaceAboveSeaLevel) ...[
              const SizedBox(height: 16),
              Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Expanded(
                    child: TextFormField(
                      controller: widget.surfaceElevationController,
                      enabled: widget.isEditable,
                      decoration: InputDecoration(
                        labelText: 'Horizon surface elevation',
                        suffixText: widget.isMetric ? 'm AMSL' : 'ft AMSL',
                        border: const OutlineInputBorder(),
                      ),
                      keyboardType: const TextInputType.numberWithOptions(
                        decimal: true,
                      ),
                      inputFormatters: [
                        FilteringTextInputFormatter.allow(
                          RegExp(r'^\d*\.?\d*'),
                        ),
                      ],
                      validator: widget.validator,
                      onFieldSubmitted: (_) => widget.onCalculate(),
                    ),
                  ),
                  const SizedBox(width: 8),
                  const InfoIcon(
                    infoKey: 'intervening_surface_elevation',
                    size: 20,
                  ),
                ],
              ),
              const SizedBox(height: 12),
              _derivedHeightSummary(context),
            ],
          ],
        );
      },
    );
  }

  Widget _surfaceOption(
    BuildContext context, {
    required bool selected,
    required String title,
    required String description,
    required VoidCallback onTap,
  }) {
    final colors = Theme.of(context).colorScheme;
    return Material(
      color: selected
          ? colors.primaryContainer.withValues(alpha: 0.35)
          : colors.surface,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(
          color: selected ? colors.primary : colors.outlineVariant,
          width: selected ? 2 : 1,
        ),
      ),
      child: InkWell(
        onTap: widget.isEditable ? onTap : null,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(14),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Radio<bool>(
                value: true,
                groupValue: selected,
                onChanged: widget.isEditable ? (_) => onTap() : null,
                visualDensity: VisualDensity.compact,
              ),
              const SizedBox(width: 4),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: const TextStyle(fontWeight: FontWeight.w700),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      description,
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
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
