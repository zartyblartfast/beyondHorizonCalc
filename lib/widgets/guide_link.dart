import 'package:flutter/material.dart';
import 'package:url_launcher/link.dart';

/// A real HTML anchor on web, rather than a Flutter application route.
class GuideLink extends StatelessWidget {
  const GuideLink({super.key, this.baseUri});
  final Uri? baseUri;

  @override
  Widget build(BuildContext context) {
    final base = baseUri ?? Uri.base;
    final guideUri = base.hasAuthority
        ? base.resolve('guide/')
        : Uri.parse('https://beyondhorizoncalc.com/guide/');
    return Link(
      uri: guideUri,
      target: LinkTarget.self,
      builder: (context, followLink) => TextButton(
        onPressed: followLink,
        style: TextButton.styleFrom(
          foregroundColor: Colors.white,
          textStyle: const TextStyle(
            fontSize: 14,
            decoration: TextDecoration.underline,
            decorationColor: Colors.white,
          ),
        ),
        child: const Text('How it works'),
      ),
    );
  }
}
