import 'dart:io';

import 'package:flutter_image_compress/flutter_image_compress.dart';
import 'package:path_provider/path_provider.dart';

class CompressImageService {
  // Приведет к не более 1 мб
  static Future<String?> compressForOriginal(XFile file, {targetSize = 1048576}) async {
    return await _compressFile(file: file, postfix: "", minWidth: 1080, minHeight: 1080, quality: 100, targetSize: targetSize);
  }

  // Приведет к не более 0.25 мб
  static Future<String?> compressForPreview(XFile file, {targetSize = 262144}) async {
    return await _compressFile(file: file, targetSize: targetSize);
  }

  static Future<String?> _compressFile({
    required XFile file,
    String postfix = "_preview",
    int minWidth = 720, // для превью
    int minHeight = 720,
    int quality = 90,
    int targetSize = 262144 // 0.4 мб для превью
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
    while (currentSize > targetSize && quality > 5) {
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
      minWidth = (minWidth * 0.8).toInt();
      minHeight = (minHeight * 0.8).toInt();
    }

    return result?.path;
  }
}