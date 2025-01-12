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
  late Future<Widget> _svgFuture;

  @override
  void initState() {
    super.initState();
    _svgFuture = SvgHelper.loadSvgAsset('assets/svg_diagram.svg');
  }

  @override
  void dispose() {
    // Clean up any resources
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        // Calculate size while maintaining aspect ratio
        final maxWidth = constraints.maxWidth * 0.95;
        final maxHeight = constraints.maxHeight * 0.95;
        final aspectRatio = 283.46457 / 566.92913;
        
        // Calculate the best size that fits within constraints
        double width = maxWidth;
        double height = width * aspectRatio;
        
        if (height > maxHeight) {
          height = maxHeight;
          width = height / aspectRatio;
        }
        
        final size = Size(width, height);
        
        return Center(
          child: Stack(
            clipBehavior: Clip.none,
            children: [
              Container(
                width: size.width,
                height: size.height,
                color: Colors.transparent,
                child: FutureBuilder<Widget>(
                  future: _svgFuture,
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return const Center(child: CircularProgressIndicator());
                    }
                    if (snapshot.hasError || !snapshot.hasData) {
                      return Center(
                        child: Text('Error loading diagram: ${snapshot.error}'),
                      );
                    }
                    return snapshot.data!;
                  },
                ),
              ),
              Positioned(
                bottom: size.height * 0.05,
                right: size.width * 0.05,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 8.0),
                  decoration: BoxDecoration(
                    color: Colors.black.withOpacity(0.8),
                    borderRadius: BorderRadius.circular(8),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.2),
                        blurRadius: 4,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text(
                        'Horizon Distance: ${widget.distanceToHorizon.toStringAsFixed(1)} km',
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 14,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Dip Angle: ${EarthCurveCalculator.calculateGeometricDip(widget.observerHeight).toStringAsFixed(2)}°',
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 14,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Hidden: ${(widget.hiddenHeight).toStringAsFixed(2)} m',
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 14,
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