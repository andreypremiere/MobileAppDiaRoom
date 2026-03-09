// Canvas представляет собой класс содержимого поста (содержит текст,
// ссылки на картинки, фото, аудио и тд)
class Canvas {
  final String id;
  final List<Map<String, dynamic>> payload;

  Canvas({required this.id, required this.payload});

  // payload это json. В нем могут быть три типа ключа: text, photo, video

//   Добавить fromJson
}