import 'package:flutter_svg/flutter_svg.dart';
import 'package:flutter/material.dart';

class SvgHelper {
  static Widget loadSvg(String assetName, {BoxFit fit = BoxFit.contain}) {
    return SvgPicture.asset(
      assetName,
      fit: fit,
      colorFilter: const ColorFilter.mode(
        Colors.transparent,
        BlendMode.dst,
      ),
      // Explicitly handle style elements
      theme: const SvgTheme(
        currentColor: Colors.transparent,
        fontSize: 0,
        xHeight: 0,
      ),
      placeholderBuilder: (BuildContext context) => Container(
        color: Colors.transparent,
      ),
    );
  }
}
