import 'package:dia_room/models/post_view/author.dart';

class CommentResponse {
  final String id;
  final String postId;
  final String text;
  final DateTime createdAt;
  final Author? author;

  const CommentResponse({
    required this.id,
    required this.postId,
    required this.text,
    required this.createdAt,
    this.author,
  });

  factory CommentResponse.fromMap(Map<String, dynamic> map) {
    return CommentResponse(
      id: map['id'] ?? '',
      postId: map['postId'] ?? '',
      text: map['text'] ?? '',
      createdAt: map['createdAt'] != null
          ? DateTime.parse(map['createdAt']).toLocal()
          : DateTime.now(),
      // Безопасно парсим автора, если он пришел в ответе
      author: map['author'] != null ? Author.fromMap(map['author']) : null,
    );
  }

  String get formattedDate {
    final hour = createdAt.hour.toString().padLeft(2, '0');
    final minute = createdAt.minute.toString().padLeft(2, '0');
    return '$hour:$minute';
  }
}
