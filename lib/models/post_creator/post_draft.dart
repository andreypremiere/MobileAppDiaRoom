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

  static const int maxCountHashtags = 6;

  PostDraft({
    this.name = '',
    this.previewPath,
    this.category = PostCategory.defaultVal,
    List<String>? hashtags,
    List<BlockPost>? blocks,
    Map<String, dynamic>? metadata
  }) : hashtags = hashtags ?? [], blocks = blocks ?? [];


  // Map<String, dynamic> toPublishedPayload() {
  //   return {
  //     "blocks": blocks.map((block) {
  //       if (block is BlockTextCreating) {
  //         return {
  //           "blockType": "text",
  //           "content": block.controller.text,
  //           "textType": block.textType.slug,
  //         };
  //       }
  //       else if (block is BlockPhotosCreating) {
  //         return {
  //           "blockType": "photos",
  //           "paths": block.paths, // уже публичные URL после загрузки
  //           "methodView": block.methodView.slug,
  //         };
  //       }
  //       else if (block is BlockVideoCreating) {
  //         return {
  //           "blockType": "video",
  //           "path": block.path,           // публичная ссылка на видео
  //           "previewPath": block.previewPath, // публичная ссылка на превью
  //           "duration": block.duration?.inSeconds,
  //         };
  //       }
  //       return {};
  //     }).toList(),
  //     "previewUrl": previewPath,
  //     "hashtags": hashtags,
  //   };
  // }
}
