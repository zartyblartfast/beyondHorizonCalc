import 'package:BeyondHorizonCalc/widgets/guide_link.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:url_launcher/link.dart';

void main() {
  for (final entry in {
    'https://beyondhorizoncalc.com/?release=test#/': 'https://beyondhorizoncalc.com/guide/',
    'http://127.0.0.1:8879/': 'http://127.0.0.1:8879/guide/',
    'https://zartyblartfast.github.io/beyondHorizonCalc/': 'https://zartyblartfast.github.io/beyondHorizonCalc/guide/',
  }.entries) {
    testWidgets('guide link resolves correctly from ${entry.key}', (tester) async {
      await tester.pumpWidget(MaterialApp(home: Scaffold(body: GuideLink(baseUri: Uri.parse(entry.key)))));
      expect(find.text('How it works'), findsOneWidget);
      final link = tester.widget<Link>(find.byType(Link));
      expect(link.uri.toString(), entry.value);
      expect(link.target, LinkTarget.self);
    });
  }
}
