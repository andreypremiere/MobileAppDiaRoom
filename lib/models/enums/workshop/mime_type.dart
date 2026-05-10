enum MimeType {
  imageJpeg('image/jpeg'),
  videoMP4('video/mp4');

  final String mimeType;

  const MimeType(this.mimeType);

  static MimeType fromMimeType(String? slug) {
    return MimeType.values.firstWhere(
          (e) => e.mimeType == slug,
      orElse: () => MimeType.imageJpeg,
    );
  }
}