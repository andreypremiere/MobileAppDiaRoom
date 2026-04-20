import '../post_view/author.dart';
import '../post_view/statistics.dart';

class ShowingPost {
  final Author author;
  final Statistics stats;
  final String roomId;
  final List<dynamic> payload; // Твой холст (canvas)
  final String categorySlug;
  final List<String> hashtags;

  ShowingPost({
    required this.author,
    required this.stats,
    required this.roomId,
    required this.payload,
    required this.categorySlug,
    required this.hashtags,
  });

  // Базовая фабрика, если вдруг понадобится создать просто пост
  factory ShowingPost.fromMap(Map<String, dynamic> map) {
    return ShowingPost(
      // Группируем данные автора
      author: Author.fromMap(map),
      // Группируем статистику
      stats: Statistics.fromMap(map),
      // Поля самого поста
      roomId: map['roomId'] ?? '',
      // payload приходит как List<dynamic>, внутри которого Map<String, dynamic>
      payload: map['payload'] as List<dynamic>? ?? [],
      categorySlug: map['categorySlug'] ?? '',
      // Безопасное приведение списка строк
      hashtags: map['hashtags'] != null
          ? List<String>.from(map['hashtags'])
          : [],
    );
  }
}