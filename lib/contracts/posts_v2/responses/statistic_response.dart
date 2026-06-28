class StatisticResponse {
  final int likesCount;
  final int viewsCount;
  final int commentsCount;

  StatisticResponse({
    required this.likesCount,
    required this.viewsCount,
    required this.commentsCount,
  });

  Map<String, dynamic> toMap() {
    return {
      'likesCount': likesCount,
      'viewsCount': viewsCount,
      'commentsCount': commentsCount,
    };
  }

  factory StatisticResponse.fromMap(Map<String, dynamic> map) {
    return StatisticResponse(
      likesCount: map['likesCount'] as int? ?? 0,
      viewsCount: map['viewsCount'] as int? ?? 0,
      commentsCount: map['commentsCount'] as int? ?? 0,
    );
  }
}