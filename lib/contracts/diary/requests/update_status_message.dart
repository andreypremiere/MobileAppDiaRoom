import 'package:dia_room/models/enums/diary/message_status.dart';

class UpdatingMessage {
  final String messageId;
  final MessageStatus status;

  UpdatingMessage({
    required this.messageId,
    required this.status,
  });

  Map<String, dynamic> toMap() {
    return {
      'messageId': messageId,
      'status': status.toJson(),
    };
  }
}