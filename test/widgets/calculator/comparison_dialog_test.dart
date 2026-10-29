import 'dart:io';
import 'dart:ui' as ui;
import 'package:flutter/services.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:BeyondHorizonCalc/services/scenario_comparison.dart';
import 'package:BeyondHorizonCalc/widgets/calculator/comparison_dialog.dart';

void main() {
  const inputs = ComparisonInputs(
      observerElevation: 30,
      surfaceElevation: 0,
      distance: 30,
      refractionFactor: 1.2,
      isMetric: true,
      targetTop: 100);
  testWidgets('narrow distance mode, invalid input, and explicit PNG limit',
      (tester) async {
    await tester.binding.setSurfaceSize(const Size(390, 844));
    addTearDown(() => tester.binding.setSurfaceSize(null));
    await tester.pumpWidget(const MaterialApp(
        home: Scaffold(body: ComparisonDialog(inputs: inputs))));
    await tester.tap(find.byKey(const ValueKey('comparison_variable')));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Target surface distance').last);
    await tester.pumpAndSettle();
    await tester.enterText(find.byKey(const ValueKey('comparison_start')), '1');
    await tester.enterText(find.byKey(const ValueKey('comparison_end')), '41');
    await tester.enterText(
        find.byKey(const ValueKey('comparison_increment')), '0');
    await tester.ensureVisible(find.text('Generate table'));
    await tester.tap(find.text('Generate table'));
    await tester.pump();
    expect(find.text('Increment must be greater than zero.'), findsOneWidget);
    await tester.enterText(
        find.byKey(const ValueKey('comparison_increment')), '1');
    await tester.ensureVisible(find.text('Generate table'));
    await tester.tap(find.text('Generate table'));
    await tester.pumpAndSettle();
    expect(
        tester
            .widget<OutlinedButton>(
                find.widgetWithText(OutlinedButton, 'Download PNG'))
            .onPressed,
        isNull);
    expect(
        tester
            .widget<OutlinedButton>(
                find.widgetWithText(OutlinedButton, 'Download CSV'))
            .onPressed,
        isNotNull);
    expect(find.textContaining('PNG is limited to 40 rows.'), findsOneWidget);
    expect(find.textContaining('Distance to horizon:'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });
  testWidgets('copy PNG includes full 40-row card beyond viewport',
      (tester) async {
    const outputDir = String.fromEnvironment('COMPARISON_ARTIFACT_DIR');
    if (outputDir.isNotEmpty) {
      await tester.runAsync(() async {
        final font = FontLoader('Roboto')
          ..addFont(File('C:/Windows/Fonts/segoeui.ttf')
              .readAsBytes()
              .then(ByteData.sublistView));
        await font.load();
      });
    }
    Uint8List? copied;
    await tester.binding.setSurfaceSize(const Size(390, 844));
    addTearDown(() => tester.binding.setSurfaceSize(null));
    await tester.pumpWidget(MaterialApp(
        home: Scaffold(
            body: ComparisonDialog(
                inputs: inputs,
                onCopyPng: (bytes) async {
                  copied = bytes;
                }))));
    await tester.enterText(
        find.byKey(const ValueKey('comparison_start')), '10');
    await tester.enterText(find.byKey(const ValueKey('comparison_end')), '400');
    await tester.enterText(
        find.byKey(const ValueKey('comparison_increment')), '10');
    await tester.ensureVisible(find.text('Generate table'));
    await tester.tap(find.text('Generate table'));
    await tester.pumpAndSettle();
    final cardSize =
        tester.getSize(find.byKey(const ValueKey('comparison_png')));
    await tester.tap(find.text('Copy PNG'));
    await tester.pump();
    await tester.runAsync(() async {
      for (var i = 0; i < 150 && copied == null; i++) {
        await Future<void>.delayed(const Duration(milliseconds: 20));
      }
      expect(copied, isNotNull);
      final codec = await ui.instantiateImageCodec(copied!);
      final frame = await codec.getNextFrame();
      expect(frame.image.width, 1920);
      expect(frame.image.height, (cardSize.height * 2).ceil());
      expect(frame.image.height, greaterThan(3000));
      frame.image.dispose();
      codec.dispose();
      if (outputDir.isNotEmpty) {
        await File('$outputDir/comparison-full.png').writeAsBytes(copied!);
      }
    });
    await tester.pumpAndSettle();
    expect(tester.takeException(), isNull);
  });
  testWidgets(
      'generate, hide stale rows, and export complete controls-free table',
      (tester) async {
    String? csv;
    Uint8List? png;
    await tester.pumpWidget(MaterialApp(
        home: Scaffold(
            body: ComparisonDialog(
                inputs: inputs,
                onDownloadCsv: (text, _) => csv = text,
                onDownloadPng: (bytes, _) => png = bytes))));
    await tester.enterText(
        find.byKey(const ValueKey('comparison_start')), '10');
    await tester.enterText(find.byKey(const ValueKey('comparison_end')), '30');
    await tester.enterText(
        find.byKey(const ValueKey('comparison_increment')), '10');
    await tester.tap(find.text('Generate table'));
    await tester.pumpAndSettle();
    expect(find.byKey(const ValueKey('comparison_table')), findsOneWidget);
    final card = find.byKey(const ValueKey('comparison_png'));
    expect(find.descendant(of: card, matching: find.byType(TextField)),
        findsNothing);
    expect(
        find.descendant(of: card, matching: find.text('beyondhorizoncalc.com')),
        findsOneWidget);
    await tester.tap(find.text('Download CSV'));
    expect(csv, contains('Refraction factor: 1.2'));
    expect(csv, contains('3 rows'));
    await tester.tap(find.text('Download PNG'));
    await tester.pump();
    await tester.runAsync(() async {
      for (var i = 0; i < 100 && png == null; i++) {
        await Future<void>.delayed(const Duration(milliseconds: 20));
      }
    });
    await tester.pumpAndSettle();
    expect(png?.take(8), [137, 80, 78, 71, 13, 10, 26, 10]);
    await tester.enterText(find.byKey(const ValueKey('comparison_end')), '50');
    await tester.pump();
    expect(find.byKey(const ValueKey('comparison_table')), findsNothing);
    expect(find.text('Inputs changed — generate an updated table.'),
        findsOneWidget);
    expect(
        tester
            .widget<OutlinedButton>(
                find.widgetWithText(OutlinedButton, 'Download CSV'))
            .onPressed,
        isNull);
    expect(inputs.observerElevation, 30);
  });
}
