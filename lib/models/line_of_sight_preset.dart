import 'dart:convert';
import 'package:flutter/services.dart' show rootBundle;

class LineOfSightPreset {
  final String name;
  final bool isHidden;
  final String description;
  final double observerHeight;
  final double distance;
  final double refractionFactor;
  final double? targetHeight;

  const LineOfSightPreset({
    required this.name,
    required this.isHidden,
    required this.description,
    required this.observerHeight,
    required this.distance,
    required this.refractionFactor,
    this.targetHeight,
  });

  factory LineOfSightPreset.fromJson(Map<String, dynamic> json) {
    return LineOfSightPreset(
      name: json['name'] as String,
      isHidden: json['isHidden'] as bool? ?? false,  // Default to false if not present
      description: json['description'] as String,
      observerHeight: json['observerHeight'].toDouble(),
      distance: json['distance'].toDouble(),
      refractionFactor: json['refractionFactor'].toDouble(),
      targetHeight: json['targetHeight']?.toDouble(),
    );
  }

  Map<String, dynamic> toJson() => {
    'name': name,
    'isHidden': isHidden,
    'description': description,
    'observerHeight': observerHeight,
    'distance': distance,
    'refractionFactor': refractionFactor,
    if (targetHeight != null) 'targetHeight': targetHeight,
  };

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is LineOfSightPreset &&
          name == other.name &&
          isHidden == other.isHidden &&
          description == other.description &&
          observerHeight == other.observerHeight &&
          distance == other.distance &&
          refractionFactor == other.refractionFactor &&
          targetHeight == other.targetHeight;

  @override
  int get hashCode => Object.hash(
        name,
        isHidden,
        description,
        observerHeight,
        distance,
        refractionFactor,
        targetHeight,
      );

  static Future<List<LineOfSightPreset>> loadPresets({bool includeHidden = false}) async {
    try {
      final String jsonString = await rootBundle.loadString('assets/info/presets.json');
      final Map<String, dynamic> jsonMap = json.decode(jsonString);
      final List<dynamic> presetList = jsonMap['presets'];
      final presets = presetList.map((json) => LineOfSightPreset.fromJson(json)).toList();
      
      // Filter out hidden presets unless explicitly requested
      if (!includeHidden) {
        return presets.where((preset) => !preset.isHidden).toList();
      }
      return presets;
    } catch (e) {
      print('Error loading presets: $e');
      return const [];
    }
  }
}
