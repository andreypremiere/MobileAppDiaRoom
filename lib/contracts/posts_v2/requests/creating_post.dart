import 'media_file_item.dart';

class PostCreateRequest {
  final String? description;
  final List<String> hashtags;
  final String? workshopLink; // uuid.UUID -> String?
  final List<MediaFileItem> files;

  PostCreateRequest({
    this.description,
    required this.hashtags,
    this.workshopLink,
    required this.files,
  });

  Map<String, dynamic> toMap() {
    return {
      'description': description,
      'hashtags': hashtags,
      'workshopLink': workshopLink,
      'files': files.map((x) => x.toMap()).toList(),
    };
  }

  factory PostCreateRequest.fromMap(Map<String, dynamic> map) {
    return PostCreateRequest(
      description: map['description'] as String?,
      hashtags: List<String>.from(map['hashtags'] ?? []),
      workshopLink: map['workshopLink'] as String?,
      files: List<MediaFileItem>.from(
        (map['files'] ?? []).map((x) => MediaFileItem.fromMap(x as Map<String, dynamic>)),
      ),
    );
  }
}