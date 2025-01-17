import 'dart:convert';
import 'package:flutter/services.dart';

class PresetInfoService {
  static Future<String> generatePresetsInfo() async {
    try {
      final String jsonString = await rootBundle.loadString('assets/info/presets.json');
      final Map<String, dynamic> jsonMap = json.decode(jsonString);
      final List<dynamic> presetList = jsonMap['presets'];
      
      StringBuffer content = StringBuffer();
      content.writeln('<p>Pre-configured scenarios of notable long-distance visibility cases from around the world.</p>');
      content.writeln('<h4>Available Presets:</h4>');
      content.writeln('<ul>');

      for (var preset in presetList) {
        final details = preset['details'];
        final location = details['location'];
        final observer = location['observer'];
        final target = location['target'];

        content.writeln('<li><strong>${preset['name']}</strong>');
        content.writeln('<p class="preset-details">');
        content.writeln('From ${observer['name']}, ${observer['region']}, ${observer['country']} ');
        content.writeln('to ${target['name']}, ${target['region']}, ${target['country']}.<br>');
        content.writeln('Distance: ${preset['distance']} km<br>');
        content.writeln('Best viewing conditions: ${details['bestViewingConditions']}<br>');
        content.writeln('${details['notes']}');
        content.writeln('</p>');
        content.writeln('</li>');
      }

      content.writeln('</ul>');
      content.writeln('<p>Select \'Custom Values\' to input your own measurements.</p>');
      
      return content.toString();
    } catch (e) {
      print('Error generating presets info: $e');
      return '<p>Error loading preset information.</p>';
    }
  }

  // Future method to generate a detailed report for email
  static Future<String> generatePresetReport() async {
    // TODO: Implement a more detailed report format for email
    // This could include:
    // - Full technical details
    // - Images if available
    // - Maps or diagrams
    // - References and sources
    // - Calculation results
    return await generatePresetsInfo();
  }
}
