import 'package:dia_room/models/diary/attachment.dart';
import 'package:dia_room/models/diary/message.dart';

class GettingMessages {
  final List<MessagePresentation> messages;

  GettingMessages({required this.messages});

  factory GettingMessages.fromMap(Map<String, dynamic> map) {
    return GettingMessages(
      messages: (map['messages'] as List? ?? [])
          .map((el) => MessagePresentation.fromMap(el))
          .toList(),
    );
  }
}

class MessagePresentation {
  final Message message;
  final List<Attachment> attachments;

  MessagePresentation({required this.message, required this.attachments});

  factory MessagePresentation.fromMap(Map<String, dynamic> map) {
    return MessagePresentation(
      message: Message.fromMap(map),
      attachments: (map['attachments'] as List? ?? [])
          .map((el) => Attachment.fromMap(el))
          .toList(),
    );
  }
}