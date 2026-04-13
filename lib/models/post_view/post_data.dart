import '../enums/post_categories.dart';

class PostData {
  final String postId;
  final String title;
  final String preview;
  final PostCategory category;
  final String canvasId;

  PostData({
    required this.postId,
    required this.title,
    required this.preview,
    required this.category,
    required this.canvasId,
  });

  factory PostData.fromMap(Map<String, dynamic> map) {
    return PostData(
      postId: map['postId'] ?? '',
      title: map['title'] ?? '',
      preview: map['previewUrl'] ?? '',
      category: PostCategory.fromId(map['categorySlug']),
      canvasId: map['canvasId'] ?? '',
    );
  }
}