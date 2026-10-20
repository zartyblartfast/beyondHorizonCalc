import 'package:BeyondHorizonCalc/models/line_of_sight_preset.dart';
import 'package:BeyondHorizonCalc/widgets/calculator/diagram/label_group_handler.dart';
import 'package:BeyondHorizonCalc/widgets/calculator/diagram_display.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'custom_scenario_test.dart' show MemoryStorage, mount, inputs;

void main() {
  testWidgets(
      'narrow form stacks and both diagram-only help dialogs close safely',
      (tester) async {
    await mount(tester, MemoryStorage());
    tester.view.devicePixelRatio = 1;
    tester.view.physicalSize = const Size(390, 3000);
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    await tester.binding.setSurfaceSize(const Size(390, 3000));
    await tester.pump();
    await tester.pump();
    expect(
        tester.getTopLeft(find.text('Distance to Horizon (D1)')).dy,
        greaterThan(
            tester.getBottomLeft(find.text('Calculate visibility')).dy));
    await tester.tap(find.text('Edit these values'));
    await tester.pump();
    await tester.pump();
    for (final tooltip in [
      'Help: target elevation methods',
      'Help: sea level and elevated lakes'
    ]) {
      final before = inputs(tester).observerHeightController.text;
      await tester.tap(find.byTooltip(tooltip));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 400));
      expect(find.byType(Dialog), findsOneWidget);
      expect(find.byType(InteractiveViewer), findsOneWidget);
      expect(tester.takeException(), isNull);
      await tester.sendKeyEvent(LogicalKeyboardKey.escape);
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 400));
      expect(find.byType(Dialog), findsNothing);
      expect(inputs(tester).observerHeightController.text, before);
    }
    expect(tester.takeException(), isNull);
  });

  setUpAll(() async {
    await LabelGroupHandler.initialize();
  });
  testWidgets('main cross-section stays bounded and vertical diagram expands',
      (tester) async {
    await mount(tester, MemoryStorage());
    await tester.binding.setSurfaceSize(const Size(1800, 3000));
    await tester.pump();
    for (var i = 0; i < 20; i++) {
      await tester.runAsync(
          () => Future<void>.delayed(const Duration(milliseconds: 20)));
      await tester.pump();
    }
    final diagrams = find.descendant(
        of: find.byType(DiagramDisplay), matching: find.byType(SvgPicture));
    expect(diagrams, findsOneWidget);
    expect(tester.getSize(diagrams.first).height, lessThanOrEqualTo(360));
    await tester.tap(find.text('Vertical perspective diagram'));
    await tester.pump(const Duration(milliseconds: 400));
    expect(diagrams, findsNWidgets(2));
    expect(find.text('Target partially visible'), findsOneWidget);
  });

  test('preset surface is read from the record, not the example name', () {
    final preset = LineOfSightPreset.fromJson({
      'name': 'Independent test record',
      'description': '',
      'observerHeight': 200,
      'distance': 50,
      'refractionFactor': 1.15,
      'targetHeight': 40,
      'targetBaseElevation': 180,
      'targetInputType': 'structure',
      'interveningSurfaceElevation': 100,
    });
    expect(preset.toJson()['interveningSurfaceElevation'], 100);
    expect(preset.targetInputType, TargetInputType.structure);
    expect(preset.refractionFactor, 1.15);
  });

  testWidgets(
      'fresh closes optional editors and closed invalid surface cannot calculate',
      (tester) async {
    await mount(tester, MemoryStorage());
    await tester.tap(find.text('Edit these values'));
    await tester.pump();
    await tester.pump();
    await tester.tap(find.text('Change for an elevated lake'));
    await tester.pump();
    inputs(tester).interveningSurfaceElevationController.text = '9000';
    await tester.tap(find.text('Close surface settings'));
    await tester.pump();
    await tester.tap(find.text('Calculate visibility'));
    await tester.pump();
    expect(find.text('Inputs changed — recalculate'), findsOneWidget);
    await tester.tap(find.text('Edit'));
    await tester.pump();
    await tester.tap(find.text('Start fresh'));
    await tester.pump();
    expect(find.text('Horizon surface elevation'), findsNothing);
    expect(inputs(tester).observerHeightController.text, '');
    expect(inputs(tester).interveningSurfaceElevationController.text, '0');
  });

  testWidgets(
      'compact desktop puts results beside inputs with optional details closed',
      (tester) async {
    await mount(tester, MemoryStorage());
    expect(find.text('Observer and viewing path'), findsNothing);
    expect(find.text('Detailed measurements'), findsOneWidget);
    expect(find.text('Horizon-line distance (D0 / AC)'), findsNothing);
    expect(find.text('Vertical perspective diagram'), findsOneWidget);
    expect(
        tester.getTopLeft(find.text('Distance to Horizon (D1)')).dx,
        greaterThan(
            tester.getTopLeft(find.text('Observer eye elevation')).dx + 400));
    await tester.tap(find.text('My own values'));
    await tester.pump();
    await tester.pump();
    expect(find.text('Change for an elevated lake'), findsOneWidget);
    expect(find.text('Horizon surface elevation'), findsNothing);
    await tester.tap(find.text('Change for an elevated lake'));
    await tester.pump();
    expect(find.text('Horizon surface elevation'), findsOneWidget);
    inputs(tester).interveningSurfaceElevationController.text = '100';
    await tester.tap(find.text('Close surface settings'));
    await tester.pump();
    expect(find.text('Intervening surface: 100 m AMSL'), findsOneWidget);
    expect(find.text('Horizon surface elevation'), findsNothing);
    await tester.tap(find.byTooltip('Help: target elevation methods'));
    await tester.pumpAndSettle();
    expect(find.byType(Dialog), findsOneWidget);
    await tester.tap(find.text('Close'));
    await tester.pumpAndSettle();
    expect(find.byType(Dialog), findsNothing);
    expect(inputs(tester).interveningSurfaceElevationController.text, '100');
  });
  testWidgets(
      'own values starts empty and target methods retain separate entries',
      (tester) async {
    await mount(tester, MemoryStorage());
    await tester.tap(find.text('My own values'));
    await tester.pump();
    await tester.pump();
    expect(inputs(tester).observerHeightController.text, '');
    inputs(tester).observerHeightController.text = '200';
    inputs(tester).distanceController.text = '50';
    inputs(tester).targetHeightController.text = '300';
    await tester.tap(find.text('Use base elevation + height instead'));
    await tester.pump();
    expect(inputs(tester).targetHeightController.text, '');
    inputs(tester).targetHeightController.text = '70';
    inputs(tester).targetBaseElevationController.text = '20';
    await tester.tap(find.text('Use top elevation instead'));
    await tester.pump();
    expect(inputs(tester).targetHeightController.text, '300');
    await tester.tap(find.text('Use base elevation + height instead'));
    await tester.pump();
    expect(inputs(tester).targetHeightController.text, '70');
    expect(inputs(tester).targetBaseElevationController.text, '20');
    expect(inputs(tester).observerHeightController.text, '200');
    expect(inputs(tester).distanceController.text, '50');
    await tester.tap(find.text('Example scenario'));
    await tester.pump();
    await tester.pump();
    await tester.tap(find.text('My own values'));
    await tester.pump();
    await tester.pump();
    await tester.tap(find.text('Use top elevation instead'));
    await tester.pump();
    expect(inputs(tester).targetHeightController.text, '300');
    expect(find.byType(SegmentedButton<dynamic>), findsNothing);
  });
}
