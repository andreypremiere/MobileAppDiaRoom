class CreatingItemVideo {
  final String itemId;
  final String presignedUrlPreview;
  final String presignedUrlOriginal;

  CreatingItemVideo({required this.itemId, required this.presignedUrlPreview, required this.presignedUrlOriginal});

  factory CreatingItemVideo.fromMap(Map<String, dynamic> item) {
    return CreatingItemVideo(
        itemId: item['itemId'],
        presignedUrlPreview: item['presignedUrlPreview'],
        presignedUrlOriginal: item['presignedUrlOriginal']
    );
  }
}