class Statistics {
  final int views;
  final int likes;

  Statistics({required this.views, required this.likes});

  factory Statistics.fromMap(Map<String, dynamic> map) {
    return Statistics(
      views: map['viewsCount'] ?? 0,
      likes: map['likesCount'] ?? 0,
    );
  }
}