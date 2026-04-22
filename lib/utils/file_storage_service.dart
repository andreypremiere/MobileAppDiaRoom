import 'dart:io';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as p;
import 'package:uuid/uuid.dart';

import '../models/internal_error.dart';

class FileStorageService {
  static const String _uploadFolderName = 'media_files';

  /// Получает путь к защищенной директории приложения
  static Future<Directory> _getUploadDir() async {
    final appDir = await getApplicationDocumentsDirectory();
    final uploadDir = Directory(p.join(appDir.path, _uploadFolderName));

    if (!await uploadDir.exists()) {
      await uploadDir.create(recursive: true);
    }
    return uploadDir;
  }

  /// Перемещает файл из кэша (ImagePicker) в постоянную папку приложения
  static Future<ResultImageService> wrapToPermanentStorage(String tempPath) async {
    final tempFile = File(tempPath);
    if (!await tempFile.exists()) return ResultImageService(path: '', result: false, message: 'Файл не найден');

    final uploadDir = await _getUploadDir();
    final String extension = p.extension(tempPath);
    const uuid = Uuid();
    final String fileName = "${uuid.v4()}$extension";
    final String targetPath = p.join(uploadDir.path, fileName);

    try {
      final movedFile = await tempFile.rename(targetPath);
      return ResultImageService(path: movedFile.path, result: true, message: '');
    } catch (e) {
      // Если rename не сработал (разные разделы диска), копируем и удаляем оригинал
      final copiedFile = await tempFile.copy(targetPath);
      await tempFile.delete();
      return ResultImageService(path: copiedFile.path, result: true, message: '');
    }
  }

  //Удаляет файл (используем при очистке черновиков или после загрузки)
  // static Future<void> deleteFile(String path) async {
  //   final file = File(path);
  //   if (await file.exists()) {
  //     await file.delete();
  //   }
  // }
}