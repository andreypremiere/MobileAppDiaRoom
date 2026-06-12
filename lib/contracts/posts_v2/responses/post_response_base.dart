import 'package:dia_room/contracts/posts_v2/responses/post_media_response.dart';
import 'package:dia_room/models/enums/post_v2/post_status.dart';

class PostResponseBase {
  final String id;
  final String? description;
  final List<String> hashtags;
  final String? workshopLink;
  final PostStatus status;
  final DateTime createdAt;
  final List<PostMediaResponse> files;

  PostResponseBase({
    required this.id,
    this.description,
    required this.hashtags,
    this.workshopLink,
    required this.status,
    required this.createdAt,
    required this.files,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'description': description,
      'hashtags': hashtags,
      'workshopLink': workshopLink,
      'status': status.value,
      'createdAt': createdAt.toIso8601String(),
    };
  }

  factory PostResponseBase.fromMap(Map<String, dynamic> map) {
    return PostResponseBase(
      id: map['id'] as String,
      description: map['description'] as String?,
      hashtags: List<String>.from(map['hashtags'] ?? []),
      workshopLink: map['workshopLink'] as String?,
      status: PostStatus.fromMap(map['status'] as String),
      // Парсим ISO-строку времени в локальное время девайса
      createdAt: DateTime.parse(map['createdAt'] as String).toLocal(),
      files: List<PostMediaResponse>.from(
        (map['files'] ?? []).map((x) => PostMediaResponse.fromMap(x as Map<String, dynamic>)),
      ),
    );
  }
}