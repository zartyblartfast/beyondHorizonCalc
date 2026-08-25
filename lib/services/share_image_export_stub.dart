import 'dart:typed_data';

Future<void> copyPngToClipboard(Uint8List bytes) {
  throw UnsupportedError('Copying PNG images is only supported on the web.');
}

void downloadPng(Uint8List bytes, String filename) {
  throw UnsupportedError(
      'Downloading PNG images is only supported on the web.');
}
