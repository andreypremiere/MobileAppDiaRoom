class RoomInfo {
  final String id;
  final String roomUniqueId;
  final String nickname;
  final String avatarUrl;

  const RoomInfo({
    required this.id,
    required this.roomUniqueId,
    required this.nickname,
    required this.avatarUrl,
  });

  factory RoomInfo.fromMap(Map<String, dynamic> map) {
    return RoomInfo(
      id: map['id'] as String,
      roomUniqueId: map['roomUniqueId'] as String,
      nickname: map['nickname'] as String,
      avatarUrl: map['avatarUrl'] as String,
    );
  }

}