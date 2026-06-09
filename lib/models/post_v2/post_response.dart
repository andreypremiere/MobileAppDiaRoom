// post_models.dart

import '../enums/post_v2/post_media_status.dart';
import '../enums/post_v2/post_status.dart';

class PostsRoom {
  final List<PostResponse> posts;

  PostsRoom({required this.posts});

  factory PostsRoom.fromMap(Map<String, dynamic> map) {
    return PostsRoom(
      posts: (map['posts'] as List? ?? [])
          .map((x) => PostResponse.fromMap(x as Map<String, dynamic>))
          .toList(),
    );
  }
}

class InternalRoomInfo {
  final String roomId;
  final String roomName;
  final String avatarUrl;

  InternalRoomInfo({
    required this.roomId,
    required this.roomName,
    required this.avatarUrl,
  });

  factory InternalRoomInfo.fromMap(Map<String, dynamic> map) {
    return InternalRoomInfo(
      roomId: map['roomId'] ?? '',
      roomName: map['roomName'] ?? '',
      avatarUrl: map['avatarUrl'] ?? '',
    );
  }
}

class PostMediaResponse {
  final String id;
  final int order;
  final String urlSmall;
  final String urlMedium;
  final MediaStatus status;
  final int width;
  final int height;

  PostMediaResponse({
    required this.id,
    required this.order,
    required this.urlSmall,
    required this.urlMedium,
    required this.status,
    required this.width,
    required this.height,
  });

  factory PostMediaResponse.fromMap(Map<String, dynamic> map) {
    return PostMediaResponse(
      id: map['id'] ?? '',
      order: map['order'] ?? 0,
      urlSmall: map['urlSmall'] ?? '',
      urlMedium: map['urlMedium'] ?? '',
      status: MediaStatus.fromMap(map['status']), // Твой кастомный парсинг
      width: map['width'] ?? 0,
      height: map['height'] ?? 0,
    );
  }
}

class PostResponse {
  final InternalRoomInfo? roomInfo;
  final String id;
  final String roomId;
  final String? description;
  final List<String> hashtags;
  final String? workshopLink;
  final PostStatus status;
  final DateTime createdAt;
  final List<PostMediaResponse> files;
  final int likesCount;
  final int viewsCount;
  final int commentsCount;
  final bool isLiked;

  PostResponse({
    this.roomInfo,
    required this.id,
    required this.roomId,
    this.description,
    required this.hashtags,
    this.workshopLink,
    required this.status,
    required this.createdAt,
    required this.files,
    required this.likesCount,
    required this.viewsCount,
    required this.commentsCount,
    required this.isLiked,
  });

  factory PostResponse.fromMap(Map<String, dynamic> map) {
    return PostResponse(
      roomInfo: map['roomInfo'] != null
          ? InternalRoomInfo.fromMap(map['roomInfo'] as Map<String, dynamic>)
          : null,
      id: map['id'] ?? '',
      roomId: map['roomId'] ?? '',
      description: map['description'] as String?,
      hashtags: List<String>.from(map['hashtags'] ?? []),
      workshopLink: map['workshopLink'] as String?,
      status: PostStatus.fromMap(map['status']), // Твой кастомный парсинг
      createdAt: map['createdAt'] != null
          ? DateTime.parse(map['createdAt'])
          : DateTime.now(),
      files: (map['files'] as List? ?? [])
          .map((x) => PostMediaResponse.fromMap(x as Map<String, dynamic>))
          .toList(),
      likesCount: _convertToInt(map['likesCount']),
      viewsCount: _convertToInt(map['viewsCount']),
      commentsCount: _convertToInt(map['commentsCount']),
      isLiked: map['isLiked'] ?? false,
    );
  }

  static int _convertToInt(dynamic value) {
    if (value == null) return 0;
    if (value is int) return value;
    return int.tryParse(value.toString()) ?? 0;
  }
}