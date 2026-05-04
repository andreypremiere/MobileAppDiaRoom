import 'package:dia_room/models/workshop/item.dart';
import '../../../models/workshop/folder.dart';

class Content {
  List<Folder> folders;
  List<Item> items;

  Content({required this.folders, required this.items});

  factory Content.fromMap(Map<String, dynamic> map) {
    return Content(
      folders: (map['folders'] as List<dynamic>?)
          ?.map((item) => Folder.fromMap(item as Map<String, dynamic>))
          .toList() ?? [],
      items: (map['items'] as List<dynamic>?)
          ?.map((item) => Item.fromMap(item as Map<String, dynamic>))
          .toList() ?? [],
    );
  }
}