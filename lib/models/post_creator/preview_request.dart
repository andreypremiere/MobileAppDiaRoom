import 'package:uuid/uuid.dart';

class PreviewRequest {
  String previewId;
  String pathPreview;

  // Конструктор генерирует UUID по умолчанию, если не передан
  PreviewRequest({required this.pathPreview, String? previewId})
      : previewId = previewId ?? const Uuid().v4();

  // Преобразование объекта в Map для jsonEncode
  Map<String, dynamic> toJson() {
    return {
      'previewId': previewId,
      'pathPreview': pathPreview,
    };
  }

  // Создание объекта из ответа сервера (если понадобится)
  factory PreviewRequest.fromJson(Map<String, dynamic> json) {
    return PreviewRequest(
      previewId: json['previewId'] ?? '',
      pathPreview: json['pathPreview'] ?? '',
    );
  }
}

class PreviewResponse extends PreviewRequest {
  String publicUrl;
  String presignedUrl;

  PreviewResponse({
    required String pathPreview,
    required String previewId, // Принимаем ID из ответа сервера
    required this.publicUrl,
    required this.presignedUrl,
  }) : super(pathPreview: pathPreview, previewId: previewId);

  @override
  Map<String, dynamic> toJson() {
    // Объединяем поля родителя и текущего класса
    final map = super.toJson();
    map.addAll({
      'publicUrl': publicUrl,
      'presignedUrl': presignedUrl,
    });
    return map;
  }

  // Основной метод для обработки ответа от твоего Go-сервиса
  factory PreviewResponse.fromJson(Map<String, dynamic> json) {
    // Сначала парсим данные вложенного PreviewRequest, если он там есть
    final req = json['previewRequest'] != null
        ? PreviewRequest.fromJson(json['previewRequest'])
        : PreviewRequest(pathPreview: '');

    return PreviewResponse(
      previewId: req.previewId,
      pathPreview: req.pathPreview,
      publicUrl: json['publicUrl'] ?? '',
      presignedUrl: json['presignedUrl'] ?? '',
    );
  }
}