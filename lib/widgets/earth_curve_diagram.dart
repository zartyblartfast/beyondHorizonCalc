import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

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
          child: Container(
            width: size.width,
            height: size.height,
            color: Colors.transparent,
            child: SvgPicture.asset(
              'assets/svg_diagram.svg',
              fit: BoxFit.contain,
              colorFilter: ColorFilter.mode(
                Colors.transparent,
                BlendMode.dst,
              ),
              placeholderBuilder: (BuildContext context) => Container(
                color: Colors.transparent,
              ),
            ),
          ),
        );
      },
    );
  }
}