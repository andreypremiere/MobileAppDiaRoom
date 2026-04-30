import 'package:dia_room/models/post_view/post_data.dart';
import 'package:dia_room/models/post_view/statistics.dart';

import 'base_post.dart';

class PersonalPost extends BasePost {
  final String status;
  final String statusAi;

  PersonalPost({
    required this.status,
    required this.statusAi,
    required super.data,
    required super.stats,
  });

  factory PersonalPost.fromMap(Map<String, dynamic> map) {
    return PersonalPost(
      status: map['status'] ?? 'Не удалось получить',
      statusAi: map['statusAi'] ?? 'Не удалось получить',
      data: PostData.fromMap(map),
      stats: Statistics.fromMap(map),
    );
  }
}