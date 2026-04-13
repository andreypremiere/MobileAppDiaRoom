class Author {
  final String roomId;
  final String roomName;
  final String avatar;

  Author({
    required this.roomId,
    required this.roomName,
    required this.avatar,
  });

  factory Author.fromMap(Map<String, dynamic> map) {
    return Author(
      // Используем те ключи, которые приходят в твоем "плоском" ответе
      roomId: map['roomId'] ?? '',
      roomName: map['roomName'] ?? 'Unknown Room',
      avatar: map['avatarUrl'] ?? '',
    );
  }
}