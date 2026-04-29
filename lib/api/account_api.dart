import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:dia_room/configuration/urls.dart';
import 'package:dia_room/models/user.dart';
import 'package:dia_room/utils/utils.dart';
import 'package:dio/dio.dart';
import 'package:flutter/cupertino.dart';
import 'package:http/http.dart' as http;
import 'package:provider/provider.dart';

import '../contracts/room/requests/save_room_request.dart';
import '../models/auth_response.dart';
import '../utils/auth_service.dart';
import '../utils/dio_service.dart';

AuthResponse _handleDioError(DioException e, String defaultMessage) {
  String message = defaultMessage;

  if (e.type == DioExceptionType.connectionTimeout || e.type == DioExceptionType.receiveTimeout) {
    message = "Сервер не отвечает, попробуйте позже";
  } else if (e.type == DioExceptionType.connectionError) {
    message = "Нет соединения с интернетом";
  } else if (e.response != null) {
    message = e.response?.data['message'] ?? e.response?.data['error'] ?? "Ошибка сервера";
  }

  return AuthResponse(
    success: false,
    message: message,
  );
}

// Вспомогательный метод для системных ошибок
AuthResponse _handleSystemError(Object e) {
  return AuthResponse(success: false, message: "Непредвиденная ошибка: $e");
}

Future<AuthResponse> requestRegistration(String email, String password) async {
  try {
    final response = await ApiService.post('/account/newAccount',
        data: {"email": email, "password": password});
    return AuthResponse(success: true, data: response.data);
  } on DioException catch (e) {
    if (e.response?.statusCode == 409) {
      return AuthResponse(
          success: false,
          message: "Этот Email уже занят, попробуйте другой"
      );
    }
    return _handleDioError(e, "Ошибка регистрации");
  } catch (e) {
    return _handleSystemError(e);
  }
}

Future<AuthResponse> requestVerifyCode(String userId, String code) async {
  try {
    final res = await ApiService.post('/account/verify/$userId', data: {'code': code});
    return AuthResponse(success: true, data: res.data);
  } on DioException catch (e) {
    if (e.response?.statusCode == 404 && e.response?.data?['error_code'] == "NOT_FOUND") {
      return AuthResponse(
          success: false,
          message: "Истек срок действия кода"
      );
    }
    if (e.response?.statusCode == 400 && e.response?.data?['error_code'] == "INVALID_VERIFICATION_CODE") {
      return AuthResponse(
          success: false,
          message: "Неверный код!!!"
      );
    }
    return _handleDioError(e, "Ошибка верификации");
  } catch (e) {
    return _handleSystemError(e);
  }
}

Future<AuthResponse> requestRepeatCode(String userId) async {
  try {
    await ApiService.post('/account/repeatCode/$userId');
    return AuthResponse(success: true);
  } on DioException catch (e) {
    return _handleDioError(e, "Ошибка повторной отправки кода");
  } catch (e) {
    return _handleSystemError(e);
  }
}

Future<AuthResponse> requestLogin(String email, String password) async {
  try {
    final res = await ApiService.post('/account/login', data: {'email': email, 'password': password});
    return AuthResponse(success: true, data: res.data);
  } on DioException catch (e) {
    if (e.response?.statusCode == 404 && e.response?.data?['error_code'] == "NOT_FOUND") {
      return AuthResponse(
          success: false,
          message: "Пользователь не найден"
      );
    }
    if (e.response?.statusCode == 400 && e.response?.data?['error_code'] == "INVALID_PASSWORD") {
      return AuthResponse(
          success: false,
          message: "Неверный пароль"
      );
    }
    return _handleDioError(e, "Ошибка авторизации");
  } catch (e) {
    return _handleSystemError(e);
  }
}

Future<AuthResponse> requestGetRoom(String roomId) async {
  try {
    final res = await ApiService.get('/account/room/$roomId');
    return AuthResponse(success: true, data: res.data);
  } on DioException catch (e) {
    return _handleDioError(e, "Комната не найдена");
  } catch (e) {
    return _handleSystemError(e);
  }
}

Future<AuthResponse> requestUpdateRoom(BuildContext context, SaveRoomRequest room) async {
  try {
    final res = await ApiService.post('/account/updateRoom', data: room.toMap());
    return AuthResponse(success: true, data: res.data);
  } on DioException catch (e) {
    return _handleDioError(e, "Не удалось обновить комнату");
  } catch (e) {
    return _handleSystemError(e);
  }
}

Future<AuthResponse> requestUploadImage(String presignedUrl, File file) async {
  try {
    final response = await ApiService.uploadImage(presignedUrl, file);
    if (response.statusCode == 200 || response.statusCode == 201) {
      return AuthResponse(success: true);
    }
    return AuthResponse(success: false, message: "S3 Error: ${response.statusCode}");
  } on DioException catch (e) {
    if (e.response?.statusCode == 403) return AuthResponse(success: false, message: "Ссылка истекла");
    return _handleDioError(e, "Ошибка загрузки файла");
  } catch (e) {
    return _handleSystemError(e);
  }
}

Future<AuthResponse?> requestLogout(BuildContext context) async {
  try {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final String? token = await authProvider.getRefreshToken();
    if (token == null) return null;

    final res = await ApiService.post('/account/logout', data: {"refreshToken": token});
    return AuthResponse(success: true, data: res.data);
  } on DioException catch (e) {
    return _handleDioError(e, "Ошибка при выходе");
  } catch (e) {
    return _handleSystemError(e);
  }
}

Future<AuthResponse> _getFollowList(String path, String roomId, int page, int limit) async {
  try {
    final res = await ApiService.get('/account/$path/$roomId',
        queryParameters: {'page': page, 'limit': limit});
    return AuthResponse(success: true, data: res.data);
  } on DioException catch (e) {
    return _handleDioError(e, "Ошибка загрузки списка");
  } catch (e) {
    return _handleSystemError(e);
  }
}

Future<AuthResponse> requestGetFollowers({required String roomId, required int page, required int limit})
=> _getFollowList('followers', roomId, page, limit);

Future<AuthResponse> requestGetFollowing({required String roomId, required int page, required int limit})
=> _getFollowList('following', roomId, page, limit);

Future<AuthResponse> requestSetConfigured() async {
  try {
    await ApiService.post('/account/setConfigured');
    return AuthResponse(success: true);
  } on DioException catch (e) {
    return _handleDioError(e, "Ошибка обновления статуса");
  } catch (e) {
    return _handleSystemError(e);
  }
}

