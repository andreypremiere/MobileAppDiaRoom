import '../../../models/i_comment_item.dart';
import '../../../models/post_view/author.dart';

class CommentResponse implements ICommentItem {
  final String id;
  final String messageId;
  final String roomId;
  final String text;
  final DateTime createdAt;
  final Author? author;

  const CommentResponse({
    required this.id,
    required this.messageId,
    required this.roomId,
    required this.text,
    required this.createdAt,
    this.author,
  });

  factory CommentResponse.fromMap(Map<String, dynamic> map) {
    return CommentResponse(
      id: map['id'] ?? '',
      messageId: map['messageId'] ?? '',
      roomId: map['roomId'] ?? '',
      text: map['content'] ?? '',
      createdAt: map['createdAt'] != null
          ? DateTime.parse(map['createdAt']).toLocal()
          : DateTime.now(),
      author: map['author'] != null ? Author.fromMap(map['author']) : null,
    );
  }

  String get formattedDate {
    final hour = createdAt.hour.toString().padLeft(2, '0');
    final minute = createdAt.minute.toString().padLeft(2, '0');
    return '$hour:$minute';
  }
}