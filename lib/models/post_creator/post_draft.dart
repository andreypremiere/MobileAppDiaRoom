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
}
