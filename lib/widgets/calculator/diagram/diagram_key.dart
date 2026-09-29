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
          _item(textTheme, 'C',
              'Tangent meets target radial. Before B, C is not a visibility cutoff.'),
          const Divider(),
          _item(
              textTheme, 'L0', 'Surface/geodesic distance from observer to X'),
          _item(textTheme, 'A-X', 'Direct distance to target base'),
          _item(
              textTheme, 'B', 'Tangent contact on the horizon-forming surface'),
          _item(textTheme, 'D0 / A-C',
              'Horizon-tangent distance: D1 + D2 beyond; D1 - D2 before; D1 at the horizon'),
          _item(textTheme, 'D1 / A-B', 'Observer to tangent contact'),
          _item(textTheme, 'D2 / B-C',
              'Positive tangent distance between B and C; zero when C = B'),
          _item(textTheme, 'A-Z',
              'Direct distance to target top (geometric; may be obstructed by Earth)'),
          _item(textTheme, 'C-Z',
              'Target-top shortfall to the horizon line (only beyond the horizon when the top is below it)'),
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
          SizedBox(
              width: 72,
              child: Text(symbol,
                  style:
                      theme.bodyMedium?.copyWith(fontWeight: FontWeight.bold))),
          Expanded(child: Text(definition)),
        ],
      ),
    );
  }
}
