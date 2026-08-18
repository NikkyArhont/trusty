import 'dart:typed_data';

import 'package:image/image.dart' as img;

class RgbaImageData {
  const RgbaImageData({
    required this.bytes,
    required this.width,
    required this.height,
  });

  final Uint8List bytes;
  final int width;
  final int height;
}

String jpegFileName(String? originalName) {
  final name = (originalName ?? 'image').trim();
  final dotIndex = name.lastIndexOf('.');
  final baseName = dotIndex > 0 ? name.substring(0, dotIndex) : name;
  return '${baseName.isEmpty ? 'image' : baseName}.jpg';
}

Uint8List encodeRgbaJpeg(RgbaImageData request) {
  final image = img.Image.fromBytes(
    width: request.width,
    height: request.height,
    bytes: request.bytes.buffer,
    bytesOffset: request.bytes.offsetInBytes,
    numChannels: 4,
    order: img.ChannelOrder.rgba,
  );
  return img.encodeJpg(image, quality: 82);
}
