import 'dart:io';

import 'package:flutter/cupertino.dart';

import '../enums/post_types.dart';
import 'block_post.dart';



class BlockPhotos extends BlockPost {
  List<PhotoInfo> listPhoto;
  MethodViewPhoto methodView;

  BlockPhotos({required this.listPhoto, required this.methodView}) : super(type: BlockType.photos);

}

class BlockPhotosCreating extends BlockPhotos implements Validatable {
  static const limitPhotos = 10;



  BlockPhotosCreating({required super.listPhoto, required super.methodView});

  bool get isFull => listPhoto.length >= limitPhotos;

  @override
  bool isEmpty() {
    return listPhoto.isEmpty;
  }

  Future<bool> addPath(String path) async {
    if (listPhoto.length >= limitPhotos) {
      return false;
    }

    try {
      final file = File(path);
      if (await file.exists()) {
        int size = await file.length();
        final newPhoto = PhotoInfo(filePath: path, uploadId: '', size: size, publicUrl: '', presignedUrl: '');
        listPhoto.add(newPhoto);
        return true;
      }
    } catch (e) {
      print("Ошибка при получении размера файла: $e");
    }
    return false;
  }

  Future<void> deletePhoto(int index) async {
    try {
      if (await File(listPhoto[index].filePath).exists()) {
        await File(listPhoto[index].filePath).delete();
      }
    } catch (e) {
      print("Файл уже удален или недоступен");
    }

    listPhoto.removeAt(index);
  }

  Future<void> deleteAllPhotos() async {
    for (final item in listPhoto) {
      try {
        final file = File(item.filePath);
        if (await file.exists()) await file.delete();
      } catch (e) {
        print("Ошибка при удалении файла $item.filePath: $e");
      }
    }
    listPhoto.clear();
  }
}

class PhotoInfo {
  String filePath;
  String uploadId;
  String publicUrl;
  String presignedUrl;
  int size;

  PhotoInfo({required this.filePath, required this.uploadId,
  required this.size, required this.publicUrl, required this.presignedUrl});

  Map<String, dynamic> toJson() {
    return {
      'publicUrl': publicUrl,
      'size': size,
    };
  }
}

class BlockPhotoUpload extends BlockUpload {
  MethodViewPhoto methodView;
  List<PhotoInfo> listPhoto;

  BlockPhotoUpload({required this.methodView}) : listPhoto = <PhotoInfo>[],
  super(type: BlockType.photos);


  @override
  Map<String, dynamic> toJson() {
    return {
      'blockType': type.slug, // Используем name из Enum (photos)
      'methodView': methodView.slug, // Предполагаем, что это Enum
      'listPhoto': listPhoto.map((photo) => photo.toJson()).toList(),
    };
  }
}

