import 'package:dia_room/contracts/diary/response/getting_messages.dart';
import 'package:dia_room/models/enums/diary/message_status.dart';

class MessageCreateResponse {
  final String messageId;
  final MessageStatus status;
  final List<AttachmentUploadItem> uploadItems;


  MessageCreateResponse({
    required this.messageId,
    required this.status,
    required this.uploadItems,
  });

  factory MessageCreateResponse.fromMap(Map<String, dynamic> map) {
    return MessageCreateResponse(
      messageId: map['messageId'],
      status: MessageStatus.fromJson(map['status']),
      uploadItems: (map['uploadItems'] as List<dynamic>?)
          ?.map((item) => AttachmentUploadItem.fromMap(item as Map<String, dynamic>))
          .toList() ??
          [],
    );
  }
}

class AttachmentUploadItem {
  final String attachmentId;
  final String presignedUrl;
  final String? presignedPreviewUrl;

  AttachmentUploadItem({
    required this.attachmentId,
    required this.presignedUrl,
    this.presignedPreviewUrl,
  });

  factory AttachmentUploadItem.fromMap(Map<String, dynamic> map) {
    return AttachmentUploadItem(
      attachmentId: map['attachmentId'],
      presignedUrl: map['presignedUrl'],
      presignedPreviewUrl: map['presignedPreviewUrl'],
    );
  }
}