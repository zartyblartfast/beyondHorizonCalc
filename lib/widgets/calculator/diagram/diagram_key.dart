import 'package:flutter/material.dart';

class DiagramKey extends StatelessWidget {
  const DiagramKey({super.key});

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    return Card(
      child: ExpansionTile(
        title: const Text('Diagram key: points and distances'),
        childrenPadding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
        children: [
          _item(textTheme, 'A', 'Observer eye'),
          _item(textTheme, 'X', 'Target base on the reference surface'),
          _item(textTheme, 'Z', 'Target top'),
          _item(textTheme, 'C', 'Horizon-line intersection on the target radial'),
          const Divider(),
          _item(textTheme, 'L0', 'Surface/geodesic distance from observer to X'),
          _item(textTheme, 'A-X', 'Direct distance to target base'),
          _item(textTheme, 'A-C', 'Horizon-line distance; D1 + D2'),
          _item(textTheme, 'D0 / A-Z', 'Direct distance to target top'),
        ],
      ),
    );
  }

  Widget _item(TextTheme theme, String symbol, String definition) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 3),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(width: 72, child: Text(symbol, style: theme.bodyMedium?.copyWith(fontWeight: FontWeight.bold))),
          Expanded(child: Text(definition)),
        ],
      ),
    );
  }
}
