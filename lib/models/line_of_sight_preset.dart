import 'dart:convert';
import 'package:flutter/services.dart' show rootBundle;

class LineOfSightPreset {
  final String name;
  final String description;
  final double observerHeight;
  final double distance;
  final double refractionFactor;
  final double? targetHeight;

  const LineOfSightPreset({
    required this.name,
    required this.description,
    required this.observerHeight,
    required this.distance,
    required this.refractionFactor,
    this.targetHeight,
  });

  factory LineOfSightPreset.fromJson(Map<String, dynamic> json) {
    return LineOfSightPreset(
      name: json['name'] as String,
      description: json['description'] as String,
      observerHeight: json['observerHeight'].toDouble(),
      distance: json['distance'].toDouble(),
      refractionFactor: json['refractionFactor'].toDouble(),
      targetHeight: json['targetHeight']?.toDouble(),
    );
  }

  Map<String, dynamic> toJson() => {
    'name': name,
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
          description == other.description &&
          observerHeight == other.observerHeight &&
          distance == other.distance &&
          refractionFactor == other.refractionFactor &&
          targetHeight == other.targetHeight;

  @override
  int get hashCode => Object.hash(
        name,
        description,
        observerHeight,
        distance,
        refractionFactor,
        targetHeight,
      );

  static Future<List<LineOfSightPreset>> loadPresets() async {
    try {
      final String jsonString = await rootBundle.loadString('assets/info/presets.json');
      final Map<String, dynamic> jsonMap = json.decode(jsonString);
      final List<dynamic> presetList = jsonMap['presets'];
      return presetList.map((json) => LineOfSightPreset.fromJson(json)).toList();
    } catch (e) {
      print('Error loading presets: $e');
      return const [];
    }
  }
}
