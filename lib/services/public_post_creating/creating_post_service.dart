// Здесь будет класс, который будет выполнять полный цикл
// публикации поста, от начала конфигурации данных, заканчивая
// статусом, что пост опубликован и отправкой уведомления

import 'dart:io';

import 'package:dia_room/models/post_creator/block_photos.dart';
import 'package:dia_room/models/post_creator/block_post.dart';
import 'package:dia_room/models/post_creator/block_video.dart';
import 'package:dia_room/models/post_creator/post_creating.dart';
import 'package:dia_room/models/post_creator/preview_request.dart';
import 'package:dia_room/models/post_creator/upload_file_info.dart';
import 'package:dia_room/models/user.dart';
import 'package:http/http.dart' as http;
import 'package:uuid/uuid.dart';

import '../../api/post_microservice/post_api.dart';
import '../../models/post_creator/upload_task.dart';

class CreatingPostService {
  final PostCreateRequest post;
  final User user;

  CreatingPostService({required this.post, required this.user});

  List<UploadFileInfo> assemblyMediaFiles() {
    final List<UploadFileInfo> files = [];

    for (final block in post.blocks) {
      if (block is BlockPhotos) {
        for (int i = 0; i < block.paths.length; i++) {
          final path = block.paths[i];
          files.add(
            UploadFileInfo(
              localPath: path,
              filename: path.split('/').last,
              contentType: 'image/jpeg',
              parentBlock: block,
              indexInBlock: i,
            ),
          );
        }
      }
      else if (block is BlockVideo) {
        if (block.path != null) {
          files.add(UploadFileInfo(
            localPath: block.path!,
            filename: block.path!.split('/').last,
            contentType: 'video/mp4',
            parentBlock: block,
            indexInBlock: 0,
          ));
        }
        if (block.previewPath != null) {
          files.add(UploadFileInfo(
            localPath: block.previewPath!,
            filename: block.previewPath!.split('/').last,
            contentType: 'image/jpeg',
            parentBlock: block,
            indexInBlock: 0,
            isVideoPreview: true,
          ));
        }
      }
    }
    return files;
  }

  List<Map<String, dynamic>> preparePresignedRequest(List<UploadFileInfo> files) {
    return files.map((f) {
        return {
          "uploadId": f.uploadId,
          "filename": f.filename,
          "contentType": f.contentType,
          // "size": null, // можно добавить File.length() если нужно
        };
      }).toList();
  }

  List<UploadTask> matchPresignedUrls(
      List<UploadFileInfo> originalFiles,
      Map<String, dynamic> serverResponse,
      ) {
    final Map<String, String> presignedMap = {};
    final Map<String, String> publicMap = {};

    // Преобразуем ответ сервера в удобные мапы
    for (final file in serverResponse['files']) {
      presignedMap[file['uploadId']] = file['presignedUrl'];
      publicMap[file['uploadId']] = file['publicUrl'];
    }

    final List<UploadTask> tasks = [];

    for (final file in originalFiles) {
      final presignedUrl = presignedMap[file.uploadId];
      final publicUrl = publicMap[file.uploadId];

      if (presignedUrl == null || publicUrl == null) {
        print('Не найдена ссылка для uploadId: ${file.uploadId}');
        continue;
      }

      tasks.add(UploadTask(
        fileInfo: file,
        presignedUrl: presignedUrl,
        publicUrl: publicUrl,
      ));
    }

    return tasks;
  }

  Future<void> uploadAllFiles(List<UploadTask> tasks) async {
    const maxConcurrent = 3;

    // Разрезаем список задач на чанки (порции) по maxConcurrent
    for (var i = 0; i < tasks.length; i += maxConcurrent) {
      final chunk = tasks.sublist(
          i,
          i + maxConcurrent > tasks.length ? tasks.length : i + maxConcurrent
      );

      // Запускаем пачку параллельно
      await Future.wait(chunk.map((task) async {
        try {
          // Расскоментировать, если нужно загружать
          // await uploadSingleMediaFile(task);

          // Логика изменения путей теперь здесь (или вынесена в отдельный метод ниже)
          _updateBlockPath(task);

          print('✅ Загружен: ${task.fileInfo.filename}');
        } catch (e) {
          print('❌ Ошибка загрузки ${task.fileInfo.filename}: $e');
          rethrow;
        }
      }));
    }

    print('🚀 Все файлы успешно загружены и пути обновлены');
  }

// Вынесенная логика обновления путей в модели
  void _updateBlockPath(UploadTask task) {
    final block = task.fileInfo.parentBlock;

    if (block is BlockPhotos) {
      // Обновляем конкретный индекс в массиве путей
      block.paths[task.fileInfo.indexInBlock!] = task.publicUrl;
    }
    else if (block is BlockVideo) {
      if (task.fileInfo.isVideoPreview) {
        block.previewPath = task.publicUrl;
      } else {
        block.path = task.publicUrl;
      }
    }
  }


  Future<void> startCreating() async {
    // 1. Создаём пост и получаем postId
    final postId = await createPostRequest(
      roomId: user.roomId,
      categoryId: post.category?.id ?? 'visual-arts',
      title: post.name, token: user.token,
    );

    post.postId = postId;

    print('Пост создан: $postId');

    // 1. Сборка всех медиафайлов
    List<UploadFileInfo> files = assemblyMediaFiles();
    // for (final file in files) {
    //   print(file);
    // }

    final preparedData = preparePresignedRequest(files);

    PreviewRequest? previewData;
    if (post.previewPath != null) {
      previewData = PreviewRequest(pathPreview: post.previewPath!);
    } else {
      previewData = null;
    }

    print('Данные подготовлены. Началась отправка');

    final responseBody = await requestPresignedUrls(preparedData, user.token, postId, previewData);

    print("Пришедшие данные с сервера $responseBody");

    if (post.previewPath != null) {
      post.previewPath = responseBody['previewResponse']['publicUrl'];
    }
    // print('Ответ от сервера ${responseBody['files'].length} первый объект ${responseBody['files'][0]}');
    //
    //
    // print(responseBody['previewResponse']);

    final uploadTasks = matchPresignedUrls(files, responseBody);

    // Написать метод для загрузки обложки поста, она отдельно загружается

    // Раскомментировать
    await uploadAllFiles(uploadTasks);

    print('Все файлы загружены. Готовим финальный запрос на создание поста...');

    final postPayload = post.toPublishedPayload();

    print('canvasPayload перед отправкой: $postPayload');

    await publishPostRequest(
      postId: postId,
      payload: postPayload['blocks'],
      previewUrl: postPayload['previewUrl'],
      hashtags: postPayload['hashtags'],
      token: user.token
    );

    print('🎉 Пост успешно опубликован!');


    //Нужно создать на сервере методы
  }
}
