import '../../../services/models/calculation_result.dart';
import 'diagram_view_model.dart';

/// View model specifically for horizon diagram calculations and label values
class HorizonDiagramViewModel extends DiagramViewModel {
  HorizonDiagramViewModel({
    required CalculationResult? result,
    double? targetHeight,
    required bool isMetric,
    String? presetName,
  }) : super(
    result: result,
    targetHeight: targetHeight,
    isMetric: isMetric,
    presetName: presetName,
  );

  /// Gets all label values for the diagram
  Map<String, String> getLabelValues() {
    return {
      'FromTo': presetName ?? 'Custom Values',  // Show "Custom Values" when no preset name
      'HiddenVisible': getVisibilityState(),
      'HiddenHeight': 'Hidden Height = ${_getHiddenHeightText()}',
      'VisibleHeight': 'Visible Height = ${_getVisibleHeightText()}',
      'h1': formatHeight(targetHeight),  
      'h2': formatHeight(h2InUnits),  
      'LoS_Distance_d0': formatDistance(result?.totalDistance),  // Total line of sight distance
      'd1': formatDistance(result?.horizonDistance),  // Distance to horizon
      'd2': formatDistance(result?.visibleDistance),  // Distance beyond horizon
      'L0': formatDistance(result?.inputDistance),  // Original input distance
      'radius': getRadiusText(),  
    };
  }

  String _getHiddenHeightText() {
    if (targetHeight == null || targetHeight == 0 || h2InUnits == null) {
      return '';
    }
    
    // If target height is less than or equal to hidden height,
    // the hidden portion is the entire target height
    if (targetHeight! <= h2InUnits!) {
      return formatHeight(targetHeight);
    }
    
    // Otherwise, the hidden portion is h2
    return formatHeight(h2InUnits);
  }

  String _getVisibleHeightText() {
    if (targetHeight == null || targetHeight == 0 || h2InUnits == null) {
      return '';
    }
    
    // If target height is less than or equal to hidden height,
    // nothing is visible
    if (targetHeight! <= h2InUnits!) {
      return '';
    }
    
    // Otherwise, visible portion is target height minus hidden height
    return formatHeight(targetHeight! - h2InUnits!);
  }
}
