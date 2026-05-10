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

  // // Создание объекта из Map (для чтения из БД или ответа сервера)
  // factory CreatingItemPhoto.fromMap(Map<String, dynamic> map) {
  //   return CreatingItemPhoto(
  //     title: map['title'] ?? '',
  //     mimeType: map['mimeType'] ?? '',
  //     folderId: map['folderId'] ?? '',
  //     sizeBytes: map['sizeBytes']?.toInt() ?? 0,
  //     itemType: map['itemType'] ?? '',
  //   );
  // }
}