import 'dart:convert';
import 'package:flutter/services.dart';
import 'preset_info_service.dart';

class InfoService {
  static Map<String, dynamic>? _content;

  static Future<void> _loadContent() async {
    if (_content != null) return;

    try {
      final String jsonString = await rootBundle.loadString('assets/info/field_info.json');
      _content = json.decode(jsonString);

      // Update presets info with dynamic content
      final presetsInfo = await PresetInfoService.generatePresetsInfo();
      _content!['presets'] = {
        'title': 'Famous Lines of Sight',
        'content': presetsInfo,
        'content_type': 'html'
      };
    } catch (e) {
      print('Error loading info content: $e');
      _content = {};
    }
  }

  static Future<Map<String, dynamic>?> getInfo(String key) async {
    await _loadContent();
    return _content?[key];
  }
}
