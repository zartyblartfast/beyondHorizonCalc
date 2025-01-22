import '../../../services/models/calculation_result.dart';
import 'diagram_view_model.dart';

/// View model specifically for mountain diagram calculations and label values
class MountainDiagramViewModel extends DiagramViewModel {
  MountainDiagramViewModel({
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

  /// Gets all label values for the mountain diagram
  @override
  Map<String, String> getLabelValues() {
    return {
      'FromTo': presetName ?? 'Custom Values',
      'HiddenVisible': getVisibilityState(),
      'HiddenHeight': 'Hidden Height = ${_getHiddenHeightText()}',
      'VisibleHeight': 'Visible Height = ${_getVisibleHeightText()}',
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
