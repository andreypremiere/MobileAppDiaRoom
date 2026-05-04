enum ItemStatus {
  uploading('uploading'),
  ready('ready'),
  failed('failed');

  final String slug;

  const ItemStatus(this.slug);

  static ItemStatus fromMap(Map<String, dynamic> map) {
    final mapSlug = map['status'] as String?;
    return ItemStatus.values.firstWhere(
          (e) => e.slug == mapSlug,
      orElse: () => ItemStatus.failed,
    );
  }
}