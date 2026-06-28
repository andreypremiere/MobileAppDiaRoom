import 'package:dia_room/models/post_view/post_data.dart';
import 'package:dia_room/models/post_view/statistics.dart';

class BasePost {
  final PostData data;
  final Statistics stats;

  BasePost({required this.data, required this.stats});

  factory BasePost.fromMap(Map<String, dynamic> map) {
    return BasePost(
      data: PostData.fromMap(map),
      stats: Statistics.fromMap(map),
    );
  }
}

