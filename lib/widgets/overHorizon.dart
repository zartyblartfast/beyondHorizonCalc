import 'package:flutter/material.dart';
import 'dart:math' as Math;

class OverHorizon extends StatelessWidget {
  final Size size;
  final Color earthColor;
  final Color lineColor;
  final Color groundColor;

  const OverHorizon({
    super.key,
    required this.size,
    required this.earthColor,
    required this.lineColor,
    required this.groundColor,
  });

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      size: size,
      painter: OverHorizonPainter(
        earthColor: earthColor,
        lineColor: lineColor,
        groundColor: groundColor,
      ),
    );
  }
}

class OverHorizonPainter extends CustomPainter {
  final Color earthColor;
  final Color lineColor;
  final Color groundColor;

  OverHorizonPainter({
    required this.earthColor,
    required this.lineColor,
    required this.groundColor,
  });

  @override
  void paint(Canvas canvas, Size size) {
    // First flip the Y axis since SVG and Flutter use opposite Y directions
    canvas.scale(1, -1);
    canvas.translate(0, -size.height);
    
    // Calculate independent scales for x and y
    double scaleX = size.width / 500;
    double scaleY = size.height / 1000;
    
    // Center horizontally and account for viewBox x-offset
    double xOffset = 0;  // No need to center since we're using exact scaling
    canvas.translate(xOffset - (-200 * scaleX), 0);  // Adjust for viewBox x-offset
    
    // Apply independent scaling
    canvas.scale(scaleX, scaleY);
            
    Path path_0 = Path();
    path_0.moveTo(0,-129.88826);
    path_0.cubicTo(71.69832,-129.88826,129.88826,-71.69832,129.88826,0);
    path_0.cubicTo(129.88826,71.69832,71.69832,129.88826,0,129.88826);
    path_0.cubicTo(-71.69832,129.88826,-129.88826,71.69832,-129.88826,0);
    path_0.cubicTo(-129.88826,-71.69832,-71.69832,-129.88826,0,-129.88826);
    path_0.close();

    final paintStroke1 = Paint()
      ..color = earthColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2;
    canvas.drawPath(path_0, paintStroke1);

    Path path_1 = Path();
    path_1.moveTo(0,0);

    final paintStroke2 = Paint()
      ..color = lineColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2;
    canvas.drawPath(path_1, paintStroke2);

    Path path_2 = Path();
    path_2.moveTo(-64.87743,108.94061);
    path_2.lineTo(-154.09238,-108.94061999999998);
    path_2.lineTo(154.09238,-108.94061999999998);
    path_2.close();

    final paintStroke3 = Paint()
      ..color = lineColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2;
    canvas.drawPath(path_2, paintStroke3);

    Path path_4 = Path();
    path_4.moveTo(0,108.94061);
    path_4.lineTo(0,-108.94061999999998);

    final paintStroke4 = Paint()
      ..color = lineColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2;
    canvas.drawPath(path_4, paintStroke4);

    Path path_5 = Path();
    path_5.moveTo(-150.2856,8.14071);
    path_5.lineTo(-148.44857,4.326840000000001);
    path_5.lineTo(-144.54786,0.9513100000000008);
    path_5.lineTo(-140.85362999999998,-2.0022799999999994);
    path_5.lineTo(-7.098359999999985,-2.0022799999999994);
    path_5.lineTo(-3.7228299999999854,-8.14072);
    path_5.lineTo(-1.5627799999999854,-2.00228);
    path_5.lineTo(143.11262000000002,-2.00228);
    path_5.lineTo(146.28029,0.9513100000000003);
    path_5.lineTo(148.59785,4.326840000000001);
    path_5.lineTo(150.28561,8.14071);

    final paintStroke5 = Paint()
      ..color = groundColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2;
    canvas.drawPath(path_5, paintStroke5);

    // Draw C_Point_Line
    final cPointY = 342.0; // Y coordinate of C_Point_Line
    Path cPointLine = Path();
    cPointLine.moveTo(-200, cPointY);
    cPointLine.lineTo(200, cPointY);

    final cPointPaint = Paint()
      ..color = lineColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3.3255;
    canvas.drawPath(cPointLine, cPointPaint);

    // Draw labels relative to C_Point_Line's actual position
    final textStyle = TextStyle(
      color: const Color(0xFF800080),
      fontSize: 16,
      fontFamily: 'Calibri',
      fontWeight: FontWeight.bold,
    );

    // Position Visible label above C_Point_Line
    TextPainter visiblePainter = TextPainter(
      text: TextSpan(text: 'Visible', style: textStyle),
      textDirection: TextDirection.ltr,
    );
    visiblePainter.layout();
    visiblePainter.paint(canvas, Offset(-190, cPointY - 10));

    // Position the group of labels that were originally one tspan label
    // Hidden is the anchor point, positioned relative to C_Point_Line
    final groupStartY = cPointY + 10;  // Hidden's position relative to C_Point_Line
    final lineHeight = 20.0;  // Vertical spacing between lines in the group
    
    // Hidden - anchor point for the group
    TextPainter hiddenPainter = TextPainter(
      text: TextSpan(text: 'Hidden', style: textStyle),
      textDirection: TextDirection.ltr,
    );
    hiddenPainter.layout();
    hiddenPainter.paint(canvas, Offset(-190, groupStartY));
    
    // Beyond - second line in the group
    TextPainter beyondPainter = TextPainter(
      text: TextSpan(text: 'Beyond', style: textStyle),
      textDirection: TextDirection.ltr,
    );
    beyondPainter.layout();
    beyondPainter.paint(canvas, Offset(-190, groupStartY + lineHeight));
    
    // Horizon - third line in the group
    TextPainter horizonPainter = TextPainter(
      text: TextSpan(text: 'Horizon', style: textStyle),
      textDirection: TextDirection.ltr,
    );
    horizonPainter.layout();
    horizonPainter.paint(canvas, Offset(-190, groupStartY + (lineHeight * 2)));
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    return true;
  }
}