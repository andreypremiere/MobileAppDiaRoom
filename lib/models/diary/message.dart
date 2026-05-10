import '../enums/diary/message_type.dart';
import 'attachment.dart';

class Message {
  final String id;
  final String roomId;
  final MessageType msgType;
  final String? content;
  final String? attachedObjectWorkshopId;
  final String? attachedObjectPostId;
  final DateTime createdAt;
  final DateTime updatedAt;
  final DateTime? deletedAt;
  final List<Attachment> attachments;

  Message({
    required this.id,
    required this.roomId,
    required this.msgType,
    this.content,
    this.attachedObjectWorkshopId,
    this.attachedObjectPostId,
    required this.createdAt,
    required this.updatedAt,
    this.deletedAt,
    this.attachments = const [],
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'roomId': roomId,
      'msgType': msgType.toJson(),
      'content': content,
      'attachedObjectWorkshopId': attachedObjectWorkshopId,
      'attachedObjectPostId': attachedObjectPostId,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
      'deletedAt': deletedAt?.toIso8601String(),
      'attachments': attachments.map((x) => x.toMap()).toList(),
    };
  }

  factory Message.fromMap(Map<String, dynamic> map) {
    return Message(
      id: map['id'] ?? '',
      roomId: map['roomId'] ?? '',
      msgType: MessageType.fromJson(map['msgType'] ?? ''),
      content: map['content'],
      attachedObjectWorkshopId: map['attachedObjectWorkshopId'],
      attachedObjectPostId: map['attachedObjectPostId'],
      createdAt: map['createdAt'] != null
          ? DateTime.parse(map['createdAt'])
          : DateTime.now(),
      updatedAt: map['updatedAt'] != null
          ? DateTime.parse(map['updatedAt'])
          : DateTime.now(),
      deletedAt: map['deletedAt'] != null
          ? DateTime.parse(map['deletedAt'])
          : null,
      attachments: map['attachments'] != null
          ? List<Attachment>.from(
          (map['attachments'] as List).map((x) => Attachment.fromMap(x)))
          : [],
    );
  }
}