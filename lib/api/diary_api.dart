import 'dart:io';

import 'package:dio/dio.dart';

import '../contracts/diary/requests/creating_message.dart';
import '../contracts/diary/requests/update_status_message.dart';
import '../models/enums/diary/message_status.dart';
import '../utils/dio_service.dart';
import 'auth_response.dart';
import 'exception_handler.dart';

Future<AuthResponse> createMessage({
  required CreatingMessage message,
}) async {
  try {
    final response = await ApiService.post('/diary/createMessage', data: message.toMap());

    return AuthResponse(success: true, data: response.data);
  } on DioException catch (e) {
    return handleDioError(e, "Ошибка при создании сообщения");
  }
}

Future<AuthResponse> updateStatus({
  required UpdatingMessage updatingMessage,
}) async {
  try {
    final response = await ApiService.post('/diary/updateStatusMessage', data: updatingMessage.toMap());

    return AuthResponse(success: true, data: response.data);
  } on DioException catch (e) {
    return handleDioError(e, "Ошибка при обновлении статуса сообщения");
  }
}

Future<bool> uploadSingleMediaFile(String filePath, String presignedUrl, String contentType) async {
  try {
    final file = File(filePath);
    if (!await file.exists()) return false;
    final res = await ApiService.putBinaryFile(url: presignedUrl, file: file, contentType: contentType);
    return res.statusCode == 200 || res.statusCode == 201;
  } catch (e) {
    print('Ошибка загрузки: $e');
    return false;
  }
}

Future<AuthResponse> getMessages({
  required String roomId,
  required int page,
  required int limit,
}) async {
  try {
    final response = await ApiService.get('/diary/messages/$roomId', queryParameters: {"page": page, "limit": limit});

    return AuthResponse(success: true, data: response.data);
  } on DioException catch (e) {
    return handleDioError(e, "Ошибка при создании сообщения");
  }
}