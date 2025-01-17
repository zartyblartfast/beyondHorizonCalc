import 'dart:convert';
import 'package:flutter/services.dart';
import '../models/info_content.dart';

class InfoService {
  static Map<String, InfoContent>? _infoContent;
  
  static Future<InfoContent?> getInfo(String key) async {
    if (_infoContent == null) {
      await _loadContent();
    }
    return _infoContent?[key];
  }
  
  static Future<void> _loadContent() async {
    try {
      final String jsonContent = await rootBundle.loadString('assets/info/field_info.json');
      final Map<String, dynamic> jsonMap = json.decode(jsonContent);
      
      _infoContent = jsonMap.map(
        (key, value) => MapEntry(
          key,
          InfoContent.fromJson(value as Map<String, dynamic>),
        ),
      );
    } catch (e) {
      print('Error loading info content: $e');
      _infoContent = {};
    }
  }
}
