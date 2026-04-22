import '../enums/post_categories.dart';
import '../payload/base_block.dart';
import 'block_photos.dart';
import 'block_text.dart';
import 'block_video.dart';

class PostDraft {
  List<BlockPost> blocks;
  String name;
  String previewPath;
  PostCategory category;
  List<String> hashtags;

  static const int maxCountHashtags = 6;

  PostDraft({
    this.name = '',
    this.previewPath = '',
    this.category = PostCategory.defaultVal,
    List<String>? hashtags,
    List<BlockPost>? blocks,
    Map<String, dynamic>? metadata
  }) : hashtags = hashtags ?? [], blocks = blocks ?? [];

  Map<String, dynamic> toMap() {
    return {
      'title': name,
      'previewPath': previewPath,
      'categorySlug': category.slug,
      'hashtags': hashtags,
      'blocks': blocks.map((block) => block.toMap()).toList(),
    };
  }

//   Map<String, dynamic> toPublishedPayload() {
//     return {
//       "blocks": blocks.map((block) {
//         if (block is BlockTextCreating) {
//           return {
//             "type": "text",
//             "content": block.controller.text,
//             "textType": block.textType.name,
//             "metadata": block.metadata,
//           };
//         }
//         else if (block is BlockPhotos) {
//           return {
//             "type": "photos",
//             "paths": block.paths, // уже публичные URL после загрузки
//             "methodView": block.methodView.name,
//           };
//         }
//         else if (block is BlockVideoCreating) {
//           return {
//             "type": "video",
//             "path": block.path,           // публичная ссылка на видео
//             "previewPath": block.previewPath, // публичная ссылка на превью
//             "duration": block.duration?.inSeconds,
//           };
//         }
//         return {};
//       }).toList(),
//       // "title": name,
//       "previewUrl": previewPath,
//       "hashtags": hashtags,
//     };
//   }
}
