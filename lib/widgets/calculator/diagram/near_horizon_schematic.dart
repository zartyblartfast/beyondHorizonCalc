import 'package:xml/xml.dart';
import '../../../services/models/calculation_result.dart';

/// Dedicated fixed schematic variants; not a proportional geometry renderer.
class NearHorizonSchematic {
  static String update(String source, CalculationResult result, bool isMetric) {
    String distance(double? km) => km == null
        ? 'N/A'
        : '${(isMetric ? km : km * 0.621371).toStringAsFixed(2)} ${isMetric ? 'km' : 'mi'}';
    final doc = XmlDocument.parse(source
        .replaceAll('{{AC}}', distance(result.horizonLineDistance))
        .replaceAll('{{AB}}', distance(result.observerToHorizonDistance))
        .replaceAll('{{BC}}', distance(result.horizonToTargetRadialDistance)));
    XmlElement byId(String id) => doc.descendants
        .whereType<XmlElement>()
        .singleWhere((e) => e.getAttribute('id') == id);
    final at = result.horizonPosition == HorizonPosition.at;
    if (at) {
      doc.rootElement.setAttribute('id', 'at-horizon');
      for (final id in ['point-C', 'point-X']) {
        byId(id).setAttribute('cx', '650');
        byId(id).setAttribute('cy', '180');
      }
      for (final id in [
        'd0-extension-C',
        'd2-extension-C',
        'd2-bracket',
        'target-radial'
      ]) {
        byId(id).setAttribute('x1', '650');
        byId(id).setAttribute('x2', '650');
      }
      byId('d0-bracket').setAttribute('x2', '650');
      byId('target').setAttribute('x1', '650');
      byId('target').setAttribute('y1', '180');
      for (final text in doc.descendants
          .whereType<XmlElement>()
          .where((e) => e.name.local == 'text')) {
        if (['C', 'X'].contains(text.innerText)) text.children.clear();
        if (text.innerText == 'B') {
          text.children
            ..clear()
            ..add(XmlText('C = B = X'));
          text.setAttribute('x', '662');
          text.setAttribute('y', '215');
        }
        if (text.innerText.startsWith('D0 =')) {
          text.children
            ..clear()
            ..add(XmlText('D0 = D1; D2 = 0'));
        }
        if (text.innerText.startsWith('C is not')) {
          text.children
            ..clear()
            ..add(XmlText('Target radial is at the tangent contact.'));
        }
      }
    }
    if (result.targetTopAboveSurfaceKm == null) {
      byId('target-top').parent!.children.remove(byId('target-top'));
      return doc.toXmlString();
    }
    final delta = (result.targetTopAboveSurfaceKm ?? 0) -
        (result.tangentRadialHeightKm ?? 0);
    final atSurface = result.targetTopAboveSurfaceKm == 0;
    final y = atSurface
        ? double.parse(byId('point-X').getAttribute('cy')!)
        : delta.abs() <= 1e-9
            ? 180.0
            : delta < 0
                ? 198.519
                : 150.0;
    final x = atSurface
        ? double.parse(byId('point-X').getAttribute('cx')!)
        : at
            ? 650.0
            : 380 + (y - 180) * .27;
    byId('point-Z').setAttribute('cx', '$x');
    byId('point-Z').setAttribute('cy', '$y');
    for (final id in ['az', 'target']) {
      byId(id).setAttribute('x2', '$x');
      byId(id).setAttribute('y2', '$y');
    }
    byId('label-Z').setAttribute('x', '${x - 26}');
    byId('label-Z').setAttribute('y', '${y + 17}');
    return doc.toXmlString();
  }
}
