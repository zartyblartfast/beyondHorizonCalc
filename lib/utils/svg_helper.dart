import 'package:flutter_svg/flutter_svg.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show rootBundle;

class SvgHelper {
  static Widget loadSvg(String assetName, {BoxFit fit = BoxFit.contain}) {
    return SvgPicture.asset(
      assetName,
      fit: fit,
      // Remove the color filter as it might interfere with SVG styles
      theme: SvgTheme(
        currentColor: Colors.black, // Default color for paths
        fontSize: 14.0, // Default font size
        xHeight: 14.0, // Default x-height
      ),
      placeholderBuilder: (BuildContext context) => Container(
        color: Colors.transparent,
      ),
    );
  }

  static Future<Widget> loadSvgAsset(String assetName, {BoxFit fit = BoxFit.contain}) async {
    try {
      // Load the SVG file as a string
      String svgString = await rootBundle.loadString(assetName);
      
      // Remove any problematic style elements
      svgString = svgString.replaceAll(RegExp(r'<style[^>]*>.*?</style>', multiLine: true, dotAll: true), '');
      
      return SvgPicture.string(
        svgString,
        fit: fit,
        placeholderBuilder: (BuildContext context) => Container(
          color: Colors.transparent,
          child: const Center(
            child: CircularProgressIndicator(),
          ),
        ),
      );
    } catch (e) {
      debugPrint('Error loading SVG: $e');
      return Container(
        color: Colors.grey[200],
        child: const Center(
          child: Text('Error loading diagram'),
        ),
      );
    }
  }
}
