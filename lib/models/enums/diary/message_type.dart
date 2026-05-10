enum MessageType {
  standard,
  voice,
  videoNote;

  String toJson() => nameValue[this]!;
  static MessageType fromJson(String value) =>
      valueMap[value] ?? MessageType.standard;

  static const valueMap = {
    'standard': MessageType.standard,
    'voice_note': MessageType.voice,
    'video_note': MessageType.videoNote,
  };

  static const nameValue = {
    MessageType.standard: 'standard',
    MessageType.voice: 'voice_note',
    MessageType.videoNote: 'video_note',
  };
}

