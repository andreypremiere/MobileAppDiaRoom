import 'package:dia_room/models/post_creator/block_post.dart';

import '../enums/post_categories.dart';

class PostCreateRequest {
  List<BlockPost> blocks;
  String name;
  String? previewPath;
  PostCategory? category;
  List<String> hashtags;

  PostCreateRequest({
    required this.blocks,
    this.name = '',
    this.previewPath,
    this.category,
    List<String>? hashtags,
  }) : hashtags = hashtags ?? [];

  @override
  String toString() {
    return '''
PostCreateRequest {
  name: $name,
  previewPath: $previewPath,
  category: ${category?.label},
  hashtags: $hashtags,
  blocksCount: ${blocks.length}
}''';
  }
}
