import 'dart:io';

import 'package:dia_room/api/workshop_api.dart';
import 'package:dia_room/contracts/workshop/requests/creating_item_photo.dart';
import 'package:dia_room/contracts/workshop/requests/updating_item_status.dart';
import 'package:dia_room/contracts/workshop/responses/creating_item_photo.dart' as resp;
import 'package:dia_room/models/enums/workshop/item_status.dart';
import 'package:dia_room/models/enums/workshop/item_type.dart';
import 'package:dia_room/models/enums/workshop/mime_type.dart';
import 'package:dia_room/utils/compress_image_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter_image_compress/flutter_image_compress.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';

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

  Future<int> getFileSize(String path) async {
    final file = File(path);

    final int bytes = await file.length();

    return bytes;
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
      try {
        print("Итерация $i. Путь: ${files[i].path}");
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