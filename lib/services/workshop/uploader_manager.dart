import 'dart:io';

import 'package:dia_room/api/workshop_api.dart';
import 'package:dia_room/contracts/workshop/requests/creating_item_photo.dart';
import 'package:dia_room/contracts/workshop/requests/updating_item_status.dart';
import 'package:dia_room/contracts/workshop/responses/creating_item_photo.dart' as resp;
import 'package:dia_room/contracts/workshop/responses/creating_item_video.dart' as respVideo;
import 'package:dia_room/models/enums/workshop/item_status.dart';
import 'package:dia_room/models/enums/workshop/item_type.dart';
import 'package:dia_room/models/enums/workshop/mime_type.dart';
import 'package:dia_room/models/workshop/item.dart';
import 'package:dia_room/services/diary/diary_utils.dart';
import 'package:dia_room/utils/compress_image_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter_image_compress/flutter_image_compress.dart';
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
      return Duration.zero;
    } finally {
      await controller.dispose();
    }
  }

  Future<bool> uploadVideos({
    required List<XFile> files,
    required String? folderId
}) async {
    progress = 0;
    isUploading = true;

    int completedCount = 0;

    for (int i=0; i<files.length; i++) {
      String? previewPathOriginal;
      String? previewPathCompressed;

      try {
        final file = files[i];

        // Получаем размер видео
        final size = await DiaryUtils.getFileSize(file.path);
        if (size > MAX_SIZE_VIDEO_WORKSHOP) {
          completedCount++;
          progress = completedCount / files.length;
          continue;
        }

        // Генерируем превью
        previewPathOriginal = await DiaryUtils.generatePreview(file.path);
        if (previewPathOriginal == null) {
          completedCount++;
          progress = completedCount / files.length;
          continue;
        }

        // Сжатие превью
        previewPathCompressed =  await CompressImageService
            .compressForPreview(XFile(previewPathOriginal));
        if (previewPathCompressed == null) {
          completedCount++;
          progress = completedCount / files.length;
          continue;
        }

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
          completedCount++;
          progress = completedCount / files.length;
          continue;
        }

        // Парсим ответ
        final respVideo.CreatingItemVideo responseData = respVideo.CreatingItemVideo.fromMap(response.data);

        // Загружаем данные
        final resultPreview = await uploadSingleMediaFile(
            previewPathCompressed, responseData.presignedUrlPreview,
            'image/jpeg');
        if (!resultPreview) {
          await updateItem(item: UpdatingItemStatus(
              itemId: responseData.itemId, status: ItemStatus.failed));
        }
        final resultOriginal = await uploadSingleMediaFile(
            file.path, responseData.presignedUrlOriginal,
            itemCreating.mimeType.mimeType);
        if (!resultOriginal) {
          await updateItem(item: UpdatingItemStatus(
              itemId: responseData.itemId, status: ItemStatus.failed));
        }

        // Обноавляем статус
        await updateItem(item: UpdatingItemStatus(
            itemId: responseData.itemId, status: ItemStatus.ready));

        completedCount++;
        progress = completedCount / files.length;
      } catch (e) {
        completedCount++;
        progress = completedCount / files.length;
      } finally {
        final sourceFile = File(files[i].path);
        final tempDir = await getTemporaryDirectory();
        if (sourceFile.path.startsWith(tempDir.path)) {
          await sourceFile.delete();
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

  Future<void> uploadPhotos({
    required List<XFile> files,
    required String? folderId,
    required Function(Item item) addPhoto
  }) async {
    progress = 0;
    isUploading = true;

    int completedCount = 0;

    for(int i=0; i<files.length; i++) {
      String? pathPreview;
      String? pathOriginal;
      try {
        final file = files[i];

        final title = p.basenameWithoutExtension(file.name);

        pathOriginal = await CompressImageService
            .compressForOriginal(files[i]);
        if (pathOriginal == null) {
          completedCount++;
          progress = completedCount / files.length;
          continue;
        }

        pathPreview = await CompressImageService
            .compressForPreview(XFile(pathOriginal));
        if (pathPreview == null) {
          completedCount++;
          progress = completedCount / files.length;
          continue;
        }

        final size = await DiaryUtils.getFileSize(pathOriginal);

        // Формируем объект для запроса на создание item

        final CreatingItemPhoto itemPhoto = CreatingItemPhoto(
            title: title,
            mimeType: MimeType.imageJpeg,
            folderId: folderId,
            sizeBytes: size,
            itemType: ItemType.photo);


        // Выполняем запрос на создание, ответ: ссылки на загрузку и id поста
        final result = await createItemImage(item: itemPhoto);
        if (!result.success) {
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
          await updateItem(item: UpdatingItemStatus(
              itemId: response.itemId, status: ItemStatus.failed));
        }
        final resultOriginal = await uploadSingleMediaFile(
            pathOriginal, response.presignedUrlOriginal,
            itemPhoto.mimeType.mimeType);
        if (!resultOriginal) {
          await updateItem(item: UpdatingItemStatus(
              itemId: response.itemId, status: ItemStatus.failed));
        }

        // Обновляем статус
        final resultUpdatedStatus = await updateItem(item: UpdatingItemStatus(
            itemId: response.itemId, status: ItemStatus.ready));
        
        if (resultUpdatedStatus.success) {
          response.item.status = ItemStatus.ready;
          addPhoto(response.item);
        }
        
        completedCount++;
        progress = completedCount / files.length;
      } catch (e) {
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
        }
      }
    }
    isUploading = false;
  }
}