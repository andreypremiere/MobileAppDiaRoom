enum MessageType {
  standard,
  voiceNote,
  videoNote;

  String toJson() => nameValue[this]!;
  static MessageType fromJson(String value) =>
      valueMap[value] ?? MessageType.standard;

  static const valueMap = {
    'standard': MessageType.standard,
    'voice_note': MessageType.voiceNote,
    'video_note': MessageType.videoNote,
  };

  static const nameValue = {
    MessageType.standard: 'standard',
    MessageType.voiceNote: 'voice_note',
    MessageType.videoNote: 'video_note',
  };
}

