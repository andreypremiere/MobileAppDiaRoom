import 'media_metadata.dart';

class MediaFileItem {
  final int order;
  final int fileSizeBytes;
  final MediaMetadata metadata;

  MediaFileItem({
    required this.order,
    required this.fileSizeBytes,
    required this.metadata,
  });

  Map<String, dynamic> toMap() {
    return {
      'order': order,
      'fileSizeBytes': fileSizeBytes,
      'metadata': metadata.toMap(),
    };
  }

  factory MediaFileItem.fromMap(Map<String, dynamic> map) {
    return MediaFileItem(
      order: map['order'] as int,
      fileSizeBytes: map['fileSizeBytes'] as int,
      metadata: MediaMetadata.fromMap(map['metadata'] as Map<String, dynamic>),
    );
  }
}