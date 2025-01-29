import '../../../services/models/calculation_result.dart';
import 'diagram_view_model.dart';
import 'observer_group_view_model.dart';
import 'sky_group_view_model.dart';
import 'mountain_group_view_model.dart';

/// View model specifically for mountain diagram calculations and label values
class MountainDiagramViewModel extends DiagramViewModel {
  final ObserverGroupViewModel _observerGroup;
  final SkyGroupViewModel _skyGroup;
  final MountainGroupViewModel _mountainGroup;
  final Map<String, dynamic> diagramSpec;

  MountainDiagramViewModel({
    required CalculationResult? result,
    double? targetHeight,
    required bool isMetric,
    String? presetName,
    required this.diagramSpec,
  }) : _observerGroup = ObserverGroupViewModel(
         result: result,
         targetHeight: targetHeight,
         isMetric: isMetric,
         presetName: presetName,
         config: diagramSpec,
       ),
       _skyGroup = SkyGroupViewModel(
         result: result,
         targetHeight: targetHeight,
         isMetric: isMetric,
         presetName: presetName,
         config: diagramSpec,
       ),
       _mountainGroup = MountainGroupViewModel(
         result: result,
         targetHeight: targetHeight,
         isMetric: isMetric,
         presetName: presetName,
         config: diagramSpec,
       ),
       super(
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
      'HiddenHeight': 'Hidden Height = ${formatHeight(h2InUnits)}',
      'VisibleHeight': 'Visible Height = ${_getVisibleHeightText()}',
      ..._observerGroup.getLabelValues(),
      ..._mountainGroup.getLabelValues(),
    };
  }

  String _getVisibleHeightText() {
    if (targetHeight == null || targetHeight == 0 || h2InUnits == null) {
      return '';
    }
    // Otherwise, visible portion is target height minus hidden height
    return formatHeight(targetHeight! - h2InUnits!);
  }

  /// Updates all dynamic elements in the mountain diagram
  String updateDynamicElements(String svgContent) {
    return updateDiagram(svgContent);
  }

  String updateDiagram(String svgContent) {
    var updatedSvg = svgContent;
    
    // Update observer group first to get observer level
    updatedSvg = _observerGroup.updateSvg(updatedSvg);
    
    // Get observer level from observer group for sky and mountain positioning
    final observerLevel = _observerGroup.getObserverLevel();
    
    // Update sky group with observer level
    updatedSvg = _skyGroup.updateSkyGroup(updatedSvg, observerLevel);
    
    // Update mountain group with observer level
    updatedSvg = _mountainGroup.updateMountainGroup(updatedSvg, observerLevel);
    
    return updatedSvg;
  }
}
