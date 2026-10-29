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

void downloadCsv(String text, String filename) {
  _downloadBlob(
      web.Blob(<web.BlobPart>['\uFEFF$text'.toJS].toJS,
          web.BlobPropertyBag(type: 'text/csv;charset=utf-8')),
      filename);
}

void downloadPng(Uint8List bytes, String filename) =>
    _downloadBlob(_pngBlob(bytes), filename);

void _downloadBlob(web.Blob blob, String filename) {
  final url = web.URL.createObjectURL(blob);
  final anchor = web.HTMLAnchorElement()
    ..href = url
    ..download = filename;
  anchor.click();
  web.URL.revokeObjectURL(url);
}
