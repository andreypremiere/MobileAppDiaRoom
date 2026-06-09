import '../../../models/enums/post_v2/post_status.dart';

class UpdatingPostStatus {
  final String id;
  final PostStatus status;

  UpdatingPostStatus({
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