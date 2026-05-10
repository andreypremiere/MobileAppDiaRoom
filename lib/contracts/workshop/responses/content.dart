import 'package:dia_room/models/enums/workshop/item_status.dart';
import 'package:dia_room/models/workshop/item.dart';
import '../../../models/enums/workshop/item_type.dart';
import '../../../models/workshop/folder.dart';

class Content {
  List<Folder> folders;
  List<Item> items;

  Content({required this.folders, required this.items});

  factory Content.fromMap(Map<String, dynamic> map) {
    final itemsList = (map['items'] as List<dynamic>?)
        ?.map((item) => Item.fromMap(item as Map<String, dynamic>))
        .toList() ?? [];

    itemsList.sort((a, b) {
      final weightA = a.itemType == ItemType.video ? 0 : 1;
      final weightB = b.itemType == ItemType.photo ? 0 : 1;
      return weightA.compareTo(weightB);
    });

    return Content(
      folders: (map['folders'] as List<dynamic>?)
          ?.map((item) => Folder.fromMap(item as Map<String, dynamic>))
          .toList() ?? [],
      items: itemsList,
    );
  }
}