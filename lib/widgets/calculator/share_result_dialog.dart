import 'dart:typed_data';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';

import '../../models/line_of_sight_preset.dart';
import '../../services/models/calculation_result.dart';
import '../../services/share_image_export.dart';
import 'diagram_display.dart';

class ShareResultDialog extends StatefulWidget {
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
  final Future<void> Function(Uint8List bytes)? onCopyPng;
  final void Function(Uint8List bytes, String filename)? onDownloadPng;

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
    this.onCopyPng,
    this.onDownloadPng,
  });

  @override
  State<ShareResultDialog> createState() => _ShareResultDialogState();
}

class _ShareResultDialogState extends State<ShareResultDialog> {
  final _pngKey = GlobalKey();
  bool _exporting = false;
  Future<void>? _globeReady;

  String get scenarioName => widget.scenarioName;
  String get observerHeight => widget.observerHeight;
  String get surfaceElevation => widget.surfaceElevation;
  String get distance => widget.distance;
  String get refractionFactor => widget.refractionFactor;
  String get targetHeight => widget.targetHeight;
  String get targetBaseElevation => widget.targetBaseElevation;
  TargetInputType get targetInputType => widget.targetInputType;
  CalculationResult get result => widget.result;
  bool get isMetric => widget.isMetric;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _globeReady ??= precacheImage(
      const AssetImage('assets/images/globe_earth.png'),
      context,
    );
  }

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

  Future<Uint8List> _renderPng() async {
    await _globeReady;
    await WidgetsBinding.instance.endOfFrame;
    final boundary =
        _pngKey.currentContext!.findRenderObject()! as RenderRepaintBoundary;
    final image = await boundary.toImage(pixelRatio: 2);
    try {
      final data = await image.toByteData(format: ui.ImageByteFormat.png);
      if (data == null) throw StateError('Could not encode the result image.');
      return data.buffer.asUint8List();
    } finally {
      image.dispose();
    }
  }

  Future<void> _copyPng() async {
    setState(() => _exporting = true);
    try {
      final copy = widget.onCopyPng ?? copyPngToClipboard;
      await copy(await _renderPng());
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('PNG copied. Paste it into your post.')),
        );
      }
    } catch (error) {
      debugPrint('Could not copy share-result PNG: $error');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(
              'This browser blocked image copying. Use Download PNG instead.',
            ),
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _exporting = false);
    }
  }

  Future<void> _downloadPng() async {
    setState(() => _exporting = true);
    try {
      final download = widget.onDownloadPng ?? downloadPng;
      download(await _renderPng(), 'beyond-horizon-result.png');
    } finally {
      if (mounted) setState(() => _exporting = false);
    }
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

    final card = RepaintBoundary(
      key: _pngKey,
      child: ColoredBox(
        key: const ValueKey('share_result_png'),
        color: theme.colorScheme.surface,
        child: Padding(
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
                    const SizedBox(width: 48),
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
                    const SizedBox(width: 48),
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

    return Dialog(
      key: const ValueKey('share_result_dialog'),
      insetPadding: const EdgeInsets.all(16),
      child: ConstrainedBox(
        constraints: BoxConstraints(
          maxWidth: 820,
          maxHeight: MediaQuery.sizeOf(context).height - 32,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Flexible(
              child: SingleChildScrollView(
                child: Stack(
                  children: [
                    card,
                    Positioned(top: 8, right: 8, child: closeButton),
                  ],
                ),
              ),
            ),
            const Divider(height: 1),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  OutlinedButton.icon(
                    onPressed: _exporting ? null : _downloadPng,
                    icon: const Icon(Icons.download),
                    label: const Text('Download PNG'),
                  ),
                  const SizedBox(width: 12),
                  FilledButton.icon(
                    onPressed: _exporting ? null : _copyPng,
                    icon: _exporting
                        ? const SizedBox.square(
                            dimension: 16,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          )
                        : const Icon(Icons.copy),
                    label: const Text('Copy PNG'),
                  ),
                ],
              ),
            ),
          ],
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
