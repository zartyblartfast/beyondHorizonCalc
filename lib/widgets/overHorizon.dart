import 'package:flutter/material.dart';

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
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    return true;
  }
}