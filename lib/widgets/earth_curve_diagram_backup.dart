import 'package:flutter/material.dart';
import 'dart:math' as math;
import 'dart:ui' as ui;
import 'package:flutter/services.dart' show rootBundle;
import 'dart:typed_data';

class EarthCurveDiagram extends StatefulWidget {
  final double observerHeight;
  final double distanceToHorizon;
  final double totalDistance;
  final double hiddenHeight;
  final double visibleDistance;

  const EarthCurveDiagram({
    super.key,
    required this.observerHeight,
    required this.distanceToHorizon,
    required this.totalDistance,
    required this.hiddenHeight,
    required this.visibleDistance,
  });

  @override
  State<EarthCurveDiagram> createState() => _EarthCurveDiagramState();
}

class _EarthCurveDiagramState extends State<EarthCurveDiagram> {
  ui.Image? observerImage;

  @override
  void initState() {
    super.initState();
    _loadObserverImage();
  }

  Future<void> _loadObserverImage() async {
    final ByteData data = await rootBundle.load('assets/observer.png');
    final Uint8List bytes = data.buffer.asUint8List();
    final codec = await ui.instantiateImageCodec(bytes);
    final frame = await codec.getNextFrame();
    setState(() {
      observerImage = frame.image;
    });
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final maxWidth = constraints.maxWidth * 0.8;
        // Original SVG viewBox was 566.92913 x 283.46457
        final size = Size(maxWidth, maxWidth * (283.46457 / 566.92913));
        return Center(
          child: CustomPaint(
            size: size,
            painter: _EarthCurvePainter(
              observerHeight: widget.observerHeight,
              distanceToHorizon: widget.distanceToHorizon,
              totalDistance: widget.totalDistance,
              hiddenHeight: widget.hiddenHeight,
              visibleDistance: widget.visibleDistance,
              colors: _DiagramColors(context),
              observerImage: observerImage,
            ),
          ),
        );
      },
    );
  }
}

class _DiagramColors {
  final Color earth;
  final Color labels;
  final Color lines;

  _DiagramColors(BuildContext context) :
    earth = const Color.fromRGBO(30, 28, 193, 1),
    labels = const Color.fromRGBO(247, 47, 58, 1),
    lines = Colors.black;
}

class _EarthCurvePainter extends CustomPainter {
  final double observerHeight;
  final double distanceToHorizon;
  final double totalDistance;
  final double hiddenHeight;
  final double visibleDistance;
  final _DiagramColors colors;
  final ui.Image? observerImage;

  _EarthCurvePainter({
    required this.observerHeight,
    required this.distanceToHorizon,
    required this.totalDistance,
    required this.hiddenHeight,
    required this.visibleDistance,
    required this.colors,
    this.observerImage,
  });

  @override
  void paint(Canvas canvas, Size size) {
    // Scale factor to match original SVG viewBox
    final scaleX = size.width / 566.92913;
    final scaleY = size.height / 283.46457;
    
    // Main circle constants from SVG
    final circleRadius = 129.88826;
    final circleTransform = Matrix4(
      1.6819826443 * scaleX, 0, 0, 0,
      0, 1.6736017774 * scaleY, 0, 0,
      0, 0, 1, 0,
      269.1631661807 * scaleX, 276.3319218607 * scaleY, 0, 1,
    );

    canvas.save();
    canvas.transform(circleTransform.storage);

    // Define origin point (O)
    final originPoint = Offset(0, 0);
    
    // Draw Earth semicircle from origin point
    final circlePath = Path()
      ..moveTo(-circleRadius, 0)          // Left end of diameter at O's height
      ..lineTo(circleRadius, 0)           // Right end of diameter at O's height
      ..arcToPoint(                 // Draw arc above the diameter line
        Offset(-circleRadius, 0),
        radius: Radius.circular(circleRadius),
        clockwise: false,           // Counter-clockwise for arc above diameter
        largeArc: true             // Large arc for upper half
      );

    // Draw the semicircle
    canvas.drawPath(
      circlePath,
      Paint()
        ..color = colors.earth
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1 / scaleX
    );

    // Draw origin point O (using same transform as semicircle)
    canvas.drawCircle(
      originPoint,
      2 * scaleX,
      Paint()..color = colors.labels
    );

    // Calculate points relative to origin
    final angleA = -math.pi / 12;  // 15 degrees from vertical in the opposite direction
    final angleB = 0.0;  // Vertical line
    final angleC = -math.pi / 4;  // -45 degrees
    
    // Calculate points on circumference using the circle's radius, not the diagram height
    final pointA = Offset(
      originPoint.dx + circleRadius * math.sin(angleA),
      originPoint.dy - circleRadius * math.cos(angleA)
    );
    final pointB = Offset(0, -circleRadius);  // Center top
    final pointC = Offset(circleRadius * 0.5, -circleRadius * 0.4);   // Right side above origin

    // Draw points
    for (var point in [pointA, pointB, pointC]) {
      canvas.drawCircle(
        point,
        2 * scaleX,
        Paint()..color = colors.labels
      );
    }

    // Draw lines from origin to points
    final linePaint = Paint()
      ..color = colors.lines
      ..strokeWidth = 1 * scaleX
      ..style = PaintingStyle.stroke;

    for (var point in [pointA, pointB, pointC]) {
      canvas.drawLine(originPoint, point, linePaint);
    }

    // Draw labels using same transform
    final labelStyle = TextStyle(
      color: colors.labels,
      fontSize: 14 * scaleX,
      fontWeight: FontWeight.bold,
    );

    final textPainter = TextPainter(
      textDirection: TextDirection.ltr,
      textAlign: TextAlign.center,
    );

    // Draw O label
    textPainter.text = TextSpan(text: 'O', style: labelStyle);
    textPainter.layout();
    textPainter.paint(canvas, originPoint.translate(-textPainter.width / 2, textPainter.height));

    // Draw other labels
    final labels = {'A': pointA, 'B': pointB, 'C': pointC};
    for (var entry in labels.entries) {
      textPainter.text = TextSpan(text: entry.key, style: labelStyle);
      textPainter.layout();
      textPainter.paint(canvas, entry.value.translate(-textPainter.width / 2, -textPainter.height - 2));
    }

    // Draw observer at point A if image is loaded
    if (observerImage != null) {
      final imageSize = Size(5 * scaleX, 7.5 * scaleX);  // Reduced from 20x30 to 5x7.5 (25%)
      
      // Calculate rotation angle for the image (perpendicular to line A)
      final imageRotation = angleA;
      
      // Save canvas state before rotation
      canvas.save();
      
      // Translate to point A, rotate, and draw image
      canvas.translate(pointA.dx, pointA.dy);
      canvas.rotate(imageRotation);
      canvas.drawImageRect(
        observerImage!,
        Rect.fromLTWH(0, 0, observerImage!.width.toDouble(), observerImage!.height.toDouble()),
        Rect.fromLTWH(-imageSize.width / 2, -imageSize.height, imageSize.width, imageSize.height),
        Paint(),
      );
      
      // Restore canvas state
      canvas.restore();
    }

    // Warning text
    textPainter.text = TextSpan(
      text: 'Warning:\nNot to Scale!',
      style: labelStyle.copyWith(fontSize: 15 * scaleX),
    );
    textPainter.layout();
    textPainter.paint(
      canvas,
      Offset(-circleRadius * 0.8, circleRadius * 0.5),  // Position relative to origin
    );

    canvas.restore();
  }

  @override
  bool shouldRepaint(covariant _EarthCurvePainter oldDelegate) {
    return observerHeight != oldDelegate.observerHeight ||
        distanceToHorizon != oldDelegate.distanceToHorizon ||
        totalDistance != oldDelegate.totalDistance ||
        hiddenHeight != oldDelegate.hiddenHeight ||
        visibleDistance != oldDelegate.visibleDistance ||
        observerImage != oldDelegate.observerImage;
  }
}
