import 'package:BeyondHorizonCalc/models/line_of_sight_preset.dart';
import 'package:BeyondHorizonCalc/widgets/calculator/input_fields.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets(
      'surface elevation is disclosed progressively and explains derived h1',
      (tester) async {
    await tester.binding.setSurfaceSize(const Size(1000, 1400));
    addTearDown(() => tester.binding.setSurfaceSize(null));
    final surface = TextEditingController(text: '176');

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: Form(
            child: InputFields(
              observerHeightController: TextEditingController(text: '185'),
              interveningSurfaceElevationController: surface,
              distanceController: TextEditingController(text: '82'),
              refractionFactorController: TextEditingController(text: '1.07'),
              targetHeightController: TextEditingController(text: '315'),
              targetBaseElevationController: TextEditingController(text: '0'),
              targetInputType: TargetInputType.elevation,
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

    expect(find.text('Observer and viewing path'), findsOneWidget);
    expect(find.text('Horizon-forming surface'), findsOneWidget);
    expect(find.text('Target'), findsOneWidget);
    expect(find.text('Atmosphere'), findsOneWidget);
    expect(find.text('Observer eye elevation'), findsOneWidget);
    expect(find.text('Observer eye elevation (h1)'), findsNothing);
    expect(find.text('Horizon surface elevation'), findsNothing);

    await tester.tap(find.text('Surface above sea level'));
    await tester.pump();

    expect(find.text('Horizon surface elevation'), findsOneWidget);
    expect(find.text('Eye height above surface (h1)'), findsOneWidget);
    expect(find.text('9.0 m'), findsOneWidget);
  });

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
    await tester.binding.setSurfaceSize(const Size(1000, 1400));
    addTearDown(() => tester.binding.setSurfaceSize(null));
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

    expect(
      find.byKey(const ValueKey('target_measurement_selector')),
      findsOneWidget,
    );
    expect(find.text('Top elevation'), findsOneWidget);
    expect(find.text('Structure height + base elevation'), findsOneWidget);
    expect(find.text('Target top elevation (optional)'), findsOneWidget);
    expect(find.text('Base elevation'), findsNothing);

    await tester.tap(find.text('Structure height + base elevation'));
    await tester.pump();

    expect(find.text('Structure height (optional)'), findsOneWidget);
    expect(find.text('Base elevation'), findsOneWidget);
  });

  testWidgets('structure base is optional when target height is empty',
      (tester) async {
    await tester.binding.setSurfaceSize(const Size(1000, 1400));
    addTearDown(() => tester.binding.setSurfaceSize(null));
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
