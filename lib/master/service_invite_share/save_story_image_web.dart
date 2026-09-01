// ignore: deprecated_member_use
import 'dart:html' as html;
import 'dart:typed_data';

Future<void> saveStoryImage(Uint8List bytes, String fileName) async {
  final blob = html.Blob(<Object>[bytes], 'image/png');
  final url = html.Url.createObjectUrlFromBlob(blob);
  html.AnchorElement(href: url)
    ..download = fileName
    ..click();
  html.Url.revokeObjectUrl(url);
}
