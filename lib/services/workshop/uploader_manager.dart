import 'dart:io';

import 'package:dia_room/api/workshop_api.dart';
import 'package:dia_room/contracts/workshop/requests/creating_item_photo.dart';
import 'package:dia_room/contracts/workshop/requests/updating_item_status.dart';
import 'package:dia_room/contracts/workshop/responses/creating_item_photo.dart' as resp;
import 'package:dia_room/contracts/workshop/responses/creating_item_video.dart' as respVideo;
import 'package:dia_room/models/enums/workshop/item_status.dart';
import 'package:dia_room/models/enums/workshop/item_type.dart';
import 'package:dia_room/models/enums/workshop/mime_type.dart';
import 'package:dia_room/utils/compress_image_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter_image_compress/flutter_image_compress.dart';
import 'package:get_thumbnail_video/index.dart';
import 'package:get_thumbnail_video/video_thumbnail.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';
import 'package:video_player/video_player.dart';

import '../../configuration/constants.dart';
import '../../contracts/workshop/requests/creating_item_video.dart';

class UploaderManager extends ChangeNotifier{
  bool _isUploading = false;
  double _progress = 0.0;

  bool get isUploading => _isUploading;
  double get progress => _progress;

  set isUploading(bool value) {
    _isUploading = value;
    notifyListeners();
  }

  set progress(double value) {
    _progress = value;
    notifyListeners();
  }

  UploaderManager();

  Future<String?> generatePreview(String path) async {
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

  Future<int> getFileSize(String path) async {
    final file = File(path);

    final int bytes = await file.length();

    return bytes;
  }

  /// Извлекает имя файла без расширения
  /// Пример: "my_photo.jpg" -> "my_photo"
  String getFileNameWithoutExtension(String fileName) {
    return p.basenameWithoutExtension(fileName);
  }

  /// Извлекает расширение файла без точки
  /// Пример: "my_photo.jpg" -> "jpg"
  String getFileExtension(String fileName) {
    String extension = p.extension(fileName);
    if (extension.startsWith('.')) {
      return extension.substring(1);
    }
    return extension;
  }

  Future<Duration> getVideoDuration(String path) async {
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

  Future<bool> uploadVideos({
    required List<XFile> files,
    required String? folderId
}) async {
    print("Началась загрузка видео");
    progress = 0;
    isUploading = true;

    int completedCount = 0;

    for (int i=0; i<files.length; i++) {
      String? previewPathOriginal;
      String? previewPathCompressed;

      try {
        final file = files[i];

        print('Итерация $i началась}');
        print("Получение размера видео...");
        // Получаем размер видео
        final size = await getFileSize(file.path);
        if (size > MAX_SIZE_VIDEO_WORKSHOP) {
          print("Видео $i не может быть загружено, т.к. оно весит больше 200 мб");
          completedCount++;
          progress = completedCount / files.length;
          continue;
        }

        print("Генерация превью...");
        // Генерируем превью
        previewPathOriginal = await generatePreview(file.path);
        if (previewPathOriginal == null) {
          print("Не удалось сгенерировать превью для $i");
          completedCount++;
          progress = completedCount / files.length;
          continue;
        }

        print("Сжатие превью...");
        // Сжатие превью
        previewPathCompressed =  await CompressImageService
            .compressForPreview(XFile(previewPathOriginal));
        if (previewPathCompressed == null) {
          print("Не удалось сжать превью для $i");
          completedCount++;
          progress = completedCount / files.length;
          continue;
        }

        print("Выполнение запроса...");
        // Формируем объект для запроса
        final ext = getFileExtension(file.name);
        final name = getFileNameWithoutExtension(file.name);

        final Duration duration = await getVideoDuration(file.path);

        final MimeType mime = ext == "mp4" ? MimeType.videoMP4 : MimeType.videoMP4;

        final CreatingItemVideo itemCreating = CreatingItemVideo(
            title: name,
            mimeType: mime,
            folderId: folderId,
            sizeBytes: size,
            itemType: ItemType.video,
            duration: duration,
        );

        // Отправляем запрос на создание
        final response = await createItemVideo(item: itemCreating);
        if (!response.success) {
          print("Не удалось создать видео $i");
          completedCount++;
          progress = completedCount / files.length;
          continue;
        }

        // Парсим ответ
        final respVideo.CreatingItemVideo responseData = respVideo.CreatingItemVideo.fromMap(response.data);

        print("Загрузка превью...");
        // Загружаем данные
        final resultPreview = await uploadSingleMediaFile(
            previewPathCompressed, responseData.presignedUrlPreview,
            'image/jpeg');
        if (!resultPreview) {
          print("Не удалось загрузить прервью для видео:");
          print("Путь Превью: $previewPathCompressed, Ссылка: ${responseData.presignedUrlPreview}, Mime: image/jpeg");
          await updateItem(item: UpdatingItemStatus(
              itemId: responseData.itemId, status: ItemStatus.failed));
        }
        print("Загрузка видео...");
        final resultOriginal = await uploadSingleMediaFile(
            file.path, responseData.presignedUrlOriginal,
            itemCreating.mimeType.mimeType);
        if (!resultOriginal) {
          print("Не удалось загрузить прервью по ссылке:");
          print("Путь Превью: $file.path, Ссылка: ${responseData
              .presignedUrlOriginal}, Mime: ${itemCreating.mimeType.mimeType}");
          await updateItem(item: UpdatingItemStatus(
              itemId: responseData.itemId, status: ItemStatus.failed));
        }

        // Обноавляем статус
        await updateItem(item: UpdatingItemStatus(
            itemId: responseData.itemId, status: ItemStatus.ready));

        completedCount++;
        progress = completedCount / files.length;
      } catch (e) {
        print('Возникла ошибка на $i. Ошибка: $e');
        completedCount++;
        progress = completedCount / files.length;
      } finally {
        final sourceFile = File(files[i].path);
        final tempDir = await getTemporaryDirectory();
        if (sourceFile.path.startsWith(tempDir.path)) {
          await sourceFile.delete();
        } else {
          print("Файл находится вне временной папки, пропускаю удаление: ${sourceFile.path}");
        }

        if (previewPathOriginal != null) {
          final f = File(previewPathOriginal);
          if (await f.exists()) await f.delete();
        }

        if (previewPathCompressed != null) {
          final f = File(previewPathCompressed);
          if (await f.exists()) await f.delete();
        }
      }
    }
    isUploading = false;
    return true;
  }

  Future<bool> uploadPhotos({
    required List<XFile> files,
    required String? folderId
  }) async {
    print("Началась загрузка изображений");
    progress = 0;
    isUploading = true;

    int completedCount = 0;

    for(int i=0; i<files.length; i++) {
      String? pathPreview;
      String? pathOriginal;
      try {
        final file = files[i];
        print('Исходный размер: ${await File(file.path).length() / 1048576}');


        final title = p.basenameWithoutExtension(file.name);

        // Сжимаем изображение и контролируем размер
        pathPreview = await CompressImageService
            .compressForPreview(files[i]);
        if (pathPreview == null) {
          print("Не удалось создать превью для изображения $i. Пропущено.");
          completedCount++;
          progress = completedCount / files.length;
          continue;
        }
        print('Итоговый размер превью: ${await File(pathPreview).length() /
            1048576}');

        pathOriginal = await CompressImageService
            .compressForOriginal(files[i]);
        if (pathOriginal == null) {
          print("Не удалось создать оригинал для изображения $i. Пропущеною");
          completedCount++;
          progress = completedCount / files.length;
          continue;
        }
        print('Итоговый размер оригинала: ${await File(pathOriginal).length() /
            1048576}');


        // Формируем объект для запроса на создание item
        final size = await getFileSize(pathOriginal);

        final CreatingItemPhoto itemPhoto = CreatingItemPhoto(
            title: title,
            mimeType: MimeType.imageJpeg,
            folderId: folderId,
            sizeBytes: size,
            itemType: ItemType.photo);


        // Выполняем запрос на создание, ответ ссылки на загрузку и id поста
        final result = await createItemImage(item: itemPhoto);
        if (!result.success) {
          print("Не удалось создать фотографию $i");
          completedCount++;
          progress = completedCount / files.length;
          continue;
        }

        // Распаковывем ответ
        final response = resp.CreatingItemPhoto.fromMap(result.data);

        // Загружаем в хранилище фотографии
        final resultPreview = await uploadSingleMediaFile(
            pathPreview, response.presignedUrlPreview,
            itemPhoto.mimeType.mimeType);
        if (!resultPreview) {
          print("Не удалось загрузить прервью по ссылке:");
          print("Путь Превью: $pathPreview, Ссылка: ${response
              .presignedUrlPreview}, Mime: ${itemPhoto.mimeType.mimeType}");
          await updateItem(item: UpdatingItemStatus(
              itemId: response.itemId, status: ItemStatus.failed));
        }
        final resultOriginal = await uploadSingleMediaFile(
            pathOriginal, response.presignedUrlOriginal,
            itemPhoto.mimeType.mimeType);
        if (!resultOriginal) {
          print("Не удалось загрузить прервью по ссылке:");
          print("Путь Превью: $pathOriginal, Ссылка: ${response
              .presignedUrlOriginal}, Mime: ${itemPhoto.mimeType.mimeType}");
          await updateItem(item: UpdatingItemStatus(
              itemId: response.itemId, status: ItemStatus.failed));
        }

        // Обновляем статус
        await updateItem(item: UpdatingItemStatus(
            itemId: response.itemId, status: ItemStatus.ready));
        completedCount++;
        progress = completedCount / files.length;
      } catch (e) {
        print("Ошибка при загрузке: $e");
        completedCount++;
        progress = completedCount / files.length;
      } finally {
        if (pathPreview != null) {
          final f = File(pathPreview);
          if (await f.exists()) await f.delete();
        }
        if (pathOriginal != null) {
          final f = File(pathOriginal);
          if (await f.exists()) await f.delete();
        }

        final sourceFile = File(files[i].path);
        final tempDir = await getTemporaryDirectory();
        if (sourceFile.path.startsWith(tempDir.path)) {
          await sourceFile.delete();
        } else {
          print("Файл находится вне временной папки, пропускаю удаление: ${sourceFile.path}");
        }
      }
    }
    isUploading = false;
    return true;
  }
}