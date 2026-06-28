import '../../../models/enums/post_v2/post_media_status.dart';

class UpdatingMediaPostStatus {
  final String id;
  final MediaStatus status;

  UpdatingMediaPostStatus({
    required this.id,
    required this.status,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'status': status.toMap(),
    };
  }
}