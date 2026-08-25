import 'package:flutter/material.dart';

import '../../models/line_of_sight_preset.dart';
import '../../services/models/calculation_result.dart';
import 'diagram_display.dart';

class ShareResultDialog extends StatelessWidget {
  final String scenarioName;
  final String observerHeight;
  final String surfaceElevation;
  final String distance;
  final String refractionFactor;
  final String targetHeight;
  final String targetBaseElevation;
  final TargetInputType targetInputType;
  final CalculationResult result;
  final bool isMetric;

  const ShareResultDialog({
    super.key,
    required this.scenarioName,
    required this.observerHeight,
    required this.surfaceElevation,
    required this.distance,
    required this.refractionFactor,
    required this.targetHeight,
    required this.targetBaseElevation,
    required this.targetInputType,
    required this.result,
    required this.isMetric,
  });

  String get _heightUnit => isMetric ? 'm' : 'ft';
  String get _distanceUnit => isMetric ? 'km' : 'mi';

  String _formatDistance(double? value) {
    if (value == null) return 'N/A';
    final displayValue = isMetric ? value : value * 0.621371;
    return '${displayValue.toStringAsFixed(2)} $_distanceUnit';
  }

  String _formatHeight(double? value) {
    if (value == null) return 'N/A';
    final displayValue = isMetric ? value * 1000 : value * 3280.84;
    return '${displayValue.toStringAsFixed(1)} $_heightUnit';
  }

  List<({String label, String value})> get _inputRows {
    final rows = <({String label, String value})>[
      (
        label: 'Observer eye elevation',
        value: '$observerHeight $_heightUnit AMSL',
      ),
      (label: 'Distance to target', value: '$distance $_distanceUnit'),
      (
        label: 'Horizon-forming surface',
        value: double.tryParse(surfaceElevation) == 0
            ? 'Sea level'
            : '$surfaceElevation $_heightUnit AMSL',
      ),
      (label: 'Refraction factor', value: refractionFactor),
    ];

    if (targetHeight.isNotEmpty) {
      if (targetInputType == TargetInputType.structure) {
        rows.add((
          label: 'Structure height',
          value: '$targetHeight $_heightUnit',
        ));
        rows.add((
          label: 'Target base elevation',
          value: '$targetBaseElevation $_heightUnit AMSL',
        ));
      } else {
        rows.add((
          label: 'Target top elevation',
          value: '$targetHeight $_heightUnit AMSL',
        ));
      }
    }

    return rows;
  }

  List<({String label, String value})> get _resultRows {
    final rows = <({String label, String value})>[
      (
        label: 'Distance to horizon',
        value: _formatDistance(result.horizonDistance),
      ),
      (
        label: 'Horizon dip angle',
        value: '${result.dipAngle?.toStringAsFixed(2) ?? 'N/A'}°',
      ),
      (label: 'Hidden height', value: _formatHeight(result.hiddenHeight)),
    ];

    if (targetHeight.isNotEmpty) {
      rows.add((
        label: 'Visible height',
        value: _formatHeight(result.visibleTargetHeight),
      ));
    }

    return rows;
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isNarrow = MediaQuery.sizeOf(context).width < 720;
    final headingText = Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Beyond Horizon Calculator',
          style: theme.textTheme.headlineSmall?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          scenarioName,
          style: theme.textTheme.titleMedium?.copyWith(
            color: theme.colorScheme.primary,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
    final globe = SizedBox.square(
      dimension: isNarrow ? 96 : 116,
      child: Image.asset(
        'assets/images/globe_earth.png',
        key: const ValueKey('share_result_globe'),
        fit: BoxFit.contain,
        filterQuality: FilterQuality.high,
        semanticLabel: 'Earth',
      ),
    );
    final titleBlock = isNarrow
        ? Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              headingText,
              const SizedBox(height: 12),
              Align(alignment: Alignment.center, child: globe),
            ],
          )
        : SizedBox(
            height: 220,
            child: Stack(
              children: [
                Align(alignment: Alignment.topLeft, child: headingText),
                Align(alignment: Alignment.bottomCenter, child: globe),
              ],
            ),
          );
    final diagram = Container(
      key: const ValueKey('share_result_diagram'),
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceContainerLowest,
        border: Border.all(color: theme.colorScheme.outlineVariant),
        borderRadius: BorderRadius.circular(12),
      ),
      child: DiagramDisplay(
        result: result,
        targetHeight: double.tryParse(targetHeight),
        isMetric: isMetric,
        isStructureTarget: targetInputType == TargetInputType.structure,
        presetName: scenarioName == 'My own values' ? null : scenarioName,
        compact: true,
      ),
    );
    final closeButton = IconButton(
      tooltip: 'Close',
      onPressed: () => Navigator.of(context).pop(),
      icon: const Icon(Icons.close),
    );

    return Dialog(
      key: const ValueKey('share_result_dialog'),
      insetPadding: const EdgeInsets.all(16),
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 820),
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              if (isNarrow) ...[
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(child: titleBlock),
                    closeButton,
                  ],
                ),
                const SizedBox(height: 12),
                diagram,
              ] else
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(flex: 4, child: titleBlock),
                    const SizedBox(width: 16),
                    Expanded(flex: 5, child: diagram),
                    closeButton,
                  ],
                ),
              const SizedBox(height: 16),
              if (isNarrow) ...[
                _ShareSection(title: 'Inputs', rows: _inputRows),
                const SizedBox(height: 12),
                _ShareSection(
                  title: 'Results',
                  rows: _resultRows,
                  emphasizeValues: true,
                ),
              ] else
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: _ShareSection(title: 'Inputs', rows: _inputRows),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: _ShareSection(
                        title: 'Results',
                        rows: _resultRows,
                        emphasizeValues: true,
                      ),
                    ),
                  ],
                ),
              const SizedBox(height: 14),
              Text(
                'beyondhorizoncalc.com',
                textAlign: TextAlign.right,
                style: theme.textTheme.bodySmall?.copyWith(
                  color: theme.colorScheme.primary,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ShareSection extends StatelessWidget {
  final String title;
  final List<({String label, String value})> rows;
  final bool emphasizeValues;

  const _ShareSection({
    required this.title,
    required this.rows,
    this.emphasizeValues = false,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceContainerLow,
        border: Border.all(color: theme.colorScheme.outlineVariant),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            title,
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          for (var index = 0; index < rows.length; index++) ...[
            if (index > 0) const Divider(height: 14),
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Text(
                    rows[index].label,
                    style: theme.textTheme.bodySmall,
                  ),
                ),
                const SizedBox(width: 12),
                Flexible(
                  child: Text(
                    rows[index].value,
                    textAlign: TextAlign.right,
                    style: theme.textTheme.bodyMedium?.copyWith(
                      fontWeight:
                          emphasizeValues ? FontWeight.bold : FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }
}
