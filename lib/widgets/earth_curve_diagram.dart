import 'package:flutter/material.dart';
import '../core/calculations.dart';
import '../utils/svg_helper.dart';
import 'dart:math' as math;

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
  void dispose() {
    // Clean up any resources
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final maxWidth = constraints.maxWidth * 0.8;
        final size = Size(maxWidth, maxWidth * (283.46457 / 566.92913));
        return Center(
          child: Stack(
            children: [
              Container(
                width: size.width,
                height: size.height,
                color: Colors.transparent,
                child: SvgHelper.loadSvg(
                  'assets/svg_diagram.svg',
                ),
              ),
              Positioned(
                top: 150,
                right: 50,
                child: Container(
                  padding: const EdgeInsets.all(4.0),
                  decoration: BoxDecoration(
                    color: Colors.black.withOpacity(0.7),
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text(
                        'θ: ${EarthCurveCalculator.calculateGeometricDip(widget.observerHeight).toStringAsFixed(2)}°',
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 12,
                        ),
                      ),
                      Text(
                        'YX: ${(widget.hiddenHeight * math.sin(EarthCurveCalculator.calculateGeometricDip(widget.observerHeight) * math.pi / 180)).toStringAsFixed(2)} km',
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}