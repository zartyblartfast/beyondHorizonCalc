import 'package:beyond_horizon_calc/widgets/calculator/diagram/diagram_element_position.dart';
import 'package:test/test.dart';
import 'dart:io';

void main() {
  test('Test dot positioning', () async {
    // Create positioning instance
    final positioner = DiagramElementPosition(config: {});
    
    // Get test dot position
    final position = positioner.getTestDotPosition();
    
    // Read SVG file
    final file = File('assets/svg/BTH_viewBox_diagram1.svg');
    var content = await file.readAsString();
    
    // Update Test_Dot coordinates
    final regex = RegExp(r'<ellipse[^>]*id="Test_Dot"[^>]*>');
    final updatedEllipse = '<ellipse\n'
        '     style="opacity:1;fill:#ff0000;fill-opacity:1;stroke:#17830c;stroke-width:2.28276;stroke-opacity:1"\n'
        '     id="Test_Dot"\n'
        '     cx="${position['cx']}"\n'
        '     cy="${position['cy']}"\n'
        '     rx="3.8586204"\n'
        '     ry="3.8586197" />';
    
    content = content.replaceAll(regex, updatedEllipse);
    
    // Write updated content back to file
    await file.writeAsString(content);
  });
}
