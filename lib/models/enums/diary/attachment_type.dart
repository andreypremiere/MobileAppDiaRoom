enum AttachmentType {
  photo,
  video,
  voiceNote,
  videoNote;

  String toJson() => nameValue[this]!;
  static AttachmentType fromJson(String value) =>
      valueMap[value] ?? AttachmentType.photo;

  static const valueMap = {
    'photo': AttachmentType.photo,
    'video': AttachmentType.video,
    'voice_note': AttachmentType.voiceNote,
    'video_note': AttachmentType.videoNote,
  };

  static const nameValue = {
    AttachmentType.photo: 'photo',
    AttachmentType.video: 'video',
    AttachmentType.voiceNote: 'voice_note',
    AttachmentType.videoNote: 'video_note',
  };
}