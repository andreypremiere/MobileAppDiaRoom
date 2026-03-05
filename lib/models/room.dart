import 'package:flutter/foundation.dart';

class Category {
  final String slug;
  final String name;

  Category({required this.slug, required this.name});

  factory Category.fromJson(Map<String, dynamic> json) {
    return Category(slug: json['slug'] as String, name: json['name'] as String);
  }
}

class Room {
  final String id;
  final String userId;
  final String roomName;
  final String roomNameId;
  final List<Category> categories;
  final String? avatarUrl;
  final String? bio;
  final Map<String, dynamic> settings;
  final int followersCount;
  final int followingCount;

  Room({
    required this.id,
    required this.userId,
    required this.roomName,
    required this.roomNameId,
    required this.categories,
    this.avatarUrl,
    this.bio,
    required this.settings,
    this.followersCount = 0,
    this.followingCount = 0,
  });

  static Room? fromJson(Map<String, dynamic> json) {
    Room room;
    try {
      room = Room(
        id: json['id'] as String,
        userId: json['user_id'] as String,
        roomName: json['room_name'] as String,
        roomNameId: json['room_name_id'] as String,
        categories:
            (json['categories'] as List<dynamic>?)
                ?.map((e) => Category.fromJson(e as Map<String, dynamic>))
                .toList() ??
            [],
        avatarUrl: json['avatar_url'] as String?,
        bio: json['bio'] as String?,
        settings: json['settings'] as Map<String, dynamic>? ?? {},
        followersCount: json['followers_count'] as int? ?? 0,
        followingCount: json['following_count'] as int? ?? 0,
      );
    } catch (e) {
      print('Возникла ошибка во время создания Room');
      return null;
    }
    return room;
  }
}
