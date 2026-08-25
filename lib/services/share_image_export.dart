import 'dart:typed_data';

import 'share_image_export_stub.dart'
    if (dart.library.js_interop) 'share_image_export_web.dart' as platform;

Future<void> copyPngToClipboard(Uint8List bytes) =>
    platform.copyPngToClipboard(bytes);

void downloadPng(Uint8List bytes, String filename) =>
    platform.downloadPng(bytes, filename);
