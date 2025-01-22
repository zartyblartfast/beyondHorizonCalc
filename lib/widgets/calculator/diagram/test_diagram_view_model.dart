import 'diagram_view_model.dart';

class TestDiagramViewModel extends DiagramViewModel {
  TestDiagramViewModel({
    required super.isMetric,
  }) : super(result: null);

  @override
  Map<String, String> getLabelValues() {
    // Return empty map since we don't need labels for this test
    return {};
  }

  // Get test dot position in viewbox coordinates
  Map<String, double> getTestDotPosition() {
    return {
      'cx': 0.0,
      'cy': 300.0,
    };
  }

  // Update SVG content with new position
  String updateTestDot(String svgContent) {
    final position = getTestDotPosition();
    
    // Regular expression to match Test_Dot element
    final regex = RegExp(r'<ellipse[^>]*id="Test_Dot"[^>]*>');
    
    // Create updated element with new coordinates
    final updatedElement = '<ellipse\n'
        '     style="opacity:1;fill:#ff0000;fill-opacity:1;stroke:#17830c;stroke-width:2.28276;stroke-opacity:1"\n'
        '     id="Test_Dot"\n'
        '     cx="${position['cx']}"\n'
        '     cy="${position['cy']}"\n'
        '     rx="3.8586204"\n'
        '     ry="3.8586197" />';
    
    // Replace old element with updated one
    return svgContent.replaceAll(regex, updatedElement);
  }
}
