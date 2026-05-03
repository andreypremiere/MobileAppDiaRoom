import 'package:dio/dio.dart';

import '../utils/dio_service.dart';
import 'auth_response.dart';
import 'exception_handler.dart';

Future<AuthResponse> getRoomRoot({
  required String roomId
}) async {
  try {
    final res = await ApiService.get('/workshop/getRoot/$roomId');
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

Future<AuthResponse> getFolder({
  required String folderId
}) async {
  try {
    final res = await ApiService.get('/workshop/getFolder/$folderId');
    return AuthResponse(success: true, data: res.data);
  } on DioException catch (e) {
    return handleDioError(e, "Ошибка при запросе папки");
  } catch (e) {
    return handleSystemError(e);
  }
}