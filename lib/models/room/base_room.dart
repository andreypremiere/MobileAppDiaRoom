import '../enums/categories.dart';

class BaseRoom {
  String uniqueRoomId;
  String roomName;
  String bio;
  String avatarUrl;
  String backgroundUrl;
  List<Categories> listCategory;
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
      listCategory: (map['listCategory'] as List<dynamic>?)
          ?.map((slug) => Categories.fromSlug(slug.toString()))
          .whereType<Categories>()
          .toList() ?? [],
      countFollowers: map['countFollowers'] ?? 0,
      countFollowing: map['countFollowing'] ?? 0
    );
  }
}