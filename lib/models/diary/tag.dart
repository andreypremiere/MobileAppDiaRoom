import 'dart:ui';

class MessageTag {
  final String id;
  final String roomId;
  final String name;
  final Color color;

  MessageTag({
    required this.id,
    required this.name,
    required this.roomId,
    required int colorValue,
  }) : color = Color(colorValue);

  factory MessageTag.fromMap(Map<String, dynamic> map) {
    return MessageTag(
        id: map['id'] ?? "",
        name: map['name'] ?? "",
        roomId: map['roomId'] ?? "",
        colorValue: map['color'] ?? 0);
  }

  Map<String, dynamic> toMap() {
    return {"name": name, "color": color.toARGB32(), "id": id, "roomId": roomId};
  }
}