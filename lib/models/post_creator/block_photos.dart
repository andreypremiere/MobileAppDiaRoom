import 'dart:io';

import 'package:dia_room/configuration/constans.dart';
import 'package:dia_room/models/payload/base_block.dart';

import '../enums/post_types.dart';
import '../internal_error.dart';
import '../payload/post_creating_interface.dart';

// Будет содержать методы для управления памятью и обновления всего
class BlockPhotosCreating extends PhotoBlockPost implements Validatable {
  static const limitPhotos = limitPhotosForBlock;

  BlockPhotosCreating()
      : super(localPaths: [], publicUrls: [], presignedUrls: [], methodView: MethodView.tiles, photoSizes: []);

  bool get isFull => localPaths.length >= limitPhotos;


  bool isEmpty() {
    return localPaths.isEmpty;
  }

  Future<Result> addPath(String path) async {
    if (localPaths.length >= limitPhotos) {
      return Result(result: false, message: "Достигнут лимит фотографий в блоке");
    }

    try {
      final file = File(path);
      if (await file.exists()) {
        int size = await file.length();
        localPaths.add(path);
        photoSizes.add(size);
        return Result(result: true, message: '');
      }
    } catch (e) {
      return Result(result: false, message: "Непредвиденная ошибка при добавлении фотографии");
    }
    return Result(result: false, message: "Файл не найден");
  }

  Future<Result> deletePhoto(int index) async {
    try {
      if (await File(localPaths[index]).exists()) {
        await File(localPaths[index]).delete();
      } else {
        print("Файл не найден при удалении фотографии");
      }
    } catch (e) {
      return Result(result: false, message: "Непредвиденная ошибка при удалении фотографии");
    }

    localPaths.removeAt(index);
    photoSizes.removeAt(index);
    return Result(result: true, message: '');
  }

  Future<Result> deleteAllPhotos() async {
    for (String path in localPaths) {
      try {
        final file = File(path);
        if (await file.exists()) await file.delete();
      } catch (e) {
        return Result(result: false, message: 'Непредвиденная ошибка во время удаления фотографий');
      }
    }
    localPaths.clear();
    photoSizes.clear();
    return Result(result: true, message: '');
  }
}



