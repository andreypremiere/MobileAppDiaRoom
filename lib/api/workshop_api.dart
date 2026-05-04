import 'package:dio/dio.dart';

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
    await ApiService.post('/workshop/createFolder', data: {
      'parentId': parentId,
      'folderName': name,
    });
    return AuthResponse(success: true);
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