import '../../../services/models/calculation_result.dart';
import 'diagram_view_model.dart';

/// Handles positioning and scaling for the Observer group elements in the mountain diagram
class ObserverGroupViewModel extends DiagramViewModel {
  // Configuration from diagram_spec.json
  final Map<String, dynamic> config;

  ObserverGroupViewModel({
    required CalculationResult? result,
    double? targetHeight,
    required bool isMetric,
    String? presetName,
    required this.config,
  }) : super(
    result: result,
    targetHeight: targetHeight,
    isMetric: isMetric,
    presetName: presetName,
  );

  @override
  Map<String, String> getLabelValues() {
    // We'll implement this later when we handle labels
    return {};
  }

  // Get Observer_SL_Line attributes
  Map<String, dynamic> getSeaLevelLineAttributes() {
    return {
      'y': 500.0,  // Primary datum line position
      'x1': -200.0,
      'x2': 200.0,
    };
  }

  // Get Observer_Height_Above_Sea_Level attributes
  Map<String, dynamic> getHeightLineAttributes() {
    final seaLevel = getSeaLevelLineAttributes();
    final double observerHeight = result?.horizonDistance ?? 0.0;  // Need to verify this is correct field
    
    // Scale height to viewbox coordinates
    final double scaledHeight = _scaleHeightToViewbox(observerHeight);
    
    return {
      'x1': 0.0,  // Centered vertically
      'x2': 0.0,
      'y1': seaLevel['y'] - scaledHeight,  // Top point
      'y2': seaLevel['y'],  // Bottom point anchored to sea level
    };
  }

  // Scale a height value to viewbox coordinates
  double _scaleHeightToViewbox(double heightInKm) {
    // Convert km to meters
    final heightInMeters = heightInKm * 1000;
    
    // Get viewbox range for height
    final viewboxMin = 250.0;  // From our config
    final viewboxMax = 500.0;
    final viewboxRange = viewboxMax - viewboxMin;
    
    // Get input range (in meters)
    final inputMin = 2.0;  // Minimum observer height
    final inputMax = 9000.0;  // Maximum observer height
    final inputRange = inputMax - inputMin;
    
    // Calculate scale factor
    final scaleFactor = viewboxRange / inputRange;
    
    // Scale height to viewbox coordinates
    return heightInMeters * scaleFactor;
  }
}
