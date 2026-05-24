import '../../../models/workshop/item.dart';

class CreatingItemVideo {
  final String itemId;
  final String presignedUrlPreview;
  final String presignedUrlOriginal;
  final Item item;

  CreatingItemVideo({required this.itemId, required this.presignedUrlPreview, required this.presignedUrlOriginal, required this.item});

  factory CreatingItemVideo.fromMap(Map<String, dynamic> item) {
    return CreatingItemVideo(
        itemId: item['itemId'],
        presignedUrlPreview: item['presignedUrlPreview'],
        presignedUrlOriginal: item['presignedUrlOriginal'],
        item: Item.fromMap(item['item']),
    );
  }
}