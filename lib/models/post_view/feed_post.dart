import 'package:dia_room/models/post_view/post_data.dart';
import 'package:dia_room/models/post_view/statistics.dart';

import 'author.dart';
import 'base_post.dart';

class FeedPost extends BasePost {
  final Author author;

  FeedPost({
    required this.author,
    required super.data,
    required super.stats,
  });

  factory FeedPost.fromMap(Map<String, dynamic> map) {
    return FeedPost(
      author: Author.fromMap(map),
      data: PostData.fromMap(map),
      stats: Statistics.fromMap(map),
    );
  }
}
