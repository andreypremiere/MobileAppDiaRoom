import 'package:dia_room/models/post_view/feed_post.dart';

class FoundPosts {
  final List<FeedPost> posts;
  
  FoundPosts({required this.posts});
  
  factory FoundPosts.fromMap(List<dynamic> map) {
    return FoundPosts(posts: map
        .map((item) => FeedPost.fromMap(item as Map<String, dynamic>))
        .toList());
  }
}