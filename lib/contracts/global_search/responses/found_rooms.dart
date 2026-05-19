import 'package:dia_room/models/global_search/room_info.dart';

class FoundRooms {
  final List<RoomInfo> rooms;

  FoundRooms({required this.rooms});

  factory FoundRooms.fromMap(Map<String, dynamic> map) {
    return FoundRooms(
      rooms: (map["rooms"] as List<dynamic>)
          .map((item) => RoomInfo.fromMap(item as Map<String, dynamic>))
          .toList(),
    );
  }
}