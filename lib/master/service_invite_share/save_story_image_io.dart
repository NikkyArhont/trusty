import 'dart:typed_data';

import 'package:saver_gallery/saver_gallery.dart';

Future<void> saveStoryImage(Uint8List bytes, String fileName) async {
  final result = await SaverGallery.saveImage(
    bytes,
    quality: 100,
    name: fileName,
    androidRelativePath: 'Pictures/Sarafan',
    androidExistNotSave: false,
  );
  if (!result.isSuccess) {
    throw Exception(result.errorMessage ?? 'Не удалось сохранить изображение');
  }
}
