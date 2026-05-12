import 'dart:io';

import 'package:dia_room/contracts/diary/requests/creating_message.dart';
import 'package:dia_room/contracts/diary/requests/update_status_message.dart';
import 'package:dia_room/models/diary/selected_media.dart';
import 'package:dia_room/models/enums/diary/attachment_type.dart';
import 'package:dia_room/models/enums/diary/message_status.dart';
import 'package:dia_room/models/enums/diary/message_type.dart';
import 'package:dia_room/services/diary/diary_utils.dart';
import 'package:flutter/material.dart';
import 'package:flutter_image_compress/flutter_image_compress.dart';

import '../../api/diary_api.dart';
import '../../contracts/diary/response/creating_message_response.dart';
import '../../utils/compress_image_service.dart';

class UploadManager {

  Future<void> _deleteFiles({required List<String?> files}) async {
    try {
      for (int i=0; i<files.length; i++) {
        if (files[i] != null) {
          final f = File(files[i]!);
          if (await f.exists()) await f.delete();
        }
      }
    } catch (e) {
      print("Ошибка при фоновом удалении файлов");
    }

  }

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
      List<String?> deletingFiles = [];
      List<Map<String, dynamic>> mappedAttach = [];
      String? originalPath;
      String? previewPath;

      // Обработка медиафайлов
      if (media != null && media.isNotEmpty) {
        for (int i = 0; i < media.length; i++) {
          try {
            AttachmentCreating? attachmentCreating;
            final SelectedMedia mediaFile = media[i];
            deletingFiles.add(mediaFile.file.path);
            // Обработка фото
            if (mediaFile.type == AttachmentType.photo) {
              // Сжатие оригинала
              originalPath = await CompressImageService.compressForOriginal(
                XFile(mediaFile.file.path),
              );
              if (originalPath == null) {
                print('Не удалось сжать изображение');
                continue;
              }
              deletingFiles.add(originalPath);
              // Получение превью
              previewPath = await CompressImageService.compressForPreview(
                XFile(originalPath),
              );
              if (previewPath == null) {
                print('Не удалось создать превью изображения');
                continue;
              }
              deletingFiles.add(previewPath);
              // Получение размера и mimeType изображения
              final sizePhoto = await DiaryUtils.getFileSize(originalPath);
              final mimeType = DiaryUtils.getSupportedMimeType(originalPath);
              if (mimeType == null) {
                print('Не получить mimeType изображения');
                continue;
              }
              attachmentCreating = AttachmentCreating(
                attachmentType: mediaFile.type,
                fileSize: sizePhoto,
                mimeType: mimeType,
              );
            }

            // Обработка видео
            if (mediaFile.type == AttachmentType.video) {
              originalPath = mediaFile.file.path;
              // Сжимает превью
              previewPath = await CompressImageService.compressForPreview(
                XFile(mediaFile.thumbnail!),
              );
              if (previewPath == null) {
                print('Не удалось сжать превью видео');
                continue;
              }
              deletingFiles.add(previewPath);
              // Получаем длительность
              final duration = await DiaryUtils.getVideoDuration(
                mediaFile.file.path,
              );
              // Получаем размер файла
              final size = await DiaryUtils.getFileSize(mediaFile.file.path);
              // Получаем mimeType
              final mimeType = DiaryUtils.getSupportedMimeType(
                mediaFile.file.path,
              );
              if (mimeType == null) {
                print('Не удалось получить mimetype video $i');
                continue;
              }
              attachmentCreating = AttachmentCreating(
                attachmentType: mediaFile.type,
                fileSize: size,
                mimeType: mimeType,
                duration: duration,
              );
            }

            if (attachmentCreating != null) {
              attachments.add(attachmentCreating);
              mappedAttach.add({
                "originalPath": originalPath,
                "previewPath": previewPath,
                "mimeType": attachmentCreating.mimeType,
              });
            }
          } catch (e) {
            print('Ошибка во время обработки медиафайла $i');
          }
        }
      }
      if ((messageText == null || messageText.isEmpty) && attachments.isEmpty) {
        print(
          'Сообщение не создано, т.к. текст null или пустая строка, а список вложений пустой',
        );
        return;
      }
      // Когда прошли по списку для стандартного сообщения
      final CreatingMessage creatingMessage = CreatingMessage(
        type: type,
        text: messageText,
        attachments: attachments,
      );

      // Отправка запроса
      final response = await createMessage(message: creatingMessage);
      if (!response.success) {
        print('Не удалось создать сообщение');
        _deleteFiles(files: deletingFiles);
        return;
      }

      final MessageCreateResponse decodedResponse = MessageCreateResponse.fromMap(response.data);

      final gotUrls = decodedResponse.uploadItems;

      if (gotUrls.length != mappedAttach.length) {
        print('Не совпадает длина списков медиафайлов');
        _deleteFiles(files: deletingFiles);
        updateStatus(updatingMessage: UpdatingMessage(messageId: decodedResponse.messageId, status: MessageStatus.failed));
        return;
      }

      try {
        for (int i=0; i<gotUrls.length; i++) {
          final urls = gotUrls[i];
          // Для превью
          await uploadSingleMediaFile(mappedAttach[i]["previewPath"], urls.presignedPreviewUrl!, "image/jpeg");
          // Для файла
          await uploadSingleMediaFile(mappedAttach[i]["originalPath"], urls.presignedUrl, mappedAttach[i]["mimeType"]);
        }
        print("Все медиафайлы успешно загружены");
      } catch (e) {
        print("Возникла ошибка во время загрузки медиа $e");
        updateStatus(updatingMessage: UpdatingMessage(messageId: decodedResponse.messageId, status: MessageStatus.failed));
        return;
      } finally {
        _deleteFiles(files: deletingFiles);
      }

      updateStatus(updatingMessage: UpdatingMessage(messageId: decodedResponse.messageId, status: MessageStatus.sent));
    }
    return;
  }
}


