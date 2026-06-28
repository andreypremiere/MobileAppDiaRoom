import 'dart:io';

import 'package:dia_room/contracts/workshop/requests/creating_item_video.dart';
import 'package:dia_room/contracts/workshop/requests/updating_item_status.dart';
import 'package:dio/dio.dart';

import '../contracts/workshop/requests/creating_item_photo.dart';
import '../utils/dio_service.dart';
import 'auth_response.dart';
import 'exception_handler.dart';

Future<AuthResponse> getRootFolders({
  required String roomId
}) async {
  try {
    final res = await ApiService.get('/workshop/folders/$roomId');
    return AuthResponse(success: true, data: res.data);
  } on DioException catch (e) {
    return handleDioError(e, "Ошибка при запросе мастерской");
  } catch (e) {
    return handleSystemError(e);
  }
}

Future<AuthResponse> renameFolder({required String folderId, required String newName}) async {
  try {
    await ApiService.patch('/workshop/renameFolder/$folderId', data: {
      'folderName': newName,
    });
    return AuthResponse(success: true);
  } on DioException catch (e) {
    return handleDioError(e, "Ошибка при переименовании");
  }
}

Future<AuthResponse> getFolders({
  required String roomId,
  required String folderId
}) async {
  try {
    final res = await ApiService.get('/workshop/folders/$roomId/$folderId');
    return AuthResponse(success: true, data: res.data);
  } on DioException catch (e) {
    return handleDioError(e, "Ошибка при запросе папки");
  } catch (e) {
    return handleSystemError(e);
  }
}

Future<AuthResponse> createFolder({
  String? parentId,
  required String name,
}) async {
  try {
    final result = await ApiService.post('/workshop/createFolder', data: {
      'parentId': parentId,
      'folderName': name,
    });
    return AuthResponse(success: true, data: result.data);
  } on DioException catch (e) {
    return handleDioError(e, "Ошибка при создании папки");
  }
}

Future<AuthResponse> moveFolder({
  required String targetId,
  String? destinationId,
}) async {
  try {
    await ApiService.post('/workshop/moveFolder', data: {
      'targetId': targetId,
      'destinationId': destinationId,
    });
    return AuthResponse(success: true);
  } on DioException catch (e) {
    return handleDioError(e, "Ошибка при перемещении");
  }
}

Future<AuthResponse> getRootContent({
  required String roomId
}) async {
  try {
    final res = await ApiService.get('/workshop/$roomId');
    return AuthResponse(success: true, data: res.data);
  } on DioException catch (e) {
    return handleDioError(e, "Ошибка при запросе мастерской");
  } catch (e) {
    return handleSystemError(e);
  }
}

Future<AuthResponse> getContentFolder({
  required String roomId,
  required String folderId
}) async {
  try {
    final res = await ApiService.get('/workshop/$roomId/$folderId');
    return AuthResponse(success: true, data: res.data);
  } on DioException catch (e) {
    return handleDioError(e, "Ошибка при запросе папки");
  } catch (e) {
    return handleSystemError(e);
  }
}

Future<AuthResponse> createItemImage({
  required CreatingItemPhoto item
}) async {
  try {
    final res = await ApiService.post('/workshop/createImage', data: item.toMap());
    return AuthResponse(success: true, data: res.data);
  } on DioException catch (e) {
    return handleDioError(e, "Ошибка при создании изображения");
  } catch (e) {
    return handleSystemError(e);
  }
}

Future<AuthResponse> createItemVideo({
  required CreatingItemVideo item
}) async {
  try {
    final res = await ApiService.post('/workshop/createVideo', data: item.toMap());
    return AuthResponse(success: true, data: res.data);
  } on DioException catch (e) {
    return handleDioError(e, "Ошибка при создании видео");
  } catch (e) {
    return handleSystemError(e);
  }
}

Future<AuthResponse> updateItem({
  required UpdatingItemStatus item
}) async {
  try {
    await ApiService.post('/workshop/updateItemStatus', data: item.toMap());
    return AuthResponse(success: true, data: null);
  } on DioException catch (e) {
    return handleDioError(e, "Ошибка при обновления значения");
  } catch (e) {
    return handleSystemError(e);
  }
}

Future<bool> uploadSingleMediaFile(String filePath, String presignedUrl, String contentType) async {
  try {
    final file = File(filePath);
    if (!await file.exists()) return false;
    final res = await ApiService.putBinaryFile(url: presignedUrl, file: file, contentType: contentType);
    return res.statusCode == 200 || res.statusCode == 201;
  } catch (e) {
    return false;
  }
}

Future<AuthResponse> moveItem({
  required String targetId,
  String? destinationId,
}) async {
  try {
    await ApiService.post('/workshop/moveItem', data: {
      'targetId': targetId,
      'destinationId': destinationId,
    });
    return AuthResponse(success: true);
  } on DioException catch (e) {
    return handleDioError(e, "Ошибка при перемещении");
  }
}

Future<AuthResponse> deleteItem({
  required String itemId
}) async {
  try {
    await ApiService.delete('/workshop/deleteItem/$itemId');
    return AuthResponse(success: true);
  } on DioException catch (e) {
    return handleDioError(e, "Ошибка при перемещении");
  }
}

Future<AuthResponse> deleteFolder({
  required String folderId
}) async {
  try {
    await ApiService.delete('/workshop/deleteFolder/$folderId');
    return AuthResponse(success: true);
  } on DioException catch (e) {
    return handleDioError(e, "Ошибка при перемещении");
  }
}