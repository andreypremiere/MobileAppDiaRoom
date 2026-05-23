import 'dart:async';
import 'dart:io';
import 'package:dia_room/contracts/room/requests/updating_avatar_request.dart';
import 'package:dia_room/contracts/room/requests/updating_background_request.dart';
import 'package:dia_room/contracts/room/requests/updating_categories_request.dart';
import 'package:dia_room/contracts/room/requests/updating_text_field_request.dart';
import 'package:dio/dio.dart';
import 'package:flutter/cupertino.dart';
import 'package:provider/provider.dart';
import '../contracts/room/requests/save_room_request.dart';
import 'auth_response.dart';
import '../models/post_view/author.dart';
import '../utils/auth_service.dart';
import '../utils/dio_service.dart';
import 'exception_handler.dart';

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
    return handleDioError(e, "Ошибка регистрации");
  } catch (e) {
    return handleSystemError(e);
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
    return handleDioError(e, "Ошибка верификации");
  } catch (e) {
    return handleSystemError(e);
  }
}

Future<AuthResponse> requestRepeatCode(String userId) async {
  try {
    await ApiService.post('/account/repeatCode/$userId');
    return AuthResponse(success: true);
  } on DioException catch (e) {
    return handleDioError(e, "Ошибка повторной отправки кода");
  } catch (e) {
    return handleSystemError(e);
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
    return handleDioError(e, "Ошибка авторизации");
  } catch (e) {
    return handleSystemError(e);
  }
}

Future<AuthResponse> requestGetRoom(String roomId) async {
  try {
    final res = await ApiService.get('/account/room/$roomId');
    return AuthResponse(success: true, data: res.data);
  } on DioException catch (e) {
    return handleDioError(e, "Комната не найдена");
  } catch (e) {
    return handleSystemError(e);
  }
}

Future<AuthResponse> requestUpdateRoom(BuildContext context, SaveRoomRequest room) async {
  try {
    final res = await ApiService.post('/account/updateRoom', data: room.toMap());
    return AuthResponse(success: true, data: res.data);
  } on DioException catch (e) {
    return handleDioError(e, "Не удалось обновить комнату");
  } catch (e) {
    return handleSystemError(e);
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
    return handleDioError(e, "Ошибка загрузки файла");
  } catch (e) {
    return handleSystemError(e);
  }
}

Future<AuthResponse?> requestLogout(BuildContext context) async {
  try {
    // Извлекает refresh token из провайдера
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final String? token = await authProvider.getRefreshToken();

    // Если токена нет, то возвращаем null
    if (token == null) return null;

    await ApiService.post('/account/logout', data: {"refreshToken": token});
    return AuthResponse(success: true);
  } on DioException catch (e) {
    return handleDioError(e, "Ошибка при выходе");
  } catch (e) {
    return handleSystemError(e);
  }
}

Future<AuthResponse> _getFollowList(String path, String roomId, int page, int limit) async {
  try {
    final res = await ApiService.get('/account/$path/$roomId',
        queryParameters: {'page': page, 'limit': limit});
    return AuthResponse(success: true, data: res.data);
  } on DioException catch (e) {
    return handleDioError(e, "Ошибка загрузки списка");
  } catch (e) {
    return handleSystemError(e);
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
    return handleDioError(e, "Ошибка обновления статуса");
  } catch (e) {
    return handleSystemError(e);
  }
}

Future<AuthResponse> getRoomInfoById(String roomId) async {
  try {
    final response = await ApiService.get('/account/getRoomInfoById/$roomId');
    response.data['roomId'] = roomId;
    final roomInfo = Author.fromMap(response.data);

    return AuthResponse(
        success: true,
        data: {"roomInfo": roomInfo}
    );
  } on DioException catch (e) {
    return handleDioError(e, "Ошибка обновления статуса");
  } catch (e) {
    return handleSystemError(e);
  }
}

Future<AuthResponse> getRoomByRoomId(String roomId) async {
  try {
    final res = await ApiService.get('/account/room/$roomId');

    return AuthResponse(
      success: true,
      data: res.data,
    );
  } on DioException catch (e) {
    return handleDioError(e, "Ошибка загрузки данных комнаты");
  } catch (e) {
    return handleSystemError(e);
  }
}

Future<AuthResponse> getRoomForSettings() async {
  try {
    final res = await ApiService.get('/account/room-settings');

    return AuthResponse(
      success: true,
      data: res.data,
    );
  } on DioException catch (e) {
    return handleDioError(e, "Ошибка загрузки данных комнаты");
  } catch (e) {
    return handleSystemError(e);
  }
}

Future<AuthResponse> checkSubscription(String roomId) async {
  try {
    final res = await ApiService.get('/account/checkRoomSubscription/$roomId');
    return AuthResponse(
      success: true,
      data: res.data,
    );
  } on DioException catch (e) {
    return handleDioError(e, "Ошибка проверки подписки");
  } catch (e) {
    return handleSystemError(e);
  }
}


Future<AuthResponse> followRoom(String roomId) async {
  try {
    await ApiService.post(
      '/account/followRoom',
      data: {"following_id": roomId},
    );
    return AuthResponse(success: true);
  } on DioException catch (e) {
    return handleDioError(e, "Не удалось подписаться");
  } catch (e) {
    return handleSystemError(e);
  }
}

Future<AuthResponse> unfollowRoom(String roomId) async {
  try {
    await ApiService.delete(
      '/account/unfollowRoom',
      data: {"following_id": roomId},
    );
    return AuthResponse(success: true);
  } on DioException catch (e) {
    return handleDioError(e, "Не удалось отписаться");
  } catch (e) {
    return handleSystemError(e);
  }
}

Future<AuthResponse> searchRooms({
  required int limit,
  required int page,
  required String value}) async {
  try {
    final response = await ApiService.get(
      '/account/search',
      queryParameters: {"limit": limit, "page": page, "value": value,}
    );
    return AuthResponse(success: true, data: response.data);
  } on DioException catch (e) {
    return handleDioError(e, "Не удалось выполнить поиск по комнатам");
  } catch (e) {
    return handleSystemError(e);
  }
}

Future<AuthResponse> updateAvatar(UpdatingAvatarRequest request) async {
  try {
    final response = await ApiService.post(
      '/account/update/avatar',
      data: request.toMap(),
    );
    return AuthResponse(success: true, data: response.data);
  } on DioException catch (e) {
    return handleDioError(e, "Не удалось обновить аватарку");
  } catch (e) {
    return handleSystemError(e);
  }
}

Future<AuthResponse> updateBackground(UpdatingBackgroundRequest request) async {
  try {
    final response = await ApiService.post(
      '/account/update/background',
      data: request.toMap(),
    );
    return AuthResponse(success: true, data: response.data);
  } on DioException catch (e) {
    return handleDioError(e, "Не удалось обновить фон комнаты");
  } catch (e) {
    return handleSystemError(e);
  }
}

Future<AuthResponse> updateRoomUniqueId(UpdatingTextFieldRequest request) async {
  try {
    await ApiService.post(
      '/account/update/roomUniqueId',
      data: request.toMap(),
    );
    return AuthResponse(success: true);
  } on DioException catch (e) {
    return handleDioError(e, "Не удалось обновить ID комнаты");
  } catch (e) {
    return handleSystemError(e);
  }
}

Future<AuthResponse> updateRoomName(UpdatingTextFieldRequest request) async {
  try {
    final response = await ApiService.post(
      '/account/update/roomName',
      data: request.toMap(),
    );
    return AuthResponse(success: true, data: response.data);
  } on DioException catch (e) {
    return handleDioError(e, "Не удалось обновить название комнаты");
  } catch (e) {
    return handleSystemError(e);
  }
}

Future<AuthResponse> updateRoomBio(UpdatingTextFieldRequest request) async {
  try {
    await ApiService.post(
      '/account/update/bio',
      data: request.toMap(),
    );
    return AuthResponse(success: true);
  } on DioException catch (e) {
    return handleDioError(e, "Не удалось обновить описание комнаты");
  } catch (e) {
    return handleSystemError(e);
  }
}

Future<AuthResponse> updateCategories(UpdatingCategoriesRequest request) async {
  try {
    await ApiService.post(
      '/account/update/categories',
      data: request.toMap(),
    );
    return AuthResponse(success: true);
  } on DioException catch (e) {
    return handleDioError(e, "Не удалось обновить категории");
  } catch (e) {
    return handleSystemError(e);
  }
}

Future<AuthResponse> deleteBackground() async {
  try {
    await ApiService.delete(
      '/account/delete/background',
    );
    return AuthResponse(success: true);
  } on DioException catch (e) {
    return handleDioError(e, "Не удалось удалить фон комнаты.");
  } catch (e) {
    return handleSystemError(e);
  }
}


Future<AuthResponse> deleteAvatar() async {
  try {
    await ApiService.delete(
      '/account/delete/avatar',
    );
    return AuthResponse(success: true);
  } on DioException catch (e) {
    return handleDioError(e, "Не удалось удалить аватар комнаты.");
  } catch (e) {
    return handleSystemError(e);
  }
}
