import '../../configuration/constans.dart';
import '../enums/post_types.dart';

abstract class BlockPost {
  final BlockType type;

  BlockPost({required this.type});

  Map<String, dynamic> toMap();

  // Фабричный конструктор, который распределяет данные по нужным классам
  factory BlockPost.fromMap(Map<String, dynamic> map) {
    // Сначала определяем тип блока через наш Enum
    final type = BlockType.fromMap(map);

    switch (type) {
      case BlockType.text:
        return TextBlockPost.fromMap(map);
      case BlockType.photos:
        return PhotoBlockPost.fromMap(map);
      case BlockType.videos:
        return VideoBlockPost.fromMap(map);
    }
  }
}

class VideoBlockPost extends BlockPost {
  String localPath;
  String publicUrl;
  String presignedUrl;

  String previewLocalPath;
  String previewPublicUrl;
  String previewPresignedUrl;

  int fileSize;
  Duration duration;

  VideoBlockPost({
    required this.localPath,
    required this.publicUrl,
    required this.presignedUrl,
    required this.previewLocalPath,
    required this.previewPublicUrl,
    required this.previewPresignedUrl,
    required this.fileSize,
    required this.duration,
  }) : super(type: BlockType.videos);

  @override
  Map<String, dynamic> toMap() {
    return {
      'blockType': type.slug,
      'localPath': localPath,
      'publicUrl': publicUrl,
      'presignedUrl': presignedUrl,
      'previewLocalPath': previewLocalPath,
      'previewPublicUrl': previewPublicUrl,
      'previewPresignedUrl': previewPresignedUrl,
      'fileSize': fileSize,
      // Сохраняем длительность в миллисекундах для бэкенда
      'durationMs': duration.inMilliseconds,
    };
  }

  static VideoBlockPost fromMap(Map<String, dynamic> map) {
    return VideoBlockPost(
      localPath: map['localPath'] ?? '',
      publicUrl: map['publicUrl'] ?? '',
      presignedUrl: map['presignedUrl'] ?? '',
      previewLocalPath: map['previewLocalPath'] ?? '',
      previewPublicUrl: map['previewPublicUrl'] ?? '',
      previewPresignedUrl: map['previewPresignedUrl'] ?? '',
      fileSize: map['fileSize'] ?? 0,
      duration: Duration(milliseconds: map['durationMs'] ?? 0),
    );
  }
}

class PhotoBlockPost extends BlockPost {
  List<String> localPaths;
  List<String> publicUrls;
  List<String> presignedUrls;
  MethodView methodView;
  List<int> photoSizes;
  // static const limitPhotos = limitPhotosForBlock;

  PhotoBlockPost({
    required this.localPaths,
    required this.publicUrls,
    required this.presignedUrls,
    required this.methodView,
    required this.photoSizes,
  }) : super(type: BlockType.photos);

  @override
  Map<String, dynamic> toMap() {
    return {
      'blockType': type.slug,
      'localPaths': localPaths,
      'publicUrls': publicUrls,
      'presignedUrls': presignedUrls,
      'methodViewPhoto': methodView.slug, // Используем метод из энума
      'photoSizes': photoSizes,
    };
  }

  static PhotoBlockPost fromMap(Map<String, dynamic> map) {
    return PhotoBlockPost(
      localPaths: List<String>.from(map['localPaths'] ?? []),
      publicUrls: List<String>.from(map['publicUrls'] ?? []),
      presignedUrls: List<String>.from(map['presignedUrls'] ?? []),
      photoSizes: List<int>.from(map['photoSizes'] ?? []),
      methodView: MethodView.fromMap(map),
    );
  }
}

class TextBlockPost extends BlockPost {
  String value;
  TextType textType;

  TextBlockPost({
    required this.value,
    required this.textType,
  }) : super(type: BlockType.text);

  @override
  Map<String, dynamic> toMap() {
    return {
      'blockType': type.slug,
      'value': value,
      'textType': textType.slug,
    };
  }

  // Статический метод для создания объекта из Map
  static TextBlockPost fromMap(Map<String, dynamic> map) {
    return TextBlockPost(
      value: map['value'] ?? 'Не удалось извлечь значение текстового блока. Это шаблонный текст.',
      textType: TextType.fromMap(map),
    );
  }
}