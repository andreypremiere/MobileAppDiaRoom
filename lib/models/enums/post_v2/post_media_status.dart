enum MediaStatus {
  uploading('uploading', "Загрузка"),
  processing('processing', "Обработка"),
  ready('ready', "Готов"),
  failed('failed', "Ошибка");

  final String value;
  final String name;

  const MediaStatus(this.value, this.name);

  String toMap() => value;

  factory MediaStatus.fromMap(dynamic mapValue) {
    if (mapValue == null) return MediaStatus.failed;

    return MediaStatus.values.firstWhere(
          (e) => e.value == mapValue.toString().toLowerCase(),
      orElse: () => MediaStatus.failed,
    );
  }
}