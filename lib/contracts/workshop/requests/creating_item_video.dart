import 'package:dia_room/models/enums/workshop/item_type.dart';
import 'package:dia_room/models/enums/workshop/mime_type.dart';

class CreatingItemVideo {
  final String title;
  final MimeType mimeType;
  final String? folderId;
  final int sizeBytes;
  final ItemType itemType;
  final Duration duration;

  CreatingItemVideo({
    required this.title,
    required this.mimeType,
    required this.folderId,
    required this.sizeBytes,
    required this.itemType,
    required this.duration,
  });

  Map<String, dynamic> toMap() {
    return {
      'title': title,
      'mimeType': mimeType.mimeType,
      'folderId': folderId,
      'sizeBytes': sizeBytes,
      'itemType': itemType.slug,
      'duration': duration.inMilliseconds,
    };
  }
}