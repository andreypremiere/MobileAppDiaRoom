import 'dart:io';

import 'package:dia_room/api/auth_response.dart';
import 'package:dia_room/contracts/posts_v2/requests/creating_post.dart';
import 'package:dia_room/contracts/posts_v2/requests/media_file_item.dart';
import 'package:dia_room/contracts/posts_v2/requests/media_metadata.dart';
import 'package:dia_room/contracts/posts_v2/responses/post_response.dart';
import 'package:dia_room/models/enums/post_v2/post_media_status.dart';
import 'package:dia_room/models/enums/post_v2/post_status.dart';
import 'package:image_size_getter/file_input.dart';
import 'package:image_size_getter/image_size_getter.dart';
import 'package:mime/mime.dart';
import 'package:dia_room/api/post_v2_api.dart' as api;
import 'package:dia_room/utils/dio_service.dart';

import '../../contracts/posts_v2/requests/updating_media_post_status.dart';
import '../../contracts/posts_v2/requests/updating_post_status.dart';
import '../../contracts/posts_v2/responses/post_create_response.dart';
import '../../models/post_v2/media_size_result.dart';
import '../../models/post_v2/post_v2_draft.dart';

class MediaService {
  Future<int?> getFileSizeBytes(String filePath) async {
    try {
      final file = File(filePath);
      if (!await file.exists()) {
        throw Exception("Файл не найден по пути: $filePath");
      }
      return await file.length();
    } catch (e) {
      print("Ошибка при получении размера файла: $e");
      return null;
    }
  }

  Future<MediaSizeResult?> getImageDimensions(String filePath) async {
    try {
      final file = File(filePath);
      if (!await file.exists()) {
        throw Exception("Файл не найден по пути: $filePath");
      }

      // Используем getSizeResult вместо устаревшего getSize
      final sizeResult = ImageSizeGetter.getSizeResult(FileInput(file));

      return MediaSizeResult(
        width: sizeResult.size.width,
        height: sizeResult.size.height,
      );
    } catch (e) {
      print("Ошибка при получении разрешения изображения: $e");
      // Возвращаем дефолтные значения в случае сбоя
      return null;
    }
  }

  Future<String?> getMimeType(String filePath) async {
    try {
      // lookupMimeType берет на себя всю работу: анализирует расширение
      // и, если нужно, может даже проверить магические байты заголовка.
      final mimeType = lookupMimeType(filePath);

      // Если библиотека не смогла определить тип, возвращаем безопасный дефолт
      return mimeType;
    } catch (e) {
      print("Ошибка при определении MimeType через lookupMimeType: $e");
      return null;
    }
  }
}

class PostV2UploaderManager {
  Future<AuthResponse> createPost(PostV2Draft draft) async {
    final mediaService = MediaService();
    final List<MediaFileItem> listMediaFileItem = [];

    // Формируес список фото для запроса
    for (int i=0; i < draft.imagesPaths.length; i++) {
      final path = draft.imagesPaths[i];

      // Определяем разрешение
      final resolution = await mediaService.getImageDimensions(path);
      if (resolution == null) {
        return AuthResponse(success: false, message: "Не удалось получить разрешение фотографии под номером ${i+1}");
      }

      // Определяем размер
      final fileSize = await mediaService.getFileSizeBytes(path);
      if (fileSize == null) {
        return AuthResponse(success: false, message: "Не удалось получить размер фотографии под номером ${i+1}");
      }

      // Определяем mimeType
      final mimeType = await mediaService.getMimeType(path);
      if (mimeType == null) {
        return AuthResponse(success: false, message: "Не удалось определить MimeType фотографии под номером ${i+1}");
      }

      final mediaFileItem = MediaFileItem(
          order: i,
          fileSizeBytes: fileSize,
          metadata: MediaMetadata(
              width: resolution.width,
              height: resolution.height,
              mimeType: mimeType
          )
      );

      listMediaFileItem.add(mediaFileItem);
    }



    // Формируем запрос для создания
    final newPost = PostCreateRequest(
        description: draft.description,
        hashtags: draft.hashtags,
        workshopLink: draft.workshopLinkId,
        articleLink: draft.articleLinkId,
        files: listMediaFileItem);

    final response = await api.createPost(post: newPost);
    if (!response.success) {
      return response;
    }

    final PostCreateResponse responseData = PostCreateResponse.fromMap(response.data);

    // Параллельная загрузка файлов в s3
    final String postId = responseData.post.id;
    bool hasUploadErrors = false;

    // Создаем список асинхронных задач (Futures)
    final List<Future<void>> uploadTasks = [];

    for (final uploadItem in responseData.uploadItems) {
      // Находим локальный путь к файлу по его индексу (order)
      final String localPath = draft.imagesPaths[uploadItem.order];
      final File file = File(localPath);

      // Достаем сохраненный mimeType для передачи в S3 заголовки
      final String contentType = listMediaFileItem[uploadItem.order].metadata.mimeType;

      // Формируем задачу для конкретного файла
      final task = ApiService.putBinaryFile(
        url: uploadItem.presignedUrl,
        file: file,
        contentType: contentType,
      ).then((s3Response) {
        // Проверяем успешность статус-кода от S3/MinIO (должен быть 200 OK)
        if (s3Response.statusCode != 200) {
          throw Exception("S3 вернул статус-код ${s3Response.statusCode}");
        }
      }).catchError((error) async {
        try {
          // Если этот конкретный файл упал при загрузке:
          hasUploadErrors = true;
          print("Ошибка загрузки файла ${uploadItem.order} в S3: $error");

          final failedFile = responseData.post.files.firstWhere(
                (file) => file.order == uploadItem.order,
          );

          final UpdatingMediaPostStatus updatingStatus = UpdatingMediaPostStatus(
              id: failedFile.id,
              status: MediaStatus.failed
          );

          // Сразу пинаем бэкенд, что этот файл сломался
          await api.updateMediaStatus(mediaStatus: updatingStatus);
        } catch (e) {
          print("Не удалось обновить статусы при ошибке загрузки;");
        }
      });

      // Добавляем задачу в общий пул параллельного выполнения
      uploadTasks.add(task);
    }

    // Запускаем все загрузки одновременно и ждем завершения задач
    await Future.wait(uploadTasks);

    // ==========================================
    // ФИНАЛЬНЫЙ СТАТУС ПОСТА
    // ==========================================
    if (hasUploadErrors) {
      final UpdatingPostStatus updatingPost = UpdatingPostStatus(
        id: postId,
        status: PostStatus.error
      );

      await api.updatePostStatus(postStatus: updatingPost);
      return AuthResponse(
        success: false,
        message: "Часть файлов не удалось загрузить в хранилище. Пост переведен в статус ошибки.",
      );
    } else {
      final UpdatingPostStatus updatingPost = UpdatingPostStatus(
          id: postId,
          status: PostStatus.processing
      );

      await api.updatePostStatus(postStatus: updatingPost);
      return AuthResponse(
        success: true,
        data: PostResponse.fromPostCreateResponse(responseData.post, responseData.statistic),
        message: "Пост успешно создан и отправлен на обработку.",
      );
    }
  }
}