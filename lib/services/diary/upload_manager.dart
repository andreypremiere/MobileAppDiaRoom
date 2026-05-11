import 'package:dia_room/contracts/diary/requests/creating_message.dart';
import 'package:dia_room/models/diary/selected_media.dart';
import 'package:dia_room/models/enums/diary/attachment_type.dart';
import 'package:dia_room/models/enums/diary/message_type.dart';
import 'package:dia_room/services/diary/diary_utils.dart';
import 'package:flutter/material.dart';
import 'package:flutter_image_compress/flutter_image_compress.dart';

import '../../utils/compress_image_service.dart';



class UploadManager extends ChangeNotifier{

  Future<void> addMessage({
    required MessageType type,
    String? messageText,
    List<SelectedMedia>? media,
    String? videoNotePath,
    String? audioNotePath,
  }) async {
    // Создание обычного сообщения с медиа
    if (type == MessageType.standard) {
      List<AttachmentCreating> attachments = [];

      // Обработка медиафайлов
      if (media != null && media.isNotEmpty) {
        for (int i = 0; i < media.length; i++) {
          try {
            AttachmentCreating? attachmentCreating;
            final SelectedMedia mediaFile = media[i];
            // Обработка фото
            if (mediaFile.type == AttachmentType.photo) {
              // Сжатие оригинала
              final originalPath = await CompressImageService.compressForOriginal(XFile(mediaFile.file.path));
              if (originalPath == null) {
                print('Не удалось сжать изображение');
                continue;
              }
              // Получение превью
              final previewPath = await CompressImageService.compressForPreview(XFile(originalPath));
              if (previewPath == null) {
                print('Не удалось создать превью изображения');
                continue;
              }
              // Получение размера и mimeType изображения
              final sizePhoto = await DiaryUtils.getFileSize(originalPath);
              final mimeType = DiaryUtils.getSupportedMimeType(originalPath);
              if (mimeType == null) {
                print('Не получить mimeType изображения');
                continue;
              }
              attachmentCreating = AttachmentCreating(attachmentType: mediaFile.type, fileSize: sizePhoto, mimeType: mimeType);
            }

            // Обработка видео
            if (mediaFile.type == AttachmentType.video) {
              // Сжимает превью
              final compressedPreview = await CompressImageService.compressForPreview(XFile(mediaFile.thumbnail!));
              if (compressedPreview == null) {
                print('Не удалось сжать превью видео');
                continue;
              }
              // Получаем длительность
              final duration = await DiaryUtils.getVideoDuration(mediaFile.file.path);
              // Получаем размер файла
              final size = await DiaryUtils.getFileSize(mediaFile.file.path);
              // Получаем mimeType
              final mimeType = DiaryUtils.getSupportedMimeType(mediaFile.file.path);
              if (mimeType == null) {
                print('Не удалось получить mimetype video $i');
                continue;
              }
              attachmentCreating = AttachmentCreating(attachmentType: mediaFile.type, fileSize: size, mimeType: mimeType, duration: duration);
            }

            if (attachmentCreating != null) {
              attachments.add(attachmentCreating);
            }
          } catch (e) {
            print('Ошибка во время обработки медиафайла $i');
          }

        }
      }
      if ((messageText == null || messageText.isEmpty) && attachments.isEmpty) {
        print('Сообщение не создано, т.к. текст null или пустая строка, а список вложений пустой');
        return;
      }
      // Когда прошли по списку для стандартного сообщения
      final CreatingMessage creatingMessage = CreatingMessage(type: type, text: messageText, attachments: attachments);

      // Отправка запроса и загрузка медиа после ответа

      // После загрузки медиа удалить медиафайлы
      print('Сообщение для отправки: ${creatingMessage.toMap()}');

    }
    return;
  }
}
