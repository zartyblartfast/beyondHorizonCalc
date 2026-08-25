import 'dart:js_interop';
import 'dart:typed_data';

import 'package:web/web.dart' as web;

web.Blob _pngBlob(Uint8List bytes) => web.Blob(
      <web.BlobPart>[bytes.toJS].toJS,
      web.BlobPropertyBag(type: 'image/png'),
    );

Future<void> copyPngToClipboard(Uint8List bytes) async {
  final item = web.ClipboardItem(
    <String, web.Blob>{'image/png': _pngBlob(bytes)}.jsify()! as JSObject,
  );
  await web.window.navigator.clipboard
      .write(<web.ClipboardItem>[item].toJS)
      .toDart;
}

void downloadPng(Uint8List bytes, String filename) {
  final url = web.URL.createObjectURL(_pngBlob(bytes));
  final anchor = web.HTMLAnchorElement()
    ..href = url
    ..download = filename;
  anchor.click();
  web.URL.revokeObjectURL(url);
}
