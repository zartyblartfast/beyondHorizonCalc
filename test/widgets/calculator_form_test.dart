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

  for (var attempt = 0; attempt < 100; attempt++) {
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
  testWidgets('Share result opens a compact input and result summary',
      (tester) async {
    await pumpCalculatorWithPresets(tester);

    expect(find.byType(Form), findsOneWidget);
    expect(find.text('Share result'), findsOneWidget);
    await tester.tap(find.text('Share result'));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 300));

    expect(find.byKey(const ValueKey('share_result_dialog')), findsOneWidget);
    expect(find.text('Beyond Horizon Calculator'), findsOneWidget);
    expect(find.text('Inputs'), findsOneWidget);
    expect(find.text('Results'), findsOneWidget);
    expect(find.text('Karagöl Area to Shkhara - World Record'), findsWidgets);
    expect(find.text('3035.0 m AMSL'), findsOneWidget);
    expect(find.text('493.1 km'), findsOneWidget);
    expect(find.text('1.20'), findsOneWidget);
    expect(find.text('Apparent visible height'), findsNothing);
    expect(find.byKey(const ValueKey('share_result_diagram')), findsOneWidget);
    expect(find.byKey(const ValueKey('share_result_globe')), findsOneWidget);
  });
}
