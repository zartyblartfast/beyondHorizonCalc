import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import '../../common/info_icon.dart';

class DiagramWithInfo extends StatelessWidget {
  final Widget svgWidget;
  final String infoKey;
  final double iconSize;
  final EdgeInsets padding;
  
  const DiagramWithInfo({
    super.key,
    required this.svgWidget,
    required this.infoKey,
    this.iconSize = 16,
    this.padding = const EdgeInsets.all(8.0),
  });

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        // Base SVG
        svgWidget,
        
        // Info Icon in top right
        Positioned(
          top: padding.top,
          right: padding.right,
          child: InfoIcon(
            infoKey: infoKey,
            size: iconSize,
          ),
        ),
      ],
    );
  }
}
