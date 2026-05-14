import 'dart:io';

import 'package:dia_room/contracts/diary/requests/creating_message.dart';
import 'package:dia_room/contracts/diary/requests/update_status_message.dart';
import 'package:dia_room/models/diary/selected_media.dart';
import 'package:dia_room/models/enums/diary/attachment_type.dart';
import 'package:dia_room/models/enums/diary/message_status.dart';
import 'package:dia_room/models/enums/diary/message_type.dart';
import 'package:dia_room/services/diary/diary_utils.dart';
import 'package:dia_room/services/diary/video_record_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_image_compress/flutter_image_compress.dart';

import '../../api/diary_api.dart';
import '../../contracts/diary/response/creating_message_response.dart';
import '../../contracts/diary/response/getting_messages.dart';
import '../../contracts/diary/response/updating_status.dart';
import '../../screens/diary/audio_record_screen.dart';
import '../../utils/compress_image_service.dart';

class UploadManager extends ChangeNotifier {
  bool _isUploading = false;
  bool get isUploading => _isUploading;

  double _progress = 0;
  double get progress => _progress;

  void updateProgress(double value) {
    _progress = value;
    notifyListeners();
  }

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
    VideoRecordResult? videoNote,
    String? linkWorkshop,
    VoiceRecordResult? audioNote,
    VoidCallback? onSuccess,
    void Function(MessagePresentation)? addMessageCallback,
  }) async {
    if (_isUploading) return;

    _isUploading = true;
    updateProgress(0);

    List<String?> deletingFiles = [];

    try {
      // Создание обычного сообщения с медиа
      if (type == MessageType.standard) {
        List<AttachmentCreating> attachments = [];
        List<Map<String, dynamic>> mappedAttach = [];
        String? originalPath;
        String? previewPath;

        // Обработка медиафайлов
        if (media != null && media.isNotEmpty) {
          updateProgress(0.1);
          for (int i = 0; i < media.length; i++) {
            try {
              double stepProgress = 0.1 + (i / media.length) * 0.3;
              updateProgress(stepProgress);
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
        updateProgress(0.5);
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
          workshopFolderId: linkWorkshop,
        );

        updateProgress(0.6);
        // Отправка запроса
        final response = await createMessage(message: creatingMessage);
        if (!response.success) {
          print('Не удалось создать сообщение');
          return;
        }

        final MessageCreateResponse decodedResponse = MessageCreateResponse.fromMap(response.data);

        final gotUrls = decodedResponse.uploadItems;

        if (gotUrls.length != mappedAttach.length) {
          print('Не совпадает длина списков медиафайлов');
          updateStatus(updatingMessage: UpdatingMessage(messageId: decodedResponse.messageId, status: MessageStatus.failed));
          return;
        }
        updateProgress(0.65);

        try {
          for (int i=0; i<gotUrls.length; i++) {
            final step = 0.65 + (i/gotUrls.length) * 0.25;
            updateProgress(step);
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
        }
        updateProgress(0.95);
        final responseStatus = await updateStatus(updatingMessage: UpdatingMessage(messageId: decodedResponse.messageId, status: MessageStatus.sent));
        if (!responseStatus.success) {
          print('Не удалось обновить статус сообщения');
        }
        final UpdatingStatus newMessage = UpdatingStatus.fromMap(responseStatus.data);
        if (newMessage.messagePresentation == null) {
          return;
        }

        updateProgress(0.99);
        if (addMessageCallback != null) {
          addMessageCallback(newMessage.messagePresentation!);
        }

      }
      if (type == MessageType.voiceNote) {
        const mimeType = 'audio/m4a';
        if (audioNote == null) {
          return;
        }
        deletingFiles.add(audioNote.path);
        // Получаем размер
        final fileSize = await DiaryUtils.getFileSize(audioNote.path);
        updateProgress(0.2);

        // Формируем запрос
        final AttachmentCreating attachmentCreating = AttachmentCreating(
            attachmentType: AttachmentType.voiceNote,
            duration: audioNote.duration,
            fileSize: fileSize,
            mimeType: mimeType);

        final CreatingMessage creatingMessage = CreatingMessage(
          type: type,
          attachments: [attachmentCreating],
        );

        print("${creatingMessage.toMap()}");
        updateProgress(0.4);

        // // Выполняем запрос
        final response = await createMessage(message: creatingMessage);

        if (!response.success) {
          print('Ответ пришел отрицательный при создании');
          return;
        }
        updateProgress(0.6);

        final MessageCreateResponse data = MessageCreateResponse.fromMap(response.data);

        if (data.uploadItems.isEmpty || data.uploadItems.length != 1) {
          print('Ошибка при получении аттача');
          return;
        }
        final AttachmentUploadItem audioUrls = data.uploadItems[0];

        // Загружаем в хранилище
        final responseAttach = await uploadSingleMediaFile(audioNote.path, audioUrls.presignedUrl, mimeType);
        if (!responseAttach) {
          print('Не удалось загрузить файл в хранилище');
          updateStatus(updatingMessage: UpdatingMessage(messageId: data.messageId, status: MessageStatus.failed));
          return;
        }
        updateProgress(0.8);

        // Обновляем статус
        final responseStatus = await updateStatus(updatingMessage: UpdatingMessage(messageId: data.messageId, status: MessageStatus.sent));
        if (!responseStatus.success) {
          print('Не удалось обновить статус сообщения');
        }

        if (responseStatus.data == null) {
          print('Пришло пустое тело на обновление статуса');
          return;
        }
        final newMessage = UpdatingStatus.fromMap(responseStatus.data);

        // Если все прошло хорошо, добавляем в список результат
        if (addMessageCallback != null && newMessage.messagePresentation != null) {
          addMessageCallback(newMessage.messagePresentation!);
        }

        print('Аудиосообщение создано и добавлено');

      }
      if (type == MessageType.videoNote) {
        const mimeType = 'video/mp4';
        if (videoNote == null) {
          return;
        }
        deletingFiles.add(videoNote.path);
        updateProgress(0.2);

        // Формируем превью
        final pathPreview = await DiaryUtils.generatePreview(videoNote.path, quality: 50, maxHeight: 720);
        if (pathPreview != null) {
          deletingFiles.add(pathPreview);
        } else {
          print("Не удалось создать превью для видеозаметки");
          return;
        }

        // Формируем запрос
        final AttachmentCreating attachmentCreating = AttachmentCreating(
            attachmentType: AttachmentType.videoNote,
            duration: videoNote.duration,
            fileSize: videoNote.sizeInBytes,
            mimeType: mimeType);

        final CreatingMessage creatingMessage = CreatingMessage(
          type: type,
          attachments: [attachmentCreating],
        );

        print("${creatingMessage.toMap()}");
        updateProgress(0.4);

        // // Выполняем запрос
        final response = await createMessage(message: creatingMessage);

        if (!response.success) {
          print('Ответ пришел отрицательный при создании');
          return;
        }
        updateProgress(0.6);

        final MessageCreateResponse data = MessageCreateResponse.fromMap(response.data);

        if (data.uploadItems.isEmpty || data.uploadItems.length != 1) {
          print('Ошибка при получении аттача');
          return;
        }
        final AttachmentUploadItem videoUrls = data.uploadItems[0];

        // Загружаем в хранилище видео
        final responseAttach = await uploadSingleMediaFile(videoNote.path, videoUrls.presignedUrl, mimeType);
        if (!responseAttach) {
          print('Не удалось загрузить файл в хранилище');
          updateStatus(updatingMessage: UpdatingMessage(messageId: data.messageId, status: MessageStatus.failed));
          return;
        }
        updateProgress(0.7);
        // Загружаем в хранилище превью
        final responsePreview = await uploadSingleMediaFile(pathPreview, videoUrls.presignedPreviewUrl!, "image/jpeg");
        if (!responsePreview) {
          print('Не удалось загрузить файл в хранилище');
          updateStatus(updatingMessage: UpdatingMessage(messageId: data.messageId, status: MessageStatus.failed));
          return;
        }
        updateProgress(0.8);

        // Обновляем статус
        final responseStatus = await updateStatus(updatingMessage: UpdatingMessage(messageId: data.messageId, status: MessageStatus.sent));
        if (!responseStatus.success) {
          print('Не удалось обновить статус сообщения');
        }

        if (responseStatus.data == null) {
          print('Пришло пустое тело на обновление статуса');
          return;
        }
        final newMessage = UpdatingStatus.fromMap(responseStatus.data);

        // Если все прошло хорошо, добавляем в список результат
        if (addMessageCallback != null && newMessage.messagePresentation != null) {
          addMessageCallback(newMessage.messagePresentation!);
        }

        print('Видеосообщение создано и добавлено');
      }
    } catch (e) {
      print("Ошибка фоновой загрузки: $e");
    } finally {
      _deleteFiles(files: deletingFiles);
      print('Файлы медиа удалены');
      _isUploading = false;
      notifyListeners();
    }

  }
}



