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

  static Future<String> generatePresetReport() async {
    try {
      final String jsonString = await rootBundle.loadString('assets/info/presets.json');
      final Map<String, dynamic> jsonMap = json.decode(jsonString);
      final List<dynamic> presetList = jsonMap['presets'];
      
      StringBuffer content = StringBuffer();
      
      // Header
      content.writeln('<div style="text-align: center;">');
      content.writeln('<h2>Long Line of Sight Report</h2>');
      content.writeln('<p>Beyond Horizon Calculator - Notable Cases</p>');
      content.writeln('</div>');
      
      // Introduction
      content.writeln('<div class="section">');
      content.writeln('<p>This report presents a collection of remarkable long-distance visibility cases from around the world. ');
      content.writeln('Each case demonstrates how Earth\'s curvature affects visibility over long distances, ');
      content.writeln('taking into account factors such as atmospheric refraction and observer elevation.</p>');
      content.writeln('</div>');

      // Cases
      content.writeln('<div class="section">');
      content.writeln('<h3>Notable Cases</h3>');
      
      for (var preset in presetList) {
        final details = preset['details'];
        final location = details['location'];
        final observer = location['observer'];
        final target = location['target'];

        content.writeln('<div class="case">');
        content.writeln('<h4>${preset['name']}</h4>');
        
        // Location Details
        content.writeln('<div class="location-details">');
        content.writeln('<p><strong>Observer Location:</strong><br>');
        content.writeln('${observer['name']}, ${observer['region']}, ${observer['country']}<br>');
        content.writeln('Elevation: ${observer['elevation']} meters</p>');
        
        content.writeln('<p><strong>Target Location:</strong><br>');
        content.writeln('${target['name']}, ${target['region']}, ${target['country']}<br>');
        content.writeln('Height: ${target['height']} meters</p>');
        
        content.writeln('<p><strong>Distance:</strong> ${preset['distance']} kilometers</p>');
        content.writeln('</div>');
        
        // Viewing Conditions
        content.writeln('<div class="conditions">');
        content.writeln('<p><strong>Best Viewing Conditions:</strong><br>');
        content.writeln('${details['bestViewingConditions']}</p>');
        content.writeln('</div>');
        
        // Additional Notes
        if (details['notes']?.isNotEmpty ?? false) {
          content.writeln('<div class="notes">');
          content.writeln('<p><strong>Notes:</strong><br>');
          content.writeln('${details['notes']}</p>');
          content.writeln('</div>');
        }
        
        content.writeln('</div>'); // End of case
      }
      
      content.writeln('</div>'); // End of cases section
      
      // Footer
      content.writeln('<div class="footer">');
      content.writeln('<p><em>Generated by Beyond Horizon Calculator</em></p>');
      content.writeln('<p>For custom calculations, use the calculator with your own measurements.</p>');
      content.writeln('</div>');
      
      return content.toString();
    } catch (e) {
      print('Error generating preset report: $e');
      return '<p>Error generating the report.</p>';
    }
  }
}