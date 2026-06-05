import 'package:dia_room/models/diary/message.dart';
import 'package:dia_room/models/post_view/author.dart';

class Diaries {
  final List<DiaryCard> diaries;

  Diaries({required this.diaries});

  factory Diaries.fromMap(Map<String, dynamic> map) {
    return Diaries(
      diaries: (map['diaries'] as List<dynamic>?)
          ?.map((diary) => DiaryCard.fromMap(diary as Map<String, dynamic>))
          .toList() ?? [],
    );
  }
}

class DiaryCard {
  final Author author;
  final DateTime? lastMessageAt;
  final Message? message;
  final int unreadCount;

  DiaryCard({
    required this.author,
    required this.lastMessageAt,
    this.message,
    required this.unreadCount,
  });

  DiaryCard copyWith({
    Author? author,
    DateTime? lastMessageAt,
    Message? message,
    int? unreadCount,
  }) {
    return DiaryCard(
      author: author ?? this.author,
      lastMessageAt: lastMessageAt ?? this.lastMessageAt,
      message: message ?? this.message,
      unreadCount: unreadCount ?? this.unreadCount,
    );
  }

  factory DiaryCard.fromMap(Map<String, dynamic> map) {
    return DiaryCard(
      author: Author.fromMap(map['author'] as Map<String, dynamic>),
      lastMessageAt: map['lastMessageAt'] != null
          ? DateTime.parse(map['lastMessageAt'] as String)
          : null,
      message: map['lastMessage'] != null
          ? Message.fromMap(map['lastMessage'] as Map<String, dynamic>)
          : null,
      unreadCount: map['unreadCount'] as int? ?? 0,
    );
  }
}