import 'dart:io';
import 'package:flutter_test/flutter_test.dart';
import 'package:xml/xml.dart';

void main() {
  test('near schematic uses original cross-section theme without a card fill', () {
    final doc = XmlDocument.parse(
        File('assets/svg/BTH_before_horizon.svg').readAsStringSync());
    final elements = doc.descendants.whereType<XmlElement>();
    XmlElement id(String name) =>
        elements.singleWhere((e) => e.getAttribute('id') == name);
    expect(elements.where((e) => e.name.local == 'rect'), isEmpty,
        reason: 'Page background must remain transparent');
    expect(id('earth-fill').getAttribute('fill'), '#e2e2e2');
    expect(id('earth-fill').getAttribute('d'), startsWith(
        'M80 358.35 A1000 1000 0 0 1 650 180'));
    // Added cropped radials must share the existing circle's off-page centre.
    for (final radial in ['observer-radius', 'horizon-radius']) {
      final e = id(radial);
      double v(String key) => double.parse(e.getAttribute(key)!);
      expect((v('x1') - 650) * (v('y2') - 1180),
          closeTo((v('x2') - 650) * (v('y1') - 1180), 0.001));
    }
    expect(id('surface').getAttribute('stroke'), '#000000');
    expect(id('surface').getAttribute('stroke-width'), '1');
    expect(id('distance-brackets').getAttribute('stroke'), '#00b050');
    expect(id('surface-accent').getAttribute('stroke'), '#00b050');
    expect(id('diagram-type').getAttribute('font-family'),
        'Calibri, Calibri_MSFontService, Arial, sans-serif');
    expect(id('distance-values').getAttribute('fill'), '#552200');
    for (final point in ['A', 'B', 'C', 'X', 'Z']) {
      final label = elements.singleWhere((e) =>
          e.name.local == 'text' && e.innerText == point);
      expect(label.getAttribute('fill'), '#ff0000');
    }
    expect(id('az').getAttribute('stroke'), '#000000');
    expect(id('az').getAttribute('stroke-dasharray'), '7 4');
    expect(id('target-radial').getAttribute('stroke'), '#000000');
    // Existing verified point/tangent geometry is not restyled into the old diagram.
    expect(id('surface').getAttribute('d'),
        'M80 358.35 A1000 1000 0 0 1 650 180');
    expect(id('point-A').getAttribute('cx'), '80');
    expect(id('point-C').getAttribute('cx'), '380');
    expect(id('point-B').getAttribute('cx'), '650');
    expect(id('point-X').getAttribute('cy'), '214.567');
    expect(id('d0-bracket').getAttribute('x2'), '380');
    expect(doc.toXmlString(), isNot(contains('6378')));
  });
}
