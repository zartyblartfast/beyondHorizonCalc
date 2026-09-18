import 'package:BeyondHorizonCalc/widgets/calculator/diagram/diagram_key.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('keeps the diagram key collapsed until requested', (tester) async {
    await tester.pumpWidget(
      const MaterialApp(home: Scaffold(body: DiagramKey())),
    );

    expect(find.text('Diagram key: points and distances'), findsOneWidget);
    expect(find.text('Observer eye'), findsNothing);

    await tester.tap(find.text('Diagram key: points and distances'));
    await tester.pumpAndSettle();

    expect(find.text('Observer eye'), findsOneWidget);
    expect(find.textContaining('Surface/geodesic distance'), findsOneWidget);
    expect(find.textContaining('Direct distance to target top'), findsOneWidget);
  });
}
