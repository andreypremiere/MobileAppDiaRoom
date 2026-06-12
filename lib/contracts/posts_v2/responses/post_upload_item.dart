class PostUploadItem {
  final int order;
  final String presignedUrl;

  PostUploadItem({
    required this.order,
    required this.presignedUrl,
  });

  Map<String, dynamic> toMap() {
    return {
      'order': order,
      'presignedUrl': presignedUrl,
    };
  }

  factory PostUploadItem.fromMap(Map<String, dynamic> map) {
    return PostUploadItem(
      order: map['order'] as int,
      presignedUrl: map['presignedUrl'] as String,
    );
  }
}