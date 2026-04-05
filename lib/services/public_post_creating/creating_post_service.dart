// Здесь будет класс, который будет выполнять полный цикл
// публикации поста, от начала конфигурации данных, заканчивая
// статусом, что пост опубликован и отправкой уведомления

import 'dart:io';

import 'package:dia_room/models/post_creator/block_photos.dart';
import 'package:dia_room/models/post_creator/block_post.dart';
import 'package:dia_room/models/post_creator/block_text.dart';
import 'package:dia_room/models/post_creator/block_video.dart';
import 'package:dia_room/models/post_creator/post_draft.dart';
import 'package:dia_room/models/post_creator/preview_request.dart';
import 'package:dia_room/models/post_creator/publication_post.dart';
import 'package:dia_room/models/post_creator/upload_file_info.dart';
import 'package:dia_room/models/user.dart';
import 'package:uuid/uuid.dart';

// import 'package:http/http.dart' as http;
// import 'package:uuid/uuid.dart';

import '../../api/post_api.dart';
import '../../models/post_creator/upload_task.dart';
import 'media_upload_planner.dart';

class CreatingPostService {
  final PostDraft post;
  final User user;
  PublicationPost publicationPost;

  CreatingPostService({required this.post, required this.user})
    : publicationPost = PublicationPost.fromDraft(
        draft: post,
        roomId: user.roomId,
      );

  List<BlockUpload> createUploadFiles(List<BlockPost> blocks) {
    List<BlockUpload> blocksUpload = [];

    for (final block in blocks) {
      if (block is BlockText) {
        final newMetadata = MetadataText();
        newMetadata.size = block.metadata.size;
        newMetadata.weight = block.metadata.weight;
        blocksUpload.add(
          BlockTextUpload(
            text: block.controller.text,
            textType: block.textType,
            metadata: newMetadata,
          ),
        );
      } else if (block is BlockPhotos) {
        final photoUpload = BlockPhotoUpload(methodView: block.methodView);

        for (var i = 0; i < block.paths.length; i++) {
          photoUpload.listPhoto.add(
            PhotoInfo(
              filePath: block.paths[i],
              uploadId: const Uuid().v4(),
              size: block.photoSizes[i],
            ),
          );
        }
        blocksUpload.add(photoUpload);
      } else if (block is BlockVideo) {
        final videoUpload = BlockVideoUpload(
          filePath: block.path!,
          previewPath: block.previewPath!,
          fileSize: block.fileSize!,
          duration: block.duration ?? Duration.zero,
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
          if (photo.presignedUrl != null) {
            final success = await uploadSingleMediaFile(
              photo.filePath,
              photo.presignedUrl!,
              "image/jpeg",
            );
            if (!success) allSuccess = false;
          }
        }
      } else if (block is BlockVideoUpload) {
        // 1. Загружаем само видео
        if (block.presignedUrlVideo != null) {
          final videoSuccess = await uploadSingleMediaFile(
            block.filePath!,
            block.presignedUrlVideo!,
            'video/mp4', // убедитесь, что это поле есть (обычно video/mp4)
          );
          if (!videoSuccess) allSuccess = false;
        }

        // 2. Загружаем превью (обложку) видео
        if (block.presignedUrlPreview != null) {
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
    /// Создаем модель превью
    Map<String, dynamic> modelPreview;
    try {
      const _uuid = Uuid();

      if (post.previewPath == null) {
        print("В publicationPost отсутствует previewUrl. Создание остановлено");
        return;
      }

      final fileName = post.previewPath!.split('/').last;

      modelPreview = {
        "uploadId": _uuid.v4(),
        "filename": fileName,
        "contentType": 'image/jpeg',
        "size": await File(post.previewPath!).length(),
      };
    } catch (e) {
      print("Ошибка при создании модели для превью публикации");
      return;
    }

    /// Выполняем запрос на создание поста и получаем сразу ссылки
    /// на превью (публичную и загрузку
    Map? resultCreating;
    try {
      final postCreating = {
        "title": publicationPost.title,
        "postStatus": publicationPost.postStatus.name,
        "aiStatus": publicationPost.aiCheckStatus.name,
        "categorySlug": publicationPost.categorySlug.id,
        "hashtags": publicationPost.hashtags,
      };

      print("modelPreview перед отправкой: $modelPreview");
      print("postCreating перед отправкой: $postCreating");

      // postId , preview {publicUrl, presignedUrl}
      resultCreating = await createPostRequest(
        postCreating: postCreating,
        modelPreview: modelPreview,
        token: user.token,
      );

      print('Результат создания поста: $resultCreating');
    } catch (e) {
      print("Что-то пошло не так при создании поста $e");
    }

    /// Загружаем превью в объектное хранилище
    if (resultCreating == null) {
      print(
        'Пришел bad response во время создания пользователя resultCreating == null',
      );
      return;
    }

    /// ---Расскоментировать блок, когда нужно будет добавлять в хранилище
    publicationPost.previewPublicURL = resultCreating['preview']['publicUrl'];
    // final resultUploadPreview = await uploadSingleMediaFile(
    //   post.previewPath!,
    //   resultCreating['preview']['presignedUrl'],
    //   "image/jpeg",
    // );
    //
    // if (!resultUploadPreview) {
    //   print('Превью не было загружено, продолжаем создание поста');
    // }
    /// ---Конец блока

    /// Формируем список для будущего payload поста
    publicationPost.payload = createUploadFiles(post.blocks);

    List<UploadFileInfo> uploadFiles = collectUploadFiles(
      publicationPost.payload!,
    );

    /// Запрос ссылок
    final responseUrls = await requestPresignedUrls(
      mediaForUrls: uploadFiles,
      token: user.token,
      postId: resultCreating['postId'],
    );

    if (responseUrls == null) {
      print('Результат запроса ссылок = null');
      return;
    } else {
      print("Результат запроса ссылок: $responseUrls");
    }

    /// Заполняем ссылками payload
    applyPresignedResponse(publicationPost.payload!, responseUrls['files']);

    // final result = await uploadAllMediaFromBlocks(publicationPost.payload!);

    // print('Результат загрузки медиа в хранилище $result');

    final resultCreatingCanvas = savePostCanvas(
      postId: resultCreating['postId'],
      canvasPayload: publicationPost.payloadToJson(),
      token: user.token,
    );

    print('Результат создания canvas: $resultCreatingCanvas');

    print('Конец создания');

  }
}
