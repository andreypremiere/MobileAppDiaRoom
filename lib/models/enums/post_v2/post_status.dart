enum PostStatus {
  uploading('uploading', "Загрузка"),
  processing('processing', "Обработка"),
  published('published', "Опубликован"),
  error('error', "Ошибка");

  final String value;
  final String name;

  const PostStatus(this.value, this.name);

  String toMap() => value;

  factory PostStatus.fromMap(dynamic mapValue) {
    if (mapValue == null) return PostStatus.error;

    return PostStatus.values.firstWhere(
          (e) => e.value == mapValue.toString().toLowerCase(),
      orElse: () => PostStatus.error,
    );
  }
}