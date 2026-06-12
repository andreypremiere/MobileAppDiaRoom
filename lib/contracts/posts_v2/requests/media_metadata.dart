class MediaMetadata {
  final int width;
  final int height;
  final String mimeType;

  MediaMetadata({
    required this.width,
    required this.height,
    required this.mimeType,
  });

  Map<String, dynamic> toMap() {
    return {
      'width': width,
      'height': height,
      'mimeType': mimeType,
    };
  }

  factory MediaMetadata.fromMap(Map<String, dynamic> map) {
    return MediaMetadata(
      width: map['width'] as int,
      height: map['height'] as int,
      mimeType: map['mimeType'] as String,
    );
  }
}