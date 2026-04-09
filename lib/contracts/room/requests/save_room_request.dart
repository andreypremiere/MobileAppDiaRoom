import 'package:dia_room/models/enums/room_categories.dart';
import 'package:path/path.dart' as p;


class SaveRoomRequest {
  final String roomUniqueId;
  final String roomName;
  final List<RoomCategory>? listCategory;
  final String? bio;
  final String? avatarPath;
  final String? backgroundPath;

  SaveRoomRequest({
    required this.roomUniqueId,
    required this.roomName,
    this.listCategory,
    this.bio,
    this.avatarPath,
    this.backgroundPath
});

  String? _getFileName(String? path) {
    if (path == null || path.isEmpty) return '';
    return p.basename(path); // Извлекает например 'image_picker_432.jpg'
  }

  Map<String, dynamic> toMap() {
    return {
      "roomUniqueId": roomUniqueId,
      "roomName": roomName,
      "bio": bio,
      "categories": listCategory != null && listCategory!.isNotEmpty ? listCategory!.map((e) => e.slug).toList() : [],
      "avatar_filename": _getFileName(avatarPath),
      "background_filename": _getFileName(backgroundPath),
    };
  }
}