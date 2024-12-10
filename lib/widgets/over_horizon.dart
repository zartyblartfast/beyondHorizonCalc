import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

class HorizontalBracket extends StatelessWidget {
  final Size size;
  final Color color;

  const HorizontalBracket({
    super.key,
    required this.size,
    this.color = const Color.fromRGBO(4, 138, 4, 1.0),
  });

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      size: size,
      painter: BracketPainter(color: color),
    );
  }
}

class BracketPainter extends CustomPainter {
  final Color color;

  BracketPainter({
    required this.color,
  });

  @override
  void paint(Canvas canvas, Size size) {
    // Scale and translate the canvas to center the drawing
    canvas.translate(size.width / 2, size.height / 2);
    double scale = size.width / 400; // Adjust scale based on the width
    canvas.scale(scale);
            
    Path bracketPath = Path();
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

    Paint bracketPaint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2
      ..color = color
      ..strokeCap = StrokeCap.round;
    
    canvas.drawPath(bracketPath, bracketPaint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    return true;
  }
}

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
    return SvgPicture.asset(
      'assets/svg_diagram.svg',
      width: size.width,
      height: size.height,
      colorFilter: ColorFilter.mode(earthColor, BlendMode.srcIn),
    );
  }
}
