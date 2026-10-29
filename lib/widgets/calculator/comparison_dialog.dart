import 'dart:typed_data';
import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import '../../services/scenario_comparison.dart';
import '../../services/share_image_export.dart';

class ComparisonDialog extends StatefulWidget {
  final ComparisonInputs inputs;
  final void Function(String text, String filename)? onDownloadCsv;
  final void Function(Uint8List bytes, String filename)? onDownloadPng;
  final Future<void> Function(Uint8List bytes)? onCopyPng;
  const ComparisonDialog(
      {super.key,
      required this.inputs,
      this.onDownloadCsv,
      this.onDownloadPng,
      this.onCopyPng});
  @override
  State<ComparisonDialog> createState() => _ComparisonDialogState();
}

class _ComparisonDialogState extends State<ComparisonDialog> {
  final _start = TextEditingController();
  final _end = TextEditingController();
  final _increment = TextEditingController(text: '10');
  final _pngKey = GlobalKey();
  ComparisonVariable _variable = ComparisonVariable.elevation;
  ScenarioComparison? _table;
  String? _error;
  bool _dirty = false;
  bool _exporting = false;
  bool get _elevation => _variable == ComparisonVariable.elevation;
  String get _unit => _elevation
      ? '${widget.inputs.heightUnit} AMSL'
      : widget.inputs.distanceUnit;

  @override
  void initState() {
    super.initState();
    _setRange();
  }

  void _setRange() {
    final current =
        _elevation ? widget.inputs.observerElevation : widget.inputs.distance;
    _start.text = current.toString();
    _end.text = current.toString();
    _increment.text = '10';
  }

  @override
  void dispose() {
    _start.dispose();
    _end.dispose();
    _increment.dispose();
    super.dispose();
  }

  void _changed(String _) => setState(() {
        _dirty = true;
        _table = null;
        _error = null;
      });
  void _generate() {
    try {
      final table = ScenarioComparison.generate(
          inputs: widget.inputs,
          variable: _variable,
          start: double.tryParse(_start.text) ?? double.nan,
          end: double.tryParse(_end.text) ?? double.nan,
          increment: double.tryParse(_increment.text) ?? double.nan);
      setState(() {
        _table = table;
        _dirty = false;
        _error = null;
      });
    } on FormatException catch (error) {
      setState(() {
        _table = null;
        _error = error.message;
      });
    }
  }

  Future<void> _exportPng(bool copy) async {
    final table = _table;
    if (table == null || table.rows.length > ScenarioComparison.maxPngRows) {
      return;
    }
    setState(() => _exporting = true);
    try {
      await WidgetsBinding.instance.endOfFrame;
      final boundary =
          _pngKey.currentContext!.findRenderObject()! as RenderRepaintBoundary;
      final image = await boundary.toImage(pixelRatio: 2);
      late Uint8List bytes;
      try {
        final data = await image.toByteData(format: ui.ImageByteFormat.png);
        if (data == null) throw StateError('PNG encoding failed');
        bytes = data.buffer.asUint8List();
      } finally {
        image.dispose();
      }
      if (copy) {
        await (widget.onCopyPng ?? copyPngToClipboard)(bytes);
        if (mounted) {
          ScaffoldMessenger.of(context)
              .showSnackBar(const SnackBar(content: Text('PNG copied.')));
        }
      } else {
        (widget.onDownloadPng ?? downloadPng)(
            bytes, 'beyond-horizon-comparison.png');
      }
    } catch (error) {
      if (mounted) {
        setState(() => _error = copy
            ? 'Image copying was blocked. Try Download PNG instead.'
            : 'PNG export failed. Try again or use Download CSV.');
      }
    } finally {
      if (mounted) setState(() => _exporting = false);
    }
  }

  void _exportCsv() {
    try {
      (widget.onDownloadCsv ?? downloadCsv)(
          _table!.toCsv(), 'beyond-horizon-comparison.csv');
    } catch (error) {
      setState(() => _error = 'CSV download failed in this browser.');
    }
  }

  Widget _field(
          String key, String label, TextEditingController controller) =>
      SizedBox(
          width: 170,
          child: TextField(
              key: ValueKey(key),
              controller: controller,
              enabled: !_exporting,
              onChanged: _changed,
              keyboardType: const TextInputType.numberWithOptions(
                  decimal: true, signed: true),
              decoration: InputDecoration(
                  labelText: label, border: const OutlineInputBorder())));

  @override
  Widget build(BuildContext context) {
    final table = _table;
    final canPng = table != null &&
        table.rows.length <= ScenarioComparison.maxPngRows &&
        !_exporting;
    return Dialog(
        key: const ValueKey('comparison_dialog'),
        insetPadding: const EdgeInsets.all(12),
        child: ConstrainedBox(
            constraints: BoxConstraints(
                maxWidth: 1040,
                maxHeight: MediaQuery.sizeOf(context).height - 24),
            child: Column(mainAxisSize: MainAxisSize.min, children: [
              Padding(
                  padding: const EdgeInsets.fromLTRB(20, 12, 8, 0),
                  child: Row(children: [
                    Expanded(
                        child: Text('Compare scenarios',
                            style: Theme.of(context).textTheme.headlineSmall)),
                    IconButton(
                        tooltip: 'Close',
                        onPressed: _exporting
                            ? null
                            : () => Navigator.of(context).pop(),
                        icon: const Icon(Icons.close)),
                  ])),
              Flexible(
                  child: SingleChildScrollView(
                      child: Padding(
                          padding: const EdgeInsets.all(20),
                          child: Column(
                              crossAxisAlignment: CrossAxisAlignment.stretch,
                              children: [
                                const Text(
                                    'Change one input. All other current calculator settings stay fixed.'),
                                const SizedBox(height: 12),
                                DropdownButtonFormField<ComparisonVariable>(
                                    key: const ValueKey('comparison_variable'),
                                    value: _variable,
                                    isExpanded: true,
                                    decoration: const InputDecoration(
                                        labelText: 'Vary',
                                        border: OutlineInputBorder()),
                                    items: const [
                                      DropdownMenuItem(
                                          value: ComparisonVariable.elevation,
                                          child: Text(
                                              'Observer eye-level elevation')),
                                      DropdownMenuItem(
                                          value: ComparisonVariable.distance,
                                          child:
                                              Text('Target surface distance'))
                                    ],
                                    onChanged: _exporting
                                        ? null
                                        : (v) {
                                            if (v != null) {
                                              setState(() {
                                                _variable = v;
                                                _setRange();
                                                _table = null;
                                                _dirty = true;
                                                _error = null;
                                              });
                                            }
                                          }),
                                const SizedBox(height: 16),
                                Wrap(
                                    spacing: 12,
                                    runSpacing: 16,
                                    crossAxisAlignment:
                                        WrapCrossAlignment.center,
                                    children: [
                                      _field('comparison_start',
                                          'Start ($_unit)', _start),
                                      _field('comparison_end', 'End ($_unit)',
                                          _end),
                                      _field(
                                          'comparison_increment',
                                          'Increment (${_elevation ? widget.inputs.heightUnit : widget.inputs.distanceUnit})',
                                          _increment),
                                      FilledButton(
                                          onPressed:
                                              _exporting ? null : _generate,
                                          child: const Text('Generate table')),
                                    ]),
                                const SizedBox(height: 12),
                                const Text(
                                    'Positive increment; direction follows Start → End. Only regular steps are included. Maximum 1000 rows.'),
                                if (_error != null)
                                  Padding(
                                      padding: const EdgeInsets.symmetric(
                                          vertical: 12),
                                      child: Text(_error!,
                                          style: TextStyle(
                                              color: Theme.of(context)
                                                  .colorScheme
                                                  .error))),
                                if (_dirty && table == null)
                                  const Padding(
                                      padding:
                                          EdgeInsets.symmetric(vertical: 16),
                                      child: Text(
                                          'Inputs changed — generate an updated table.')),
                                if (table != null) ...[
                                  const SizedBox(height: 16),
                                  SingleChildScrollView(
                                      scrollDirection: Axis.horizontal,
                                      child: RepaintBoundary(
                                          key: _pngKey,
                                          child: ComparisonCard(table: table))),
                                  const SizedBox(height: 8),
                                  Text(
                                      '${table.rows.length} rows · Display rounded to 2 decimals; CSV retains full precision.'),
                                  if (table.rows.length >
                                      ScenarioComparison.maxPngRows)
                                    const Text(
                                        'PNG is limited to 40 rows. Download CSV for the complete table, or shorten the range. No rows are truncated.'),
                                ],
                              ])))),
              const Divider(height: 1),
              Padding(
                  padding: const EdgeInsets.all(12),
                  child: Wrap(spacing: 12, runSpacing: 8, children: [
                    OutlinedButton(
                        onPressed:
                            table == null || _exporting ? null : _exportCsv,
                        child: const Text('Download CSV')),
                    OutlinedButton(
                        onPressed: canPng ? () => _exportPng(false) : null,
                        child: const Text('Download PNG')),
                    FilledButton(
                        onPressed: canPng ? () => _exportPng(true) : null,
                        child: Text(_exporting ? 'Exporting…' : 'Copy PNG')),
                  ])),
            ])));
  }
}

/// Full-width, controls-free content: the repaint boundary is INSIDE both scroll
/// views, so image capture includes every row and column, not the viewport.
class ComparisonCard extends StatelessWidget {
  final ScenarioComparison table;
  const ComparisonCard({super.key, required this.table});
  @override
  Widget build(BuildContext context) => Container(
      key: const ValueKey('comparison_png'),
      width: 960,
      color: Theme.of(context).colorScheme.surface,
      padding: const EdgeInsets.all(24),
      child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('Beyond Horizon Calculator · comparison',
                style: Theme.of(context).textTheme.headlineSmall),
            const SizedBox(height: 8),
            Text(table.rangeLabel),
            const SizedBox(height: 16),
            Text('HELD CONSTANT',
                style: Theme.of(context).textTheme.titleSmall),
            const SizedBox(height: 8),
            Wrap(
                spacing: 24,
                runSpacing: 6,
                children: [for (final fact in table.heldConstant) Text(fact)]),
            const SizedBox(height: 16),
            Table(
                key: const ValueKey('comparison_table'),
                border: TableBorder.all(
                    color: Theme.of(context).colorScheme.outlineVariant),
                columnWidths: {
                  table.headers.length - 1: const FlexColumnWidth(1.4)
                },
                defaultVerticalAlignment: TableCellVerticalAlignment.middle,
                children: [
                  TableRow(
                      decoration: BoxDecoration(
                          color: Theme.of(context)
                              .colorScheme
                              .surfaceContainerHighest),
                      children: [
                        for (final label in table.headers)
                          Padding(
                              padding: const EdgeInsets.all(10),
                              child: Text(label,
                                  style: const TextStyle(
                                      fontWeight: FontWeight.bold))),
                      ]),
                  for (final row in table.rows)
                    TableRow(children: [
                      for (final cell in table.cells(row, rounded: true))
                        Padding(
                            padding: const EdgeInsets.all(10),
                            child: Text(cell)),
                    ]),
                ]),
            const SizedBox(height: 16),
            const Text(ScenarioComparison.modelNote),
            const SizedBox(height: 12),
            const Text('beyondhorizoncalc.com', textAlign: TextAlign.right),
          ]));
}
