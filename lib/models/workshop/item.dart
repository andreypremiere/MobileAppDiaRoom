import 'package:dia_room/models/enums/workshop/item_type.dart';

abstract class BasePayload {
  Map<String, dynamic> toMap();

  static BasePayload? fromMap(ItemType itemType, Map<String, dynamic>? map) {
    if (map == null) return null;

    switch (itemType) {
      case ItemType.photo:
        return PhotoPayload.fromMap(map);
      default:
        return null;
    }
  }
}

class PhotoPayload extends BasePayload {
  int? width;
  int? height;
  String? publicUrl;
  String? presignedUrl;

  PhotoPayload({
    this.width,
    this.height,
    this.publicUrl,
    this.presignedUrl
  });

  factory PhotoPayload.fromMap(Map<String, dynamic> map) {
    return PhotoPayload(
      width: map['width'],
      height: map['height'],
      publicUrl: map['publicUrl'],
      presignedUrl: map['presignedUrl']
    );
  }

  @override
  Map<String, dynamic> toMap() {
    return {
      'width': width,
      'height': height,
      'publicUrl': publicUrl,
      'presignedUrl': presignedUrl
    };
  }
}

class Item {
  String? id;
  final String roomId;
  String? folderId;
  String? title;
  String? previewUrl;
  int? sizeBytes;
  ItemType itemType;
  String? mimeType;
  String? status;
  BasePayload? payload;

  Item({
    this.id,
    required this.roomId,
    this.folderId,
    this.title,
    this.previewUrl,
    this.sizeBytes,
    required this.itemType,
    this.mimeType,
    this.status,
    this.payload,
  });

  factory Item.fromMap(Map<String, dynamic> map) {
    final ItemType itemType = ItemType.fromMap(map);
    return Item(
      id: map['id'],
      roomId: map['roomId'],
      folderId: map['folderId'],
      title: map['title'],
      previewUrl: map['previewUrl'] ?? '',
      sizeBytes: map['sizeBytes'] != null ? int.parse(map['sizeBytes'].toString()) : null,
      itemType: itemType,
      mimeType: map['mimeType'],
      status: map['status'],
      payload: BasePayload.fromMap(itemType, map['payload']),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'roomId': roomId,
      'folderId': folderId,
      'title': title,
      'previewUrl': previewUrl,
      'sizeBytes': sizeBytes,
      'itemType': itemType.slug,
      'mimeType': mimeType,
      'status': status,
      'payload': payload?.toMap(),
    };
  }
}

