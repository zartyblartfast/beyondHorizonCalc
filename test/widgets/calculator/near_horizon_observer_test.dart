import 'dart:convert';
import 'dart:io';
import 'dart:math' as math;
import 'dart:ui' as ui;
import 'package:flutter_test/flutter_test.dart';
import 'package:xml/xml.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  test('near observer reuses original pixels and stands radially on surface', () async {
    final doc = XmlDocument.parse(File('assets/svg/BTH_before_horizon.svg').readAsStringSync());
    final images = doc.findAllElements('image');
    expect(images, hasLength(1), reason: 'Reuse the existing observer icon');
    final image = images.single;
    expect(image.getAttribute('id'), 'observer-icon');
    final encoded = image.getAttribute('href')!.split(',').last;
    final originalCodec = await ui.instantiateImageCodec(File('assets/observer.png').readAsBytesSync());
    final embeddedCodec = await ui.instantiateImageCodec(base64Decode(encoded));
    final original = (await originalCodec.getNextFrame()).image;
    final embedded = (await embeddedCodec.getNextFrame()).image;
    expect(embedded.width, original.width);
    expect(embedded.height, original.height);
    final src = (await original.toByteData(format: ui.ImageByteFormat.rawRgba))!.buffer.asUint8List();
    final dst = (await embedded.toByteData(format: ui.ImageByteFormat.rawRgba))!.buffer.asUint8List();
    // Exact black silhouette / antialias coverage, with only white made transparent.
    for (var i = 0; i < src.length; i += 4) {
      expect(dst[i], 0);
      expect(dst[i + 1], 0);
      expect(dst[i + 2], 0);
      expect(dst[i + 3], 255 - src[i]);
    }
    final x = double.parse(image.getAttribute('x')!);
    final y = double.parse(image.getAttribute('y')!);
    final scale = double.parse(image.getAttribute('width')!) / 321;
    expect(double.parse(image.getAttribute('height')!) / 640, closeTo(scale, 1e-10));
    final group = image.parentElement!;
    final transform = group.getAttribute('transform')!;
    final v = RegExp(r'-?\d+(?:\.\d+)?').allMatches(transform).map((m) => double.parse(m[0]!)).toList();
    expect(v, hasLength(3));
    expect(math.sqrt(math.pow(v[0] - 650, 2) + math.pow(v[1] - 1180, 2)), closeTo(1000, .001));
    expect(v[2], closeTo(-math.atan2(570, 1000) * 180 / math.pi, .00001));
    expect((v[0] - 650) / (v[1] - 1180), closeTo(.57, .000001));
    // No eyes are drawn: upper-face centre (160.5,64) is the eye datum.
    // The baseline midpoint (160.5,639) is the surface contact datum.
    final angle = v[2] * math.pi / 180;
    List<double> world(double px, double py) {
      final dx = x + px * scale;
      final dy = y + py * scale;
      return [v[0] + dx * math.cos(angle) - dy * math.sin(angle),
        v[1] + dx * math.sin(angle) + dy * math.cos(angle)];
    }
    final eye = world(160.5, 64);
    final a = doc.findAllElements('circle').singleWhere((e) => e.getAttribute('id') == 'point-A');
    expect(eye[0], closeTo(double.parse(a.getAttribute('cx')!), .000001), reason: 'Eye anchor must be A, not merely near A');
    expect(eye[1], closeTo(double.parse(a.getAttribute('cy')!), .000001));
    final foot = world(160.5, 639);
    expect(math.sqrt(math.pow(foot[0]-650, 2)+math.pow(foot[1]-1180, 2)), closeTo(1000, .000001));
    // Finite-width flat soles approximate a curved surface within one SVG unit.
    for (final px in [40.0, 94.0, 223.0, 274.0]) {
      final sole = world(px, 639);
      expect(math.sqrt(math.pow(sole[0]-650, 2)+math.pow(sole[1]-1180, 2)), closeTo(1000, 1));
    }
    // Conservative 14x16 glyph box plus two units clearance for the A label.
    final label = doc.findAllElements('text').singleWhere((e) => e.innerText == 'A');
    final lx = double.parse(label.getAttribute('x')!);
    final ly = double.parse(label.getAttribute('y')!);
    var collisions = 0;
    for (var py = 0; py < 640; py++) {
      for (var px = 0; px < 321; px++) {
        if (dst[(py * 321 + px) * 4 + 3] < 32) continue;
        final p = world(px.toDouble(), py.toDouble());
        if (p[0] >= lx - 2 && p[0] <= lx + 16 && p[1] >= ly - 18 && p[1] <= ly + 2) collisions++;
      }
    }
    expect(collisions, 0, reason: 'A label must clear the enlarged head');
    original.dispose(); embedded.dispose(); originalCodec.dispose(); embeddedCodec.dispose();
  });
}
