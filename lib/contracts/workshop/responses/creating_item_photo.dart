import '../../../models/workshop/item.dart';

class CreatingItemPhoto {
  final String itemId;
  final String presignedUrlPreview;
  final String presignedUrlOriginal;
  final Item item;

  CreatingItemPhoto({required this.itemId, required this.presignedUrlPreview, required this.presignedUrlOriginal, required this.item});

  factory CreatingItemPhoto.fromMap(Map<String, dynamic> item) {
    return CreatingItemPhoto(
      itemId: item['itemId'],
      presignedUrlPreview: item['presignedUrlPreview'],
      presignedUrlOriginal: item['presignedUrlOriginal'],
      item: Item.fromMap(item['item'])
    );
  }
}