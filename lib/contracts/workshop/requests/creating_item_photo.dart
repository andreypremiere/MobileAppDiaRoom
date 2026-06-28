import 'package:dia_room/models/enums/workshop/item_type.dart';
import 'package:dia_room/models/enums/workshop/mime_type.dart';

class CreatingItemPhoto {
  final String title;
  final MimeType mimeType;
  final String? folderId;
  final int sizeBytes;
  final ItemType itemType;

  CreatingItemPhoto({
    required this.title,
    required this.mimeType,
    required this.folderId,
    required this.sizeBytes,
    required this.itemType,
  });

  Map<String, dynamic> toMap() {
    return {
      'title': title,
      'mimeType': mimeType.mimeType,
      'folderId': folderId,
      'sizeBytes': sizeBytes,
      'itemType': itemType.slug,
    };
  }
}