import 'package:flutter/material.dart';
import 'dart:math' as math;
import 'dart:ui' as ui;
import 'package:flutter_svg/flutter_svg.dart';
import 'package:vector_math/vector_math_64.dart' as vm64;
// import 'dart:typed_data';

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
  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final maxWidth = constraints.maxWidth * 0.8;
        final size = Size(maxWidth, maxWidth * (283.46457 / 566.92913));
        return Center(
          child: SizedBox(
            width: size.width,
            height: size.height,
            child: SvgPicture.asset(
              'assets/source_file.svg',
              fit: BoxFit.contain,
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
  final Color ground;

  const _DiagramColors(BuildContext context) :
    earth = const Color.fromRGBO(30, 28, 193, 1),
    labels = const Color.fromRGBO(247, 47, 58, 1),
    lines = Colors.black,
    ground = const Color.fromRGBO(4, 138, 4, 1.0);
}

class _EarthCurvePainter extends CustomPainter {
  final double observerHeight;
  final double distanceToHorizon;
  final double totalDistance;
  final double hiddenHeight;
  final double visibleDistance;
  final _DiagramColors colors;
  final ui.Image? observerImage;

  const _EarthCurvePainter({
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
    final scale = math.min(scaleX, scaleY);
    
    // Main circle constants from SVG
    const circleRadius = 129.88826;
    final vm64.Matrix4 circleTransform;
    circleTransform = vm64.Matrix4(
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
      ..moveTo(-circleRadius, 0)
      ..lineTo(circleRadius, 0)
      ..arcToPoint(
        Offset(-circleRadius, 0),
        radius: Radius.circular(circleRadius),
        clockwise: false,
        largeArc: true
      );

    // Draw the semicircle
    canvas.drawPath(
      circlePath,
      Paint()
        ..color = colors.earth
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1 / scaleX
    );

    // Draw origin point O
    canvas.drawCircle(
      originPoint,
      2 * scaleX,
      Paint()..color = colors.labels
    );

    // Calculate points relative to origin
    const angleA = -5 * math.pi / 60;  // -15 degrees
    const angleC = -math.pi / 4;  // -45 degrees
    
    // Calculate points on circumference
    final pointA = Offset(
      originPoint.dx + circleRadius * math.sin(angleA),
      originPoint.dy - circleRadius * math.cos(angleA)
    );
    final pointB = Offset(0, -circleRadius);  // Center top
    final pointC = Offset(
      originPoint.dx + circleRadius * math.sin(angleC),
      originPoint.dy - circleRadius * math.cos(angleC)
    );

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

    canvas.drawLine(originPoint, pointA, linePaint);
    canvas.drawLine(originPoint, pointB, linePaint);
    canvas.drawLine(originPoint, pointC, linePaint);

    // Calculate observer head position
    final observerHeadPoint = Offset(
      pointA.dx,
      pointA.dy - (observerImage != null ? observerImage!.height.toDouble() * 0.025 * scaleX * 0.95 : 0)
    );

    // Draw horizontal d0 line from observer to where it meets line C
    final d0StartPoint = observerHeadPoint;
    // Calculate where horizontal line at B's height intersects with line OC
    final cLineSlope = (pointC.dy - originPoint.dy) / (pointC.dx - originPoint.dx);
    final d0IntersectX = originPoint.dx + (pointB.dy - originPoint.dy) / cLineSlope;
    final d0EndPoint = Offset(d0IntersectX, pointB.dy);    
    final d0Paint = Paint()
      ..color = colors.lines
      ..strokeWidth = 1 * scaleX
      ..style = PaintingStyle.stroke;
    
    canvas.drawLine(d0StartPoint, d0EndPoint, d0Paint);

    // Draw observer image at point A if available
    if (observerImage != null) {
      final imageSize = Size(
        observerImage!.width.toDouble() * 0.025,
        observerImage!.height.toDouble() * 0.025
      );
      
      // Calculate position so bottom of image touches the circumference
      final imageRect = Rect.fromLTWH(
        pointA.dx - (imageSize.width * scaleX) / 2,
        pointA.dy - imageSize.height * scaleX,  // Position bottom at pointA
        imageSize.width * scaleX,
        imageSize.height * scaleX,
      );

      canvas.save();
      // Rotate around point A by the angle
      canvas.translate(pointA.dx, pointA.dy);
      canvas.rotate(angleA);
      canvas.translate(-pointA.dx, -pointA.dy);
      
      // Create a paint with high filter quality
      final imagePaint = Paint()
        ..filterQuality = FilterQuality.high
        ..colorFilter = ColorFilter.matrix([
          1, 0, 0, 0, 0,
          0, 1, 0, 0, 0,
          0, 0, 1, 0, 0,
          -1, -1, -1, 1, 0,
        ]);
      
      canvas.drawImageRect(
        observerImage!,
        Rect.fromLTWH(0, 0, observerImage!.width.toDouble(), observerImage!.height.toDouble()),
        imageRect,
        imagePaint,
      );
      canvas.restore();
    }

    // Draw labels
    final labelStyle = TextStyle(
      color: colors.labels,
      fontSize: 14 * scaleX,
      fontWeight: FontWeight.bold,
    );

    final textPainter = TextPainter(
      textDirection: TextDirection.ltr,
      textAlign: TextAlign.center,
    );

    // Get B's vertical position as reference
    final labelVerticalPosition = pointB.dy - 15 * scaleX;  // B's current vertical position

    // Draw O label
    textPainter.text = TextSpan(text: 'O', style: labelStyle);
    textPainter.layout();
    textPainter.paint(
      canvas,
      originPoint.translate(-textPainter.width / 2, 2 * scaleX)
    );

    // Draw other labels at the same vertical level
    final labels = {
      'A': Offset(pointA.dx - textPainter.width - 5 * scaleX, labelVerticalPosition),
      'B': Offset(pointB.dx, labelVerticalPosition),
      'C': Offset(pointC.dx + 5 * scaleX, labelVerticalPosition)
    };

    for (var entry in labels.entries) {
      textPainter.text = TextSpan(text: entry.key, style: labelStyle);
      textPainter.layout();
      textPainter.paint(
        canvas,
        entry.value.translate(-textPainter.width / 2, 0)
      );
    }

    canvas.restore();

    // Draw horizontal bracket (after restoring the original transform)
    canvas.save();
    
    // Calculate points in screen space
    final vm64.Matrix4 transform = circleTransform;
    final vm64.Vector4 transformedPointA = transform.transform(vm64.Vector4(pointA.dx, pointA.dy, 0, 1));
    final vm64.Vector4 transformedPointC = transform.transform(vm64.Vector4(pointC.dx, pointC.dy, 0, 1));
    
    final screenPointA = Offset(transformedPointA.x, transformedPointA.y);
    final screenPointC = Offset(transformedPointC.x, transformedPointC.y);
    
    // Calculate observer head position in screen space
    final observerHeadOffset = observerImage != null ? observerImage!.height.toDouble() * 0.025 * scaleX * 0.95 : 0;
    final screenObserverHead = Offset(screenPointA.dx, screenPointA.dy - observerHeadOffset);
    
    canvas.translate(size.width / 2, 20);  // Position for the bracket
    
    // Calculate scale factor based on screen space distance
    final bracketWidth = (screenPointC.dx - screenObserverHead.dx) * 0.5;  // Half the distance
    final originalBracketWidth = 150.28561;  // Original bracket half-width
    final horizontalScale = bracketWidth / originalBracketWidth;
    
    // Center the bracket between the points
    final centerX = (screenPointC.dx + screenObserverHead.dx) / 2;
    final horizontalOffset = (centerX - size.width / 2) / horizontalScale;
    
    canvas.scale(horizontalScale, 1);  // Scale only horizontally
    canvas.translate(horizontalOffset / horizontalScale, 0);  // Center the bracket
    
    final bracketPath = Path();
    bracketPath.moveTo(-150.2856, 8.14071);
    bracketPath.lineTo(-148.44857, 4.326840000000001);
    bracketPath.lineTo(-144.54786, 0.9513100000000008);
    bracketPath.lineTo(-140.85362999999998, -2.0022799999999994);
    bracketPath.lineTo(-7.098359999999985, -2.0022799999999994);
    bracketPath.lineTo(-3.7228299999999854, -8.14072);
    bracketPath.lineTo(-1.5627799999999854, -2.00228);
    bracketPath.lineTo(143.11262000000002, -2.00228);
    bracketPath.lineTo(146.28029, 0.9513100000000003);
    bracketPath.lineTo(148.59785, 4.326840000000001);
    bracketPath.lineTo(150.28561, 8.14071);

    final bracketPaint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2 * scale
      ..color = const Color.fromRGBO(4, 138, 4, 1.0)
      ..strokeCap = StrokeCap.round;
    
    canvas.drawPath(bracketPath, bracketPaint);
    canvas.restore();
  }

  @override
  bool shouldRepaint(covariant _EarthCurvePainter oldDelegate) {
    return oldDelegate.observerHeight != observerHeight ||
           oldDelegate.distanceToHorizon != distanceToHorizon ||
           oldDelegate.totalDistance != totalDistance ||
           oldDelegate.hiddenHeight != hiddenHeight ||
           oldDelegate.visibleDistance != visibleDistance ||
           oldDelegate.observerImage != observerImage;
  }
}
