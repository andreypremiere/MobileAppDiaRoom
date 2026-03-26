import 'dart:io';

import '../enums/post_types.dart';
import 'block_post.dart';

class BlockPhotos extends BlockPost {
  List<String> paths;
  MethodViewPhoto methodView;
  List<int> photoSizes;
  static const limitPhotos = 10;

  bool get isFull => paths.length >= limitPhotos;

  BlockPhotos({List<String>? paths, List<int>? photoSizes, this.methodView = MethodViewPhoto.tiles})
      : paths = paths ?? [], photoSizes = photoSizes ?? [],
        super(type: BlockPostType.photos);

  @override
  bool isEmpty() {
    if (paths.isEmpty) {
      return true;
    }
    return false;
  }

  Future<bool> addPath(String path) async {
    if (paths.length >= limitPhotos) {
      return false;
    }

    try {
      final file = File(path);
      if (await file.exists()) {
        int size = await file.length();
        paths.add(path);
        photoSizes.add(size); // Добавляем размер в соответствующий индекс
        return true;
      }
    } catch (e) {
      print("Ошибка при получении размера файла: $e");
    }
    return false;
  }

  Future<void> deletePhoto(int index) async {
    try {
      if (await File(paths[index]).exists()) {
        await File(paths[index]).delete();
      }
    } catch (e) {
      print("Файл уже удален или недоступен");
    }

    paths.removeAt(index);
    photoSizes.removeAt(index); // Удаляем размер вместе с путем
  }

  Future<void> deleteAllPhotos() async {
    for (String path in paths) {
      try {
        final file = File(path);
        if (await file.exists()) await file.delete();
      } catch (e) {
        print("Ошибка при удалении файла $path: $e");
      }
    }
    paths.clear();
    photoSizes.clear();
  }
}

class PhotoInfo {
  String filePath;
  String uploadId;
  String? publicUrl;
  String? presignedUrl;
  int size;

  PhotoInfo({required this.filePath, required this.uploadId,
  required this.size});

  Map<String, dynamic> toJson() {
    return {
      'uploadId': uploadId,
      'publicUrl': publicUrl,
      // filePath и presignedUrl обычно НЕ отправляются в финальный payload для БД,
      // так как они временные, но если они нужны для кэша — можно оставить.
      'size': size,
    };
  }
}

class BlockPhotoUpload extends BlockUpload {
  MethodViewPhoto methodView;
  List<PhotoInfo> listPhoto;

  BlockPhotoUpload({required this.methodView}) : listPhoto = <PhotoInfo>[],
  super(type: BlockPostType.photos);


  @override
  Map<String, dynamic> toJson() {
    return {
      'type': type.name, // Используем name из Enum (photos)
      'methodView': methodView.name, // Предполагаем, что это Enum
      'listPhoto': listPhoto.map((photo) => photo.toJson()).toList(),
    };
  }
}

