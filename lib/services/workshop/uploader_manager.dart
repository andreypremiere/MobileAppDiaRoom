import 'dart:io';

import 'package:dia_room/api/workshop_api.dart';
import 'package:dia_room/contracts/workshop/requests/creating_item_photo.dart';
import 'package:dia_room/contracts/workshop/requests/updating_item_status.dart';
import 'package:dia_room/contracts/workshop/responses/creating_item_photo.dart' as resp;
import 'package:dia_room/models/enums/workshop/item_status.dart';
import 'package:dia_room/models/enums/workshop/item_type.dart';
import 'package:dia_room/models/enums/workshop/mime_type.dart';
import 'package:dia_room/utils/compress_image_service.dart';
import 'package:flutter_image_compress/flutter_image_compress.dart';
import 'package:path/path.dart' as p;

class UploaderManager {

  static Future<int> getFileSize(String path) async {
    final file = File(path);

    final int bytes = await file.length();

    return bytes;
  }

  static Future<bool> uploadPhotos({
    required List<XFile> files,
    required String? folderId
  }) async {
    print("Началась загрузка изображений");

    for(int i=0; i<files.length; i++) {
      final file = files[i];
      print('Исходный размер: ${await File(file.path).length() / 1048576}');


      final title = p.basenameWithoutExtension(file.name);

      // Сжимаем изображение и контролируем размер
      final String? pathPreview = await CompressImageService.compressForPreview(files[i]);
      if (pathPreview == null) {
        print("Не удалось создать превью для изображения $i. Пропущено.");
        continue;
      }
      print('Итоговый размер превью: ${await File(pathPreview).length() / 1048576}');

      final String? pathOriginal = await CompressImageService.compressForOriginal(files[i]);
      if (pathOriginal == null) {
        print("Не удалось создать оригинал для изображения $i. Пропущеною");
        continue;
      }
      print('Итоговый размер оригинала: ${await File(pathOriginal).length() / 1048576}');


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
        continue;
      }

      // Распаковывем ответ
      final response = resp.CreatingItemPhoto.fromMap(result.data);

      // Загружаем в хранилище фотографии
      final resultPreview = await uploadSingleMediaFile(pathPreview, response.presignedUrlPreview, itemPhoto.mimeType.mimeType);
      if (!resultPreview) {
        print("Не удалось загрузить прервью по ссылке:");
        print("Путь Превью: $pathPreview, Ссылка: ${response.presignedUrlPreview}, Mime: ${itemPhoto.mimeType.mimeType}");
        await updateItem(item: UpdatingItemStatus(itemId: response.itemId, status: ItemStatus.failed));
      }
      final resultOriginal = await uploadSingleMediaFile(pathOriginal, response.presignedUrlOriginal, itemPhoto.mimeType.mimeType);
      if (!resultOriginal) {
        print("Не удалось загрузить прервью по ссылке:");
        print("Путь Превью: $pathOriginal, Ссылка: ${response.presignedUrlOriginal}, Mime: ${itemPhoto.mimeType.mimeType}");
        await updateItem(item: UpdatingItemStatus(itemId: response.itemId, status: ItemStatus.failed));
      }

      // Обновляем статус
      await updateItem(item: UpdatingItemStatus(itemId: response.itemId, status: ItemStatus.ready));
    }
    return true;
  }
}