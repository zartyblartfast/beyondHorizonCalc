import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'diagram_view_model.dart';
import 'horizon_diagram_view_model.dart';

/// Service to update SVG diagram labels with calculated values
class DiagramLabelService {
  static const Map<String, String> labelIds = {
    'FromTo': 'FromTo',
    'HiddenVisible': 'HiddenVisible',
    'HiddenHeight': 'HiddenHeight',
    'VisibleHeight': 'VisibleHeight',
    'h1': 'h1',
    'h2': 'h2',
    'LoS_Distance_d0': 'LoS_Distance_d0',
    'd1': 'd1',
    'd2': 'd2',
    'L0': 'L0',
    'radius': 'radius',
    '3_2_Z_Height': '3_2_Z_Height',
  };

  /// Updates all labels in the SVG with values from the view model
  String updateLabels(String svgContent, DiagramViewModel viewModel) {
    String updatedSvg = svgContent;
    final labelValues = viewModel.getLabelValues();
    
    // Update each label in the SVG
    labelValues.forEach((id, value) {
      updatedSvg = _updateLabel(updatedSvg, id, value);
    });
    
    return updatedSvg;
  }
  
  /// Updates a specific label in the SVG content
  String _updateLabel(String svgContent, String id, String newText) {
    // Find the text element with the specified ID
    final RegExp textPattern = RegExp(
      r'(<text[^>]*id="' + id + r'"[^>]*>)(.*?)(</text>)',
      multiLine: true,
      dotAll: true
    );
    
    // If found, update the text content while preserving all attributes
    return svgContent.replaceFirstMapped(textPattern, (match) {
      final openingTag = match.group(1) ?? '';
      final closingTag = match.group(3) ?? '';
      
      // Handle potential tspan elements
      if (openingTag.contains('tspan')) {
        // If there's a tspan, update its content
        final tspanPattern = RegExp(r'(<tspan[^>]*>)(.*?)(</tspan>)');
        final tspanMatch = tspanPattern.firstMatch(match.group(2) ?? '');
        if (tspanMatch != null) {
          return openingTag +
                 tspanMatch.group(1)! +
                 newText +
                 tspanMatch.group(3)! +
                 closingTag;
        }
      }
      
      // No tspan, just update text content
      return openingTag + newText + closingTag;
    });
  }
}
