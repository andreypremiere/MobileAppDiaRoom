import 'package:dia_room/contracts/posts_v2/responses/post_response_base.dart';
import 'package:dia_room/contracts/posts_v2/responses/post_upload_item.dart';
import 'package:dia_room/contracts/posts_v2/responses/statistic_response.dart';

class PostCreateResponse {
  final PostResponseBase post;
  final StatisticResponse statistic;
  final List<PostUploadItem> uploadItems;

  PostCreateResponse({
    required this.post,
    required this.statistic,
    required this.uploadItems,
  });

  Map<String, dynamic> toMap() {
    return {
      'post': post.toMap(),
      'statistic': statistic.toMap(),
      'uploadItems': uploadItems.map((x) => x.toMap()).toList(),
    };
  }

  factory PostCreateResponse.fromMap(Map<String, dynamic> map) {
    return PostCreateResponse(
      post: PostResponseBase.fromMap(map['post'] as Map<String, dynamic>),
      statistic: StatisticResponse.fromMap(map['statistic'] as Map<String, dynamic>),
      uploadItems: List<PostUploadItem>.from(
        (map['uploadItems'] ?? []).map((x) => PostUploadItem.fromMap(x as Map<String, dynamic>)),
      ),
    );
  }
}