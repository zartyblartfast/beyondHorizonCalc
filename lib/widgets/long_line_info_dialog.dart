import 'package:flutter/material.dart';

class LongLineInfoDialog extends StatelessWidget {
  const LongLineInfoDialog({super.key});

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Long Lines of Sight'),
      content: const SingleChildScrollView(
        child: ListBody(
          children: [
            Text(
              'Long lines of sight are exceptional cases where objects can be seen at great distances despite Earth\'s curvature.',
              style: TextStyle(fontSize: 16),
            ),
            SizedBox(height: 16),
            Text(
              'Factors that enable long lines of sight:',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 8),
            Text('• High observer position'),
            Text('• Atmospheric refraction'),
            Text('• Clear weather conditions'),
            Text('• Large target size'),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Close'),
        ),
      ],
    );
  }
}
