import 'dart:convert';
import 'package:flutter/services.dart';

class PresetInfoService {
  static Future<String> generatePresetsInfo() async {
    try {
      final String jsonString = await rootBundle.loadString('assets/info/presets.json');
      final Map<String, dynamic> jsonMap = json.decode(jsonString);
      final List<dynamic> presetList = jsonMap['presets']
          .where((preset) => !(preset['isHidden'] ?? false))
          .toList();
      
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
        content.writeln('Observer Height: ${preset['observerHeight']}m<br>');
        content.writeln('Target Height: ${preset['targetHeight']}m<br>');
        content.writeln('Distance: ${preset['distance']}km<br>');
        final hiddenHeight = (preset['targetHeight'] - preset['observerHeight']) * 0.7;
        content.writeln('Hidden Height: ~${hiddenHeight.round()}m<br>');
        content.writeln('From ${observer['name']}, ${observer['region']}, ${observer['country']} ');
        content.writeln('to ${target['name']}, ${target['region']}, ${target['country']}.<br>');
        content.writeln('Best viewing conditions: ${details['bestViewingConditions']}<br>');
        content.writeln('${details['notes']}<br>');
        if (details['attribution'] != null) {
          content.writeln('Attribution: ${details['attribution']}');
        }
        content.writeln('</p>');
        content.writeln('</li>');
      }

      content.writeln('</ul>');
      content.writeln('<p>Each preset includes accurate measurements based on real-world data:</p>');
      content.writeln('<ul>');
      content.writeln('<li><strong>Observer Height (h1):</strong> Height of the viewing position above sea level</li>');
      content.writeln('<li><strong>Target Height:</strong> Height of the distant object above sea level</li>');
      content.writeln('<li><strong>Distance:</strong> Direct line of sight distance between observer and target</li>');
      content.writeln('<li><strong>Hidden Height:</strong> Approximate height hidden by Earth\'s curvature (varies with refraction)</li>');
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
      final List<dynamic> presetList = jsonMap['presets']
          .where((preset) => !(preset['isHidden'] ?? false))
          .toList();
      
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
      content.writeln('<ul>');

      for (var preset in presetList) {
        final details = preset['details'];
        final location = details['location'];
        final observer = location['observer'];
        final target = location['target'];
        final hiddenHeight = (preset['targetHeight'] - preset['observerHeight']) * 0.7;

        content.writeln('<li>');
        content.writeln('<h4>${preset['name']}</h4>');
        content.writeln('<div class="measurements">');
        content.writeln('<p><strong>Key Measurements:</strong></p>');
        content.writeln('<ul>');
        content.writeln('<li>Observer Height (h1): ${preset['observerHeight']}m</li>');
        content.writeln('<li>Target Height: ${preset['targetHeight']}m</li>');
        content.writeln('<li>Distance: ${preset['distance']}km</li>');
        content.writeln('<li>Hidden Height: ~${hiddenHeight.round()}m</li>');
        content.writeln('</ul>');
        content.writeln('</div>');
        
        content.writeln('<div class="location-details">');
        content.writeln('<p><strong>Location Details:</strong></p>');
        content.writeln('<ul>');
        content.writeln('<li><strong>Observer:</strong> ${observer['name']}, ${observer['region']}, ${observer['country']}</li>');
        content.writeln('<li><strong>Target:</strong> ${target['name']}, ${target['region']}, ${target['country']}</li>');
        content.writeln('</ul>');
        content.writeln('</div>');
        
        content.writeln('<div class="viewing-details">');
        content.writeln('<p><strong>Viewing Information:</strong></p>');
        content.writeln('<ul>');
        content.writeln('<li><strong>Best Conditions:</strong> ${details['bestViewingConditions']}</li>');
        content.writeln('<li><strong>Notes:</strong> ${details['notes']}</li>');
        if (details['attribution'] != null) {
          content.writeln('<li><strong>Attribution:</strong> ${details['attribution']}</li>');
        }
        content.writeln('</ul>');
        content.writeln('</div>');
        
        content.writeln('</li>');
      }

      content.writeln('</ul>');
      content.writeln('</div>');
      
      // Footer with explanation
      content.writeln('<div class="section">');
      content.writeln('<h3>Understanding the Measurements</h3>');
      content.writeln('<ul>');
      content.writeln('<li><strong>Observer Height (h1):</strong> The elevation of the viewing position above sea level.</li>');
      content.writeln('<li><strong>Target Height:</strong> The elevation of the distant object above sea level.</li>');
      content.writeln('<li><strong>Distance:</strong> The direct line of sight distance between observer and target.</li>');
      content.writeln('<li><strong>Hidden Height:</strong> The approximate height hidden by Earth\'s curvature at the given distance. ');
      content.writeln('This value varies with atmospheric refraction conditions.</li>');
      content.writeln('</ul>');
      content.writeln('</div>');
      
      return content.toString();
    } catch (e) {
      print('Error generating preset report: $e');
      return '<p>Error generating preset report.</p>';
    }
  }
}
