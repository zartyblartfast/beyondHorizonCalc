import 'package:flutter/material.dart';
import 'dart:ui' as ui;

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
      painter: RPSCustomPainter(
        earthColor: earthColor,
        lineColor: lineColor,
        groundColor: groundColor,
      ),
    );
  }
}

class RPSCustomPainter extends CustomPainter {
  final Color earthColor;
  final Color lineColor;
  final Color groundColor;

  RPSCustomPainter({
    required this.earthColor,
    required this.lineColor,
    required this.groundColor,
  });

  @override
  void paint(Canvas canvas, Size size) {
    // Scale and translate the canvas to center the drawing
    canvas.translate(size.width / 2, size.height / 2);
    double scale = size.width / 400; // Adjust scale based on the width
    canvas.scale(scale);
            
    Path path_0 = Path();
    path_0.moveTo(0,-129.88826);
    path_0.cubicTo(71.69832,-129.88826,129.88826,-71.69832,129.88826,0);
    path_0.cubicTo(129.88826,71.69832,71.69832,129.88826,0,129.88826);
    path_0.cubicTo(-71.69832,129.88826,-129.88826,71.69832,-129.88826,0);
    path_0.cubicTo(-129.88826,-71.69832,-71.69832,-129.88826,0,-129.88826);
    path_0.close();

    Paint paint_0_stroke = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2
      ..color = earthColor
      ..strokeCap = StrokeCap.round;
    canvas.drawPath(path_0, paint_0_stroke);

    Path path_1 = Path();
    path_1.moveTo(0,0);

    Paint paint_1_stroke = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2
      ..color = lineColor
      ..strokeCap = StrokeCap.round;
    canvas.drawPath(path_1, paint_1_stroke);

    Path path_2 = Path();
    path_2.moveTo(-64.87743,108.94061);
    path_2.lineTo(-154.09238,-108.94061999999998);
    path_2.lineTo(154.09238,-108.94061999999998);
    path_2.close();

    Paint paint_2_stroke = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2
      ..color = lineColor
      ..strokeCap = StrokeCap.round;
    canvas.drawPath(path_2, paint_2_stroke);

    Path path_4 = Path();
    path_4.moveTo(0,108.94061);
    path_4.lineTo(0,-108.94061999999998);

    Paint paint_4_stroke = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2
      ..color = lineColor
      ..strokeCap = StrokeCap.round;
    canvas.drawPath(path_4, paint_4_stroke);

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

    Paint paint_5_stroke = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2
      ..color = groundColor
      ..strokeCap = StrokeCap.round;
    canvas.drawPath(path_5, paint_5_stroke);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    return true;
  }
}