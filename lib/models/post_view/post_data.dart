import 'package:dia_room/models/post_creator/workshop_link.dart';

import '../enums/categories.dart';

class PostData {
  final String roomId;
  final String postId;
  final String title;
  final String preview;
  final Categories category;
  final String canvasId;
  final WorkshopLink workshopLink;

  PostData({
    required this.roomId,
    required this.postId,
    required this.title,
    required this.preview,
    required this.category,
    required this.canvasId,
    required this.workshopLink,
  });

  factory PostData.fromMap(Map<String, dynamic> map) {
    return PostData(
      roomId: map['roomId'] ?? '',
      postId: map['postId'] ?? '',
      title: map['title'] ?? '',
      preview: map['previewUrl'] ?? '',
      category: Categories.fromSlug(map['categorySlug']),
      canvasId: map['canvasId'] ?? '',
      workshopLink: WorkshopLink.fromMap(map),
    );
  }
}