import 'dart:typed_data';

import 'package:flutter/foundation.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:image/image.dart' as img;
import 'package:trusty/backend/image_processing.dart';

void main() {
  test('encodes RGBA pixels as a correctly sized JPEG in an isolate', () async {
    const width = 32;
    const height = 24;
    final rgba = Uint8List(width * height * 4);
    for (var index = 0; index < rgba.length; index += 4) {
      rgba[index] = 20;
      rgba[index + 1] = 100;
      rgba[index + 2] = 220;
      rgba[index + 3] = 255;
    }

    final encoded = await compute(
      encodeRgbaJpeg,
      RgbaImageData(bytes: rgba, width: width, height: height),
    );
    final decoded = img.decodeJpg(encoded);

    expect(encoded.take(2), [0xFF, 0xD8]);
    expect(decoded, isNotNull);
    expect(decoded!.width, width);
    expect(decoded.height, height);
  });

  test('normalizes uploaded image names to JPEG', () {
    expect(jpegFileName('photo.png'), 'photo.jpg');
    expect(jpegFileName('photo'), 'photo.jpg');
    expect(jpegFileName(null), 'image.jpg');
  });
}
