import 'package:dia_room/models/room.dart';

import 'enums/room_categories.dart';

class BaseRoom {
  String uniqueRoomId;
  String roomName;
  String bio;
  String avatarUrl;
  String backgroundUrl;
  List<RoomCategory> listCategory;
  int countFollowers;
  int countFollowing;

  BaseRoom({
    required this.uniqueRoomId,
    required this.roomName,
    required this.bio,
    required this.avatarUrl,
    required this.backgroundUrl,
    required this.listCategory,
    required this.countFollowers,
    required this.countFollowing
});

  static BaseRoom fromMap(Map<String, dynamic> map) {
    return BaseRoom(
      uniqueRoomId: map['roomUniqueId'] ?? '',
      roomName: map['roomName'] ?? '',
      bio: map['bio'] ?? '',
      avatarUrl: map['avatarPath'] ?? '',
      backgroundUrl: map['backgroundPath'] ?? '',
      // Конвертируем List<dynamic> (слаги) в List<RoomCategory>
      listCategory: (map['listCategory'] as List<dynamic>?)
          ?.map((slug) => RoomCategory.fromSlug(slug.toString()))
          .whereType<RoomCategory>()
          .toList() ?? [],
      countFollowers: map['countFollowers'] ?? 0,
      countFollowing: map['countFollowing'] ?? 0
    );
  }
}