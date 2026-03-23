import 'package:dia_room/models/post_creator/block_post.dart';

import '../enums/post_categories.dart';
import 'block_photos.dart';
import 'block_text.dart';
import 'block_video.dart';

class PostDraft {
  List<BlockPost> blocks;
  String name;
  String? previewPath;
  PostCategory category;
  List<String> hashtags;
  // Сюда потом можно будет класть ссылку на мастерскую например
  Map<String, dynamic> metadata;

  PostDraft({
    this.name = '',
    this.previewPath,
    this.category = PostCategory.defaultVal,
    List<String>? hashtags,
    List<BlockPost>? blocks,
    Map<String, dynamic>? metadata
  }) : hashtags = hashtags ?? [], blocks = blocks ?? [], metadata = metadata ?? {};

  @override
  String toString() {
    return '''
      PostDraft {
      name: $name,
      previewPath: $previewPath,
      category: ${category.id},
      hashtags: $hashtags,
      blocksCount: ${blocks.length},
      metadata: $metadata
}''';
  }

  // ИСПРАВИТЬ
  Map<String, dynamic> toPublishedPayload() {
    return {
      "blocks": blocks.map((block) {
        if (block is BlockText) {
          return {
            "type": "text",
            "content": block.controller.text,
            "textType": block.textType.name,
            "metadata": block.metadata,
          };
        }
        else if (block is BlockPhotos) {
          return {
            "type": "photos",
            "paths": block.paths, // уже публичные URL после загрузки
            "methodView": block.methodView.name,
          };
        }
        else if (block is BlockVideo) {
          return {
            "type": "video",
            "path": block.path,           // публичная ссылка на видео
            "previewPath": block.previewPath, // публичная ссылка на превью
            "duration": block.duration?.inSeconds,
          };
        }
        return {};
      }).toList(),
      // "title": name,
      "previewUrl": previewPath,
      "hashtags": hashtags,
    };
  }
}
