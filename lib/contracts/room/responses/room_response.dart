import 'package:dia_room/models/enums/categories.dart';

class RoomResponse {
  final String roomUniqueId;
  final String roomName;
  final List<Categories> listCategory;
  final String bio;
  final String avatarPath;
  final String backgroundPath;
  final int countFollowers;
  final int countFollowing;

  RoomResponse({
    required this.roomUniqueId,
    required this.roomName,
    required this.listCategory,
    required this.bio,
    required this.avatarPath,
    required this.backgroundPath,
    required this.countFollowers,
    required this.countFollowing,
  });

  factory RoomResponse.fromMap(Map<String, dynamic> map) {
    return RoomResponse(
      roomUniqueId: map['roomUniqueId'] ?? '',
      roomName: map['roomName'] ?? '',
      // Безопасное приведение списка категорий
      listCategory: List<String>.from(map['listCategory'] ?? []).map((slug) => Categories.fromSlug(slug)).toList(),
      bio: map['bio'] ?? '',
      avatarPath: map['avatarPath'] ?? '',
      backgroundPath: map['backgroundPath'] ?? '',
      countFollowers: map['countFollowers'] ?? 0,
      countFollowing: map['countFollowing'] ?? 0,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'roomUniqueId': roomUniqueId,
      'roomName': roomName,
      'listCategory': listCategory,
      'bio': bio,
      'avatarPath': avatarPath,
      'backgroundPath': backgroundPath,
      'countFollowers': countFollowers,
      'countFollowing': countFollowing,
    };
  }
}