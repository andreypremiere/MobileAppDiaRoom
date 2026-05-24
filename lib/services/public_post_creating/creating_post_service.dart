// Здесь будет класс, который будет выполнять полный цикл
// публикации поста, от начала конфигурации данных, заканчивая
// статусом, что пост опубликован и отправкой уведомления

import 'dart:io';

import 'package:camera/camera.dart';
import 'package:dia_room/api/auth_response.dart';
import 'package:dia_room/models/post_creator/block_photos.dart';
import 'package:dia_room/models/post_creator/block_post.dart';
import 'package:dia_room/models/post_creator/block_text.dart';
import 'package:dia_room/models/post_creator/block_video.dart';
import 'package:dia_room/models/post_creator/post_draft.dart';
import 'package:dia_room/models/post_creator/publication_post.dart';
import 'package:dia_room/models/post_creator/upload_file_info.dart';
import 'package:dia_room/utils/compress_image_service.dart';
import 'package:uuid/uuid.dart';
import '../../api/post_api.dart';


class CreatingPostService {
  final PostDraft post;
  PublicationPost publicationPost;

  CreatingPostService({required this.post})
    : publicationPost = PublicationPost.fromDraft(
        draft: post,
      );

  Future<List<BlockUpload>> createUploadFiles(List<BlockPost> blocks) async {
    List<BlockUpload> blocksUpload = [];

    for (final block in blocks) {
      if (block is BlockTextCreating) {
        blocksUpload.add(
          BlockTextUpload(
            text: block.value,
            textType: block.textType,
          ),
        );
      } else if (block is BlockPhotosCreating) {
        final photoUpload = BlockPhotoUpload(methodView: block.methodView);

        for (var i = 0; i < block.listPhoto.length; i++) {
          final path = block.listPhoto[i].filePath;
          if (path.isEmpty) continue;

          String? compressedImage;
          try {
            compressedImage = await CompressImageService.compressForPreview(XFile(path));
          } catch (_) {
            continue;
          }

          if (compressedImage == null) continue;

          photoUpload.listPhoto.add(
            PhotoInfo(
              filePath: compressedImage,
              uploadId: const Uuid().v4(),
              size: block.listPhoto[i].size,
              publicUrl: '',
              presignedUrl: '',
            ),
          );
        }
        blocksUpload.add(photoUpload);
      } else if (block is BlockVideoCreating) {
        final previewPath = block.previewLocalPath;
        if (previewPath.isEmpty) continue;

        String? compressedImage;
        try {
          compressedImage = await CompressImageService.compressForPreview(XFile(previewPath));
        } catch (_) {
          continue;
        }

        if (compressedImage == null) continue;

        final videoUpload = BlockVideoUpload(
          filePath: block.localPath,
          previewPath: compressedImage,
          fileSize: block.fileSize,
          duration: block.duration,
          uploadIdVideo: const Uuid().v4(),
          uploadIdPreview: const Uuid().v4(),
        );

        blocksUpload.add(videoUpload);
      }
    }

    return blocksUpload;
  }

  List<UploadFileInfo> collectUploadFiles(List<BlockUpload> uploadBlocks) {
    final List<UploadFileInfo> files = [];

    for (final block in uploadBlocks) {
      if (block is BlockPhotoUpload) {
        for (final photo in block.listPhoto) {
          files.add(
            UploadFileInfo(
              uploadId: photo.uploadId,
              filename: photo.filePath.split('/').last,
              contentType: 'image/jpeg',
            ),
          );
        }
      } else if (block is BlockVideoUpload) {
        // Основное видео
        if (block.filePath.isNotEmpty) {
          files.add(
            UploadFileInfo(
              uploadId: block.uploadIdVideo,
              filename: block.filePath.split('/').last,
              contentType: 'video/mp4',
            ),
          );
        }
        // Превью видео
        if (block.previewPath.isNotEmpty) {
          files.add(
            UploadFileInfo(
              uploadId: block.uploadIdPreview,
              filename: block.previewPath.split('/').last,
              contentType: 'image/jpeg',
            ),
          );
        }
      }
    }

    return files;
  }

  /// Применяет ответ от сервера и обновляет все блоки публичными и presigned ссылками
  void applyPresignedResponse(
    List<BlockUpload> uploadBlocks,
    List<dynamic> serverFiles, // массив из 'files' в ответе
  ) {
    final Map<String, dynamic> responseMap = {
      for (var file in serverFiles) file['uploadId']: file,
    };

    for (final block in uploadBlocks) {
      if (block is BlockPhotoUpload) {
        for (final photo in block.listPhoto) {
          final data = responseMap[photo.uploadId];
          if (data != null) {
            photo.publicUrl = data['publicUrl'];
            photo.presignedUrl = data['presignedUrl'];
          }
        }
      } else if (block is BlockVideoUpload) {
        // Видео
        final videoData = responseMap[block.uploadIdVideo];
        if (videoData != null) {
          block.publicUrlVideo = videoData['publicUrl'];
          block.presignedUrlVideo = videoData['presignedUrl'];
        }

        // Превью
        final previewData = responseMap[block.uploadIdPreview];
        if (previewData != null) {
          block.publicUrlPreview = previewData['publicUrl'];
          block.presignedUrlPreview = previewData['presignedUrl'];
        }
      }
    }
  }

  Future<bool> uploadAllMediaFromBlocks(List<BlockUpload> uploadBlocks) async {
    bool allSuccess = true;

    for (final block in uploadBlocks) {
      if (block is BlockPhotoUpload) {
        // Загружаем список фотографий в блоке
        for (final photo in block.listPhoto) {
          if (photo.presignedUrl.isNotEmpty) {
            final success = await uploadSingleMediaFile(
              photo.filePath,
              photo.presignedUrl,
              "image/jpeg",
            );
            if (!success) allSuccess = false;
          }
        }
      } else if (block is BlockVideoUpload) {
        // 1. Загружаем само видео
        if (block.presignedUrlVideo != null && block.presignedUrlVideo!.isNotEmpty) {
          final videoSuccess = await uploadSingleMediaFile(
            block.filePath,
            block.presignedUrlVideo!,
            'video/mp4', // убедитесь, что это поле есть (обычно video/mp4)
          );
          if (!videoSuccess) allSuccess = false;
        }

        // 2. Загружаем превью (обложку) видео
        if (block.presignedUrlPreview != null && block.presignedUrlPreview!.isNotEmpty) {
          final previewSuccess = await uploadSingleMediaFile(
            block.previewPath,
            block.presignedUrlPreview!,
            'image/jpeg', // или block.contentTypePreview
          );
          if (!previewSuccess) allSuccess = false;
        }
      }
    }

    return allSuccess;
  }

  /// Метод, выполняющий полный цикл создания поста
  Future<void> startCreating() async {
    String? compressedPreview;
    print("--- [START] Процесс создания поста запущен ---");
    /// Создаем модель превью
    Map<String, dynamic> modelPreview;
    try {
      const uuid = Uuid();

      if (post.previewPath == null) {
        print("❌ [ШАГ 1: Превью] previewUrl отсутствует в post. Создание остановлено.");
        return;
      }

      // Сжатие изображения
      compressedPreview = await CompressImageService.compressForPreview(XFile(post.previewPath!));
      if (compressedPreview == null) {
        print("Не удалось сжать превью");
        return;
      }

      final fileName = post.previewPath!.split('/').last;

      modelPreview = {
        "uploadId": uuid.v4(),
        "filename": fileName,
        "contentType": 'image/jpeg',
        "size": await File(compressedPreview).length(),
      };
      print("✅ [ШАГ 1: Превью] Модель превью успешно сформирована: $modelPreview");
    } catch (e) {
      print("🚨 [ШАГ 1: Превью] Ошибка при формировании модели: $e");
      return;
    }

    AuthResponse resultCreating;

    /// Выполняем запрос на создание поста и получаем сразу ссылки
    /// на превью (публичную и загрузку)
    try {
      final postCreating = {
        "title": publicationPost.title,
        "categorySlug": publicationPost.categorySlug.slug,
        "hashtags": publicationPost.hashtags,
        "workshopLink": publicationPost.workshopLink.getLink(),
      };

      // postId , preview {publicUrl, presignedUrl}
      resultCreating = await createPostRequest(
        postCreating: postCreating ,
        modelPreview: modelPreview ,
      );

      print("📡 [ШАГ 2: API] Отправка запроса createPost...");
      print("   > Данные поста: $postCreating");
      print('Результат создания поста: ${resultCreating.success}');
    } catch (e) {
      print("🚨 [ШАГ 2: API] Критическая ошибка при вызове createPost: $e");
      return;
    }

    /// Загружаем превью в объектное хранилище
    if (!resultCreating.success) {
      print('⛔ [ОСТАНОВКА] Дальнейшие действия невозможны из-за ошибки API.');
      return;
    }

    /// ---Расскоментировать блок, когда нужно будет добавлять в хранилище
    publicationPost.previewPublicURL = resultCreating.data!['preview']['publicUrl'];
    print("🔗 [ИНФО] Публичный URL превью получен: ${publicationPost.previewPublicURL}");
    final resultUploadPreview = await uploadSingleMediaFile(
      compressedPreview,
      resultCreating.data!['preview']['presignedUrl'],
      "image/jpeg",
    );

    if (!resultUploadPreview) {
      print('Превью не было загружено, продолжаем создание поста');
    }

    /// Формируем список для будущего payload поста (В createUploadFiles выполняется сжатие)
    print("🛠️ [ШАГ 3: Payload] Сбор файлов из блоков контента...");
    publicationPost.payload = await createUploadFiles(post.blocks);

    List<UploadFileInfo> uploadFiles = collectUploadFiles(
      publicationPost.payload!,
    );
    print("📦 [ШАГ 3: Payload] Найдено файлов для загрузки: ${uploadFiles.length}");

    /// Запрос ссылок
    print("📡 [ШАГ 4: S3 Links] Запрос Presigned URLs для медиа-файлов...");
    final responseUrls = await requestPresignedUrls(
      mediaForUrls: uploadFiles,
      postId: resultCreating.data!['postId'],
    );

    if (!responseUrls.success) {
      print('❌ [ШАГ 4: S3 Links] Ошибка: ответ от сервера пустой (null)');
      return;
    } else {
      print("✅ [ШАГ 4: S3 Links] Ссылки успешно получены.");
    }

    print("📝 [ШАГ 5: Payload Update] Привязка полученных ссылок к блокам...");
    applyPresignedResponse(publicationPost.payload!, responseUrls.data!['files']);

    print("📡 [ШАГ 6: Canvas] Отправка финального холста (Canvas) на сервер...");
    final resultCreatingCanvas = await savePostCanvas(
      postId: resultCreating.data!['postId'],
      canvasPayload: publicationPost.payloadToJson(),
    );

    print('📊 [ШАГ 6: Canvas] Результат сохранения холста: $resultCreatingCanvas');
    final result = await uploadAllMediaFromBlocks(publicationPost.payload!);
    print('Результат загрузки медиа в хранилище $result');

    print("📡 [ШАГ 7: Canvas] Обновление статуса и добавление в очередь на проверку...");
    final resultStatusUpdating = await updateStatusPost(postId: resultCreating.data!['postId']);
    print("Результат обновления статуса ${resultStatusUpdating.success}");

    print('--- [FINISH] Процесс создания поста завершен успешно ---');
  }
}
