import 'dart:io';

import 'package:flutter_image_compress/flutter_image_compress.dart';
import 'package:path_provider/path_provider.dart';

class CompressImageService {
  static Future<String?> compressForOriginal(XFile file) async {
    return await _compressFile(file: file, postfix: "", minWidth: 4000, minHeight: 4000, quality: 100, targetSize: 4194304);
  }

  static Future<String?> compressForPreview(XFile file) async {
    return await _compressFile(file: file);
  }

  static Future<String?> _compressFile({
    required XFile file,
    String postfix = "_preview",
    int minWidth = 1080, // для превью
    int minHeight = 1080,
    int quality = 90,
    int targetSize = 786432 // 0.75 мб для превью
  }) async {

    final dir = await getTemporaryDirectory();
    final targetPath = "${dir.path}/${DateTime.now().microsecondsSinceEpoch}$postfix.jpeg";

    XFile? result;
    int currentSize = await file.length();

    if (currentSize <= targetSize) {
      await File(file.path).copy(targetPath);
      return targetPath;
    }

    // Цикл сжатия
    while (currentSize > targetSize && quality > 10) {
      result = await FlutterImageCompress.compressAndGetFile(
        file.path,
        targetPath,
        quality: quality,
        minWidth: minWidth,
        minHeight: minHeight,
        format: CompressFormat.jpeg,
      );

      if (result == null) break;

      currentSize = await result.length();

      quality -= 10;
      minWidth = (minWidth * 0.9).toInt();
      minHeight = (minHeight * 0.9).toInt();
    }

    return result?.path;
  }
}