import 'package:BeyondHorizonCalc/widgets/calculator_form.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

Future<void> pumpCalculatorWithPresets(WidgetTester tester) async {
  await tester.binding.setSurfaceSize(const Size(1400, 3000));
  addTearDown(() => tester.binding.setSurfaceSize(null));

  await tester.pumpWidget(
    const MaterialApp(
      home: Scaffold(body: CalculatorForm()),
    ),
  );

  for (var attempt = 0; attempt < 20; attempt++) {
    await tester.runAsync(
      () => Future<void>.delayed(const Duration(milliseconds: 50)),
    );
    await tester.pump();
    if (find.byKey(const ValueKey('preset_dropdown')).evaluate().isNotEmpty) {
      return;
    }
  }

  fail('The default example scenario did not finish loading');
}

void main() {
  testWidgets('users can switch between examples and their own retained values',
      (tester) async {
    await pumpCalculatorWithPresets(tester);

    expect(find.byKey(const ValueKey('preset_mode_selector')), findsOneWidget);
    expect(find.text('Example scenario'), findsWidgets);
    expect(find.text('My own values'), findsOneWidget);
    expect(find.byKey(const ValueKey('units_selector')), findsOneWidget);
    expect(find.text('Edit these values'), findsOneWidget);

    final observerField = find.byType(TextFormField).first;
    final observerEditableText = find.descendant(
      of: observerField,
      matching: find.byType(EditableText),
    );
    final presetValue =
        tester.widget<TextFormField>(observerField).controller!.text;
    expect(tester.widget<TextFormField>(observerField).enabled, isTrue);
    expect(tester.widget<EditableText>(observerEditableText).readOnly, isTrue);

    await tester.tap(find.text('My own values'));
    await tester.pump();

    expect(tester.widget<EditableText>(observerEditableText).readOnly, isFalse);
    expect(tester.widget<TextFormField>(observerField).controller!.text,
        presetValue);
    expect(find.byKey(const ValueKey('preset_dropdown')), findsNothing);

    await tester.tap(find.text('Surface above sea level'));
    await tester.pump();
    expect(find.text('Horizon surface elevation'), findsOneWidget);

    await tester.tap(find.text('Example scenario').first);
    await tester.pump();
    expect(tester.widget<TextFormField>(observerField).enabled, isTrue);
    expect(tester.widget<EditableText>(observerEditableText).readOnly, isTrue);
    expect(find.text('Horizon surface elevation'), findsNothing);

    await tester.tap(find.text('Edit these values'));
    await tester.pump();
    expect(tester.widget<EditableText>(observerEditableText).readOnly, isFalse);
    expect(tester.widget<TextFormField>(observerField).controller!.text,
        presetValue);
  });
}
