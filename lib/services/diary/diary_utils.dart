import 'dart:io';

import 'package:get_thumbnail_video/index.dart';
import 'package:get_thumbnail_video/video_thumbnail.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';
import 'package:video_player/video_player.dart';
import 'package:mime/mime.dart';
import '../../models/enums/diary/attachment_type.dart';

class DiaryUtils {
  static const videoExtensions = [
    '.mp4', '.mov', '.avi', '.wmv', '.3gp', '.m4v', '.mkv', '.webm'
  ];

  static const photoExtensions = [
    '.jpg', '.jpeg', '.png', '.gif', '.bmp', '.webp', '.heic', '.heif'
  ];

  static const audioExtensions = ['.m4a'];

  /// Возвращает mimeType только если расширение файла входит в список разрешенных.
  /// В противном случае возвращает null.
  static String? getSupportedMimeType(String filePath) {
    final ext = p.extension(filePath).toLowerCase();

    // 1. Проверяем, входит ли расширение в наши списки
    final isSupported = videoExtensions.contains(ext) || photoExtensions.contains(ext);

    if (!isSupported) {
      return null; // Файл не поддерживается
    }

    // 2. Если расширение ок, пытаемся определить mimeType через библиотеку
    // Если библиотека не справится, возвращаем дефолтный тип на основе наших списков
    final mime = lookupMimeType(filePath);
    if (mime != null) return mime;

    // 3. Фолбэк (запасной вариант), если lookupMimeType вернул null, но расширение в нашем списке
    if (videoExtensions.contains(ext)) return 'video/mp4';
    if (photoExtensions.contains(ext)) return 'image/jpeg';
    if (audioExtensions.contains(ext)) return 'audio/m4a';

    return null;
  }

  static AttachmentType? getAttachmentType(String filePath) {
    // Получаем расширение в нижнем регистре
    final extension = p.extension(filePath).toLowerCase();

    if (videoExtensions.contains(extension)) {
      return AttachmentType.video;
    } else if (photoExtensions.contains(extension)) {
      return AttachmentType.photo;
    }

    return null;
  }

  static Future<String?> generatePreview(String path) async {
    if (path.isEmpty) return null;

    final uint8list = await VideoThumbnail.thumbnailFile(
      video: path,
      thumbnailPath: (await getTemporaryDirectory()).path,
      imageFormat: ImageFormat.JPEG,
      maxHeight: 1080,
      quality: 80,
    );

    return uint8list.path;
  }

  static Future<int> getFileSize(String path) async {
    final file = File(path);

    final int bytes = await file.length();

    return bytes;
  }

  /// Извлекает имя файла без расширения
  /// Пример: "my_photo.jpg" -> "my_photo"
  static String getFileNameWithoutExtension(String fileName) {
    return p.basenameWithoutExtension(fileName);
  }

  /// Извлекает расширение файла без точки
  /// Пример: "my_photo.jpg" -> "jpg"
  static String getFileExtension(String fileName) {
    String extension = p.extension(fileName);
    if (extension.startsWith('.')) {
      return extension.substring(1);
    }
    return extension;
  }

  static Future<Duration> getVideoDuration(String path) async {
    final controller = VideoPlayerController.file(File(path));

    try {
      await controller.initialize();
      return controller.value.duration;
    } catch (e) {
      print("Ошибка при получении длительности: $e");
      return Duration.zero;
    } finally {
      await controller.dispose();
    }
  }
}