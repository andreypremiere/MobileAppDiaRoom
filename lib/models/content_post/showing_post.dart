import 'package:dia_room/models/post_creator/workshop_link.dart';

import '../post_creator/block_post.dart';
import '../post_view/author.dart';
import '../post_view/statistics.dart';

class ShowingPost {
  final Statistics stats;
  final String roomId;
  final List<BlockPost> payload;
  final String categorySlug;
  final List<String> hashtags;
  final WorkshopLink workshopLink;

  ShowingPost({
    required this.stats,
    required this.roomId,
    required this.payload,
    required this.categorySlug,
    required this.hashtags,
    required this.workshopLink,
  });

  factory ShowingPost.fromMap(Map<String, dynamic> map) {
    return ShowingPost(
      stats: Statistics.fromMap(map),
      roomId: map['roomId'] ?? '',
      payload: (map['payload'] as List<dynamic>? ?? [])
          .map((blockMap) => BlockPost.fromMap(blockMap as Map<String, dynamic>))
          .toList(),
      categorySlug: map['categorySlug'] ?? '',
      hashtags: map['hashtags'] != null
          ? List<String>.from(map['hashtags'])
          : [],
      workshopLink: WorkshopLink.fromMap(map),
    );
  }
}