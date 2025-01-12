import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:BeyondHorizonCalc/widgets/calculator/preset_selector.dart';
import 'package:BeyondHorizonCalc/models/line_of_sight_preset.dart';

void main() {
  group('PresetSelector', () {
    testWidgets('renders dropdown and info button', (WidgetTester tester) async {
      bool infoPressed = false;
      LineOfSightPreset? changedPreset;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: PresetSelector(
              selectedPreset: LineOfSightPreset.presets[0],
              onPresetChanged: (preset) => changedPreset = preset,
              onInfoPressed: () => infoPressed = true,
            ),
          ),
        ),
      );

      // Verify dropdown exists
      expect(find.byType(DropdownButtonFormField<LineOfSightPreset>), findsOneWidget);
      
      // Verify info button exists
      expect(find.byIcon(Icons.info_outline), findsOneWidget);
      
      // Test info button press
      await tester.tap(find.byIcon(Icons.info_outline));
      expect(infoPressed, true);
    });

    testWidgets('shows all presets in dropdown', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: PresetSelector(
              selectedPreset: LineOfSightPreset.presets[0],
              onPresetChanged: (_) {},
              onInfoPressed: () {},
            ),
          ),
        ),
      );

      // Open the dropdown
      await tester.tap(find.byType(DropdownButtonFormField<LineOfSightPreset>));
      await tester.pumpAndSettle();

      // Verify all preset names are shown (they appear twice - in button and menu)
      for (final preset in LineOfSightPreset.presets) {
        expect(find.text(preset.name), findsNWidgets(preset == LineOfSightPreset.presets[0] ? 2 : 1));
      }
      
      // Verify "Custom Values" option exists
      expect(find.text('Custom Values'), findsOneWidget);
      
      // Verify label exists
      expect(find.text('Famous Line of Sight'), findsOneWidget);
    });
  });
}
