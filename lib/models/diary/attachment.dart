import '../enums/diary/attachment_type.dart';

class Attachment {
  final String id;
  final String messageId;
  final AttachmentType attType;
  final String s3Key;
  final String? previewS3Key;
  final int fileSizeBytes;
  final int? duration;
  final DateTime createdAt;

  Attachment({
    required this.id,
    required this.messageId,
    required this.attType,
    required this.s3Key,
    this.previewS3Key,
    required this.fileSizeBytes,
    this.duration,
    required this.createdAt,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'messageId': messageId,
      'attType': attType.toJson(),
      's3Key': s3Key,
      'previewS3Key': previewS3Key,
      'fileSizeBytes': fileSizeBytes,
      'duration': duration,
      'createdAt': createdAt.toIso8601String(),
    };
  }

  factory Attachment.fromMap(Map<String, dynamic> map) {
    return Attachment(
      id: map['id'] ?? '',
      messageId: map['messageId'] ?? '',
      attType: AttachmentType.fromJson(map['attType'] ?? ''),
      s3Key: map['s3Key'] ?? '',
      previewS3Key: map['previewS3Key'],
      fileSizeBytes: (map['fileSizeBytes'] as num?)?.toInt() ?? 0,
      duration: (map['duration'] as num?)?.toInt(),
      createdAt: map['createdAt'] != null
          ? DateTime.parse(map['createdAt'])
          : DateTime.now(),
    );
  }
}