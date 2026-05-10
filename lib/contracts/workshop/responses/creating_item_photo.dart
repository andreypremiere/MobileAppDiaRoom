class CreatingItemPhoto {
  final String itemId;
  final String presignedUrlPreview;
  final String presignedUrlOriginal;

  CreatingItemPhoto({required this.itemId, required this.presignedUrlPreview, required this.presignedUrlOriginal});

  factory CreatingItemPhoto.fromMap(Map<String, dynamic> item) {
    return CreatingItemPhoto(
      itemId: item['itemId'],
      presignedUrlPreview: item['presignedUrlPreview'],
      presignedUrlOriginal: item['presignedUrlOriginal']
    );
  }
}