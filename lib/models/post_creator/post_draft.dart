import 'package:dia_room/models/post_creator/block_post.dart';

import '../enums/categories.dart';

class PostDraft {
  List<BlockPost> blocks;
  String name;
  String? previewPath;
  Categories category;
  List<String> hashtags;

  static const int maxCountHashtags = 6;

  PostDraft({
    this.name = '',
    this.previewPath,
    this.category = Categories.defaultVal,
    List<String>? hashtags,
    List<BlockPost>? blocks,
    Map<String, dynamic>? metadata
  }) : hashtags = hashtags ?? [], blocks = blocks ?? [];
}
