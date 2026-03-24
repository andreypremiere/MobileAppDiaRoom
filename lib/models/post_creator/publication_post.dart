import 'package:dia_room/models/enums/ai_post_types.dart';
import 'package:dia_room/models/enums/post_categories.dart';
import 'package:dia_room/models/enums/post_status.dart';
import 'package:dia_room/models/post_creator/post_draft.dart';

import 'block_photos.dart';
import 'block_post.dart';
import 'block_text.dart';
import 'block_video.dart';

class PublicationPost {
  String? id;
  PostStatus postStatus;
  AiCheckStatus aiCheckStatus;
  String title;
  String? previewPublicURL;
  Map<String, dynamic> metadata;

  PostCategory categorySlug;

  List<Map<dynamic, dynamic>>? canvas; // по началу может быть ноль, но нужна проверка

  List<String> hashtags;

  PublicationPost({
    this.id,
    this.postStatus = PostStatus.pending,
    this.aiCheckStatus = AiCheckStatus.notChecked,
    required this.title,
    this.previewPublicURL,
    Map<String, dynamic>? metadata,
    required this.categorySlug,
    this.canvas,
    List<String>? hashtags,
  })  : metadata = metadata ?? {},
        hashtags = hashtags ?? [];

  factory PublicationPost.fromDraft({
    required PostDraft draft,
    required String roomId,
  }) {
    return PublicationPost(
      id: null,
      title: draft.name,
      previewPublicURL: null, // На старте это локальный путь
      categorySlug: draft.category,
      hashtags: List.from(draft.hashtags),
      metadata: Map.from(draft.metadata),
      canvas: null,
    );
  }

  // Вспомогательный статический метод для конвертации блоков
  static Map<String, dynamic> _convertBlockToMap(BlockPost block) {
    if (block is BlockText) {
      return {
        "type": "text",
        "content": block.controller.text,
        "textType": block.textType.name,
        "metadata": Map<String, dynamic>.from(block.metadata),
      };
    } else if (block is BlockPhotos) {
      return {
        "type": "photos",
        "paths": List<String>.from(block.paths), // Пока еще локальные пути
        "methodView": block.methodView.name,
      };
    } else if (block is BlockVideo) {
      return {
        "type": "video",
        "path": block.path,
        "previewPath": block.previewPath,
        "fileName": block.fileName,
        "fileSize": block.fileSize,
        "duration": block.duration?.inSeconds,
      };
    }
    return {};
  }

  // 3. Метод для генерации JSON (Payload для сервера)
  // Вызывается в самом конце, когда все previewURL и пути в canvas заменены на сетевые
  Map<String, dynamic> toJson() {
    return {
      if (id != null) "id": id,
      "status": postStatus.name,
      "aiStatus": aiCheckStatus.name,
      "title": title,
      "previewUrl": previewPublicURL,
      "category": categorySlug.id, // или .name, смотря что ждет бэкенд
      "hashtags": hashtags,
      "metadata": metadata,
      "canvas": canvas ?? [],
    };
  }
}