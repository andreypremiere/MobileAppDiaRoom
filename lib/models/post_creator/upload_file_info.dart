class UploadFileInfo {
  final String uploadId;
  final String filename;
  final String contentType;


  UploadFileInfo({
    required this.filename,
    required this.contentType,
    required this.uploadId
  });

  Map<String, dynamic> toJson() {
    return {
      'uploadId': uploadId,
      'filename': filename,
      'contentType': contentType,
    };
  }
}