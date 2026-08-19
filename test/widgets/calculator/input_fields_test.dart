import 'package:BeyondHorizonCalc/models/line_of_sight_preset.dart';
import 'package:BeyondHorizonCalc/widgets/calculator/input_fields.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('mountain preset displays its target elevation value',
      (tester) async {
    await tester.binding.setSurfaceSize(const Size(1000, 1200));
    addTearDown(() => tester.binding.setSurfaceSize(null));

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: Form(
            child: InputFields(
              observerHeightController: TextEditingController(text: '7015.0'),
              interveningSurfaceElevationController:
                  TextEditingController(text: '0.0'),
              distanceController: TextEditingController(text: '539.0'),
              refractionFactorController: TextEditingController(text: '1.07'),
              targetHeightController: TextEditingController(text: '6070.0'),
              targetBaseElevationController: TextEditingController(text: '0.0'),
              targetInputType: TargetInputType.elevation,
              isMetric: true,
              isCustomPreset: false,
              onTargetInputTypeChanged: (_) {},
              onMetricChanged: (_) {},
              onCalculate: () {},
            ),
          ),
        ),
      ),
    );

    expect(find.text('6070.0'), findsOneWidget);
    expect(find.text('Elevation above sea level'), findsNothing);
  });

  testWidgets('structure mode asks for structure height and base elevation',
      (tester) async {
    final observer = TextEditingController(text: '102');
    final distance = TextEditingController(text: '50');
    final refraction = TextEditingController(text: '1.07');
    final target = TextEditingController(text: '100');
    final targetBase = TextEditingController(text: '100');
    var inputType = TargetInputType.elevation;

    Widget buildForm() => MaterialApp(
          home: StatefulBuilder(
            builder: (context, setState) => Scaffold(
              body: Form(
                child: InputFields(
                  observerHeightController: observer,
                  interveningSurfaceElevationController:
                      TextEditingController(text: '0'),
                  distanceController: distance,
                  refractionFactorController: refraction,
                  targetHeightController: target,
                  targetBaseElevationController: targetBase,
                  targetInputType: inputType,
                  isMetric: true,
                  isCustomPreset: true,
                  onTargetInputTypeChanged: (value) {
                    setState(() => inputType = value);
                  },
                  onMetricChanged: (_) {},
                  onCalculate: () {},
                ),
              ),
            ),
          ),
        );

    await tester.pumpWidget(buildForm());

    expect(find.text('Target elevation - optional (XZ)'), findsOneWidget);
    expect(find.text('Ground/base elevation'), findsNothing);
    expect(find.text('Intervening surface elevation'), findsOneWidget);

    await tester.tap(find.byKey(const ValueKey('target_input_type')));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Structure height').last);
    await tester.pumpAndSettle();

    expect(find.text('Structure height - optional'), findsOneWidget);
    expect(find.text('Ground/base elevation'), findsOneWidget);
  });

  testWidgets('structure base is optional when target height is empty',
      (tester) async {
    final formKey = GlobalKey<FormState>();

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: Form(
            key: formKey,
            child: InputFields(
              observerHeightController: TextEditingController(text: '102'),
              interveningSurfaceElevationController:
                  TextEditingController(text: '0'),
              distanceController: TextEditingController(text: '50'),
              refractionFactorController: TextEditingController(text: '1.07'),
              targetHeightController: TextEditingController(),
              targetBaseElevationController: TextEditingController(),
              targetInputType: TargetInputType.structure,
              isMetric: true,
              isCustomPreset: true,
              onTargetInputTypeChanged: (_) {},
              onMetricChanged: (_) {},
              onCalculate: () {},
            ),
          ),
        ),
      ),
    );

    expect(formKey.currentState!.validate(), isTrue);
  });
}
