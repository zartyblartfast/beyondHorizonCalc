import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

/// Approved artwork is rasterized to preserve SVG marker arrowheads in Flutter.
class InputHelpButton extends StatelessWidget {
  const InputHelpButton({super.key, required this.target});
  final bool target;

  @override
  Widget build(BuildContext context) => IconButton(
        icon: const Icon(Icons.info_outline, size: 18),
        tooltip: target
            ? 'Help: target elevation methods'
            : 'Help: sea level and elevated lakes',
        onPressed: () => showDialog<void>(
            context: context,
            builder: (context) => CallbackShortcuts(
                    bindings: {
                      const SingleActivator(LogicalKeyboardKey.escape): () =>
                          Navigator.pop(context)
                    },
                    child: Focus(
                        autofocus: true,
                        child: Dialog(
                          insetPadding: const EdgeInsets.all(12),
                          child: ConstrainedBox(
                              constraints: const BoxConstraints(
                                  maxWidth: 1060, maxHeight: 760),
                              child: Column(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Padding(
                                        padding: const EdgeInsets.symmetric(
                                            horizontal: 16, vertical: 8),
                                        child: Row(children: [
                                          Expanded(
                                              child: Text(
                                                  target
                                                      ? 'Two ways to describe the target'
                                                      : 'Sea level and elevated lakes',
                                                  style: Theme.of(context)
                                                      .textTheme
                                                      .titleMedium)),
                                          TextButton(
                                              onPressed: () =>
                                                  Navigator.pop(context),
                                              child: const Text('Close'))
                                        ])),
                                    Flexible(
                                        child: SingleChildScrollView(
                                            child: SingleChildScrollView(
                                                scrollDirection:
                                                    Axis.horizontal,
                                                child: InteractiveViewer(
                                                    minScale: 1,
                                                    maxScale: 3,
                                                    child: Image.asset(
                                                        target
                                                            ? 'assets/images/target-measurements-v2.png'
                                                            : 'assets/images/elevated-surface-v12.png',
                                                        width: 1000,
                                                        semanticLabel: target
                                                            ? 'Target elevation methods diagram'
                                                            : 'Sea and elevated lake diagram'))))),
                                  ])),
                        )))),
      );
}
