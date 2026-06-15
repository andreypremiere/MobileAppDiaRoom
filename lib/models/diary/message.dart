import 'dart:convert';

import 'package:dia_room/models/enums/diary/message_status.dart';

import '../enums/diary/message_type.dart';

class Message {
  final String id;
  final String roomId;
  final MessageType msgType;
  MessageStatus status;
  final String? content;
  final List<dynamic>? contentJson;
  final String? attachedObjectWorkshopId;
  final String? attachedObjectPostId;
  final String? attachedObjectPostV2Id;
  final DateTime createdAt;
  final DateTime updatedAt;
  final DateTime? deletedAt;
  int countComments;

  Message({
    required this.id,
    required this.roomId,
    required this.msgType,
    this.content,
    this.contentJson,
    required this.status,
    this.attachedObjectWorkshopId,
    this.attachedObjectPostId,
    this.attachedObjectPostV2Id,
    required this.createdAt,
    required this.updatedAt,
    this.deletedAt,
    required this.countComments
  });

  // Map<String, dynamic> toMap() {
  //   return {
  //     'id': id,
  //     'roomId': roomId,
  //     'msgType': msgType.toJson(),
  //     'status': status.toJson(),
  //     'content': content,
  //     'attachedObjectWorkshopId': attachedObjectWorkshopId,
  //     'attachedObjectPostId': attachedObjectPostId,
  //     'createdAt': createdAt.toIso8601String(),
  //     'updatedAt': updatedAt.toIso8601String(),
  //     'deletedAt': deletedAt?.toIso8601String(),
  //   };
  // }

  factory Message.fromMap(Map<String, dynamic> map) {

    List<dynamic>? parsedJson;

    // Безопасно парсим contentJson, если он пришел от сервера
    if (map['contentJson'] != null) {
      if (map['contentJson'] is String) {
        parsedJson = jsonDecode(map['contentJson']);
      } else {
        parsedJson = map['contentJson'] as List<dynamic>;
      }
    }

    return Message(
      id: map['id'] ?? '',
      roomId: map['roomId'] ?? '',
      msgType: MessageType.fromJson(map['msgType'] ?? ''),
      status: MessageStatus.fromJson(map['status'] ?? ''),
      content: map['content'],
      contentJson: parsedJson,
      attachedObjectWorkshopId: map['attachedObjectWorkshopId'],
      attachedObjectPostId: map['attachedObjectPostId'],
      attachedObjectPostV2Id: map['attachedObjectPostV2Id'],
      createdAt: map['createdAt'] != null
          ? DateTime.parse(map['createdAt'])
          : DateTime.now(),
      updatedAt: map['updatedAt'] != null
          ? DateTime.parse(map['updatedAt'])
          : DateTime.now(),
      deletedAt: map['deletedAt'] != null
          ? DateTime.parse(map['deletedAt'])
          : null,
      countComments: map['countComments'] ?? 0
    );
  }
}