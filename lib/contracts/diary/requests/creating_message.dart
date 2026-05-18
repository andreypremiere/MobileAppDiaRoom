import 'package:dia_room/models/diary/tag.dart';
import 'package:dia_room/models/enums/diary/attachment_type.dart';
import 'package:dia_room/models/enums/diary/message_type.dart';

class CreatingMessage {
  final MessageType type;
  final String? text;
  final List<AttachmentCreating> attachments;
  final String? workshopFolderId;
  final String? publicationPostId;
  final List<MessageTag> tags;

  CreatingMessage({
    required this.type,
    this.text,
    this.attachments = const [],
    this.workshopFolderId,
    this.publicationPostId,
    required this.tags,
  });

  Map<String, dynamic> toMap() {
    return {
      'msgType': type.toJson(),
      'content': text,
      'attachments': attachments.map((x) => x.toMap()).toList(),
      'workshopFolderId': workshopFolderId,
      'publicationPostId': publicationPostId,
      'tags': tags.map((x) => x.toMap()).toList()
    };
  }
}

class AttachmentCreating {
  final AttachmentType attachmentType;
  final int fileSize;
  final Duration? duration;
  final String mimeType;

  AttachmentCreating({
    required this.attachmentType,
    required this.fileSize,
    this.duration,
    required this.mimeType,
  });

  Map<String, dynamic> toMap() {
    return {
      'attType': attachmentType.toJson(),
      'fileSizeBytes': fileSize,
      'duration': duration?.inMilliseconds,
      'mimeType': mimeType,
    };
  }
}