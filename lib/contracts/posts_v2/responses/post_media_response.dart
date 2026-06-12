import '../../../models/enums/post_v2/post_media_status.dart';

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

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'order': order,
      'urlSmall': urlSmall,
      'urlMedium': urlMedium,
      'status': status.toMap(),
      'width': width,
      'height': height,
    };
  }

  factory PostMediaResponse.fromMap(Map<String, dynamic> map) {
    return PostMediaResponse(
      id: map['id'] as String,
      order: map['order'] as int,
      urlSmall: map['urlSmall'] as String,
      urlMedium: map['urlMedium'] as String,
      status: MediaStatus.fromMap(map['status'] as String),
      width: map['width'] as int,
      height: map['height'] as int,
    );
  }
}