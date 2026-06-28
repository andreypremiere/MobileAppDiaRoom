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
      roomId: map['roomId'] ?? '',
      roomName: map['roomName'] ?? 'Unknown Room',
      avatar: map['avatarUrl'] ?? '',
    );
  }
}