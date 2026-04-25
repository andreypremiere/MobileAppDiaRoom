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

Future<AuthResponse> requestRegistration(String email, String password) async {
  try {
    final response = await ApiService.post(
      '/account/newAccount',
      data: {
        "email": email,
        "password": password,
      },
    );

    return AuthResponse(success: true, data: response.data);

  } on DioException catch (e) {
    String errorMessage = "Произошла ошибка";

    if (e.type == DioExceptionType.connectionTimeout || e.type == DioExceptionType.receiveTimeout) {
      errorMessage = "Сервер не отвечает, попробуйте позже";
    } else if (e.type == DioExceptionType.connectionError) {
      errorMessage = "Нет соединения с интернетом";
    } else if (e.response != null) {
      errorMessage = e.response?.data['error'] ?? "Неизвестная ошибка сервера";
    }

    return AuthResponse(success: false, message: errorMessage);
  } catch (e) {
    return AuthResponse(success: false, message: "Непредвиденная ошибка: $e");
  }
}

Future<AuthResponse> requestVerifyCode(String userId, String code) async {
  try {
    final response = await ApiService.post(
      '/account/verify/$userId',
      data: {'code': code},
    );

    return AuthResponse(success: true, data: response.data);

  } on DioException catch (e) {
    String errorMessage = "Ошибка верификации";

    if (e.response != null) {
      errorMessage = e.response?.data['error'] ?? "Неизвестная ошибка";
    } else {
      errorMessage = "Проблемы с соединением";
    }

    return AuthResponse(success: false, message: errorMessage);
  } catch (e) {
    return AuthResponse(success: false, message: "Ошибка: $e");
  }
}

Future<AuthResponse> requestLogin(String email, String password) async {
  try {
    final response = await ApiService.post(
      '/account/login',
      data: {'email': email,
      'password': password},
    );

    return AuthResponse(
        success: true,
        data: response.data
    );

  } on DioException catch (e) {
    String errorMessage = "Ошибка при поиске пользователя";

    if (e.response != null) {
      errorMessage = e.response?.data['error'] ?? "Пользователь не найден";
    } else {
      errorMessage = "Не удалось связаться с сервером";
    }

    return AuthResponse(success: false, message: errorMessage);
  } catch (e) {
    return AuthResponse(success: false, message: "Непредвиденная ошибка: $e");
  }
}

Future<AuthResponse> requestGetRoom(String roomId) async {
  try {
    // В GET запросах данные обычно передаются в самом URL
    final response = await ApiService.get(
      '/account/room/$roomId',
    );

    // Предполагаем, что бэкенд на Go возвращает JSON объект комнаты
    return AuthResponse(
      success: true,
      data: response.data,
    );

  } on DioException catch (e) {
    String errorMessage = "Не удалось загрузить данные комнаты";

    if (e.type == DioExceptionType.connectionTimeout || e.type == DioExceptionType.receiveTimeout) {
      errorMessage = "Сервер не отвечает, проверьте соединение";
    } else if (e.type == DioExceptionType.connectionError) {
      errorMessage = "Отсутствует подключение к сети";
    } else if (e.response != null) {
      // Обработка ошибок от Go (например, если комната не найдена)
      errorMessage = e.response?.data['error'] ?? "Ошибка сервера при получении комнаты";
    }

    return AuthResponse(success: false, message: errorMessage + e.toString());
  } catch (e) {
    return AuthResponse(success: false, message: "Ошибка инициализации данных: $e");
  }
}

// Внутри твоего класса запросов (например, RoomService)
Future<AuthResponse> requestUpdateRoom(BuildContext context, SaveRoomRequest room) async {
  try {
    // final authProvider = Provider.of<AuthProvider>(context, listen: false);
    // final String? token = authProvider.accessToken;

    // if (token == null) {
    //   return AuthResponse(success: false, message: "Вы не авторизованы");
    // }

    // 2. Отправляем POST запрос
    final response = await ApiService.post(
      '/account/updateRoom',
      data: room.toMap(),
    );



    return AuthResponse(
      success: true,
      data: response.data,

    );

  } on DioException catch (e) {
    // Обработка ошибок бэкенда (например, если ID уже занят)
    final String error = e.response?.data['error'] ?? "Ошибка при обновлении комнаты :(";
    return AuthResponse(success: false, message: error);
  } catch (e) {
    return AuthResponse(success: false, message: "Системная ошибка: $e");
  }
}


Future<AuthResponse> requestUploadImage(String presignedUrl, File file) async {
  try {
    print('Загрузка в s3');

    final response = await ApiService.uploadImage(presignedUrl, file);

    if (response.statusCode == 200 || response.statusCode == 201) {
      print('Файл успешно загружен в облако');
      return AuthResponse(success: true);
    } else {
      return AuthResponse(
          success: false,
          message: "Хранилище вернуло ошибку: ${response.statusCode}"
      );
    }

  } on DioException catch (e) {
    String errorMessage = "Ошибка при передаче файла в хранилище";

    print('--- [S3 UPLOAD ERROR] ---');
    if (e.response != null) {
      print('Status: ${e.response?.statusCode}');
      print('Data: ${e.response?.data}');

      if (e.response?.statusCode == 403) {
        errorMessage = "Ошибка доступа: ссылка для загрузки недействительна или истекла";
      } else if (e.response?.statusCode == 413) {
        errorMessage = "Файл слишком большой для загрузки";
      }
    } else if (e.type == DioExceptionType.connectionTimeout) {
      errorMessage = "Таймаут загрузки: медленное соединение";
    } else {
      errorMessage = "Сетевая ошибка при загрузке: ${e.message}";
    }
    print('-------------------------');

    return AuthResponse(success: false, message: errorMessage);

  } catch (e) {
    print('Системная ошибка при загрузке: $e');
    return AuthResponse(success: false, message: "Непредвиденная ошибка: $e");
  }
}

Future<AuthResponse?> requestLogout(BuildContext context) async {
  try {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final String? token = await authProvider.getRefreshToken();

    if (token == null) {
      return null;
    }

    // В GET запросах данные обычно передаются в самом URL
    final response = await ApiService.post(
      '/account/logout', data: {"refreshToken": token}
    );

    final responseData = response.data is Map<String, dynamic>
        ? response.data as Map<String, dynamic>
        : null;

    // Предполагаем, что бэкенд на Go возвращает JSON объект комнаты
    return AuthResponse(
      success: true,
      data: responseData,
    );

  } on DioException catch (e) {
    String errorMessage = "Не удалось загрузить данные комнаты";

    if (e.type == DioExceptionType.connectionTimeout || e.type == DioExceptionType.receiveTimeout) {
      errorMessage = "Сервер не отвечает, проверьте соединение";
    } else if (e.type == DioExceptionType.connectionError) {
      errorMessage = "Отсутствует подключение к сети";
    } else if (e.response != null) {
      // Обработка ошибок от Go (например, если комната не найдена)
      errorMessage = e.response?.data['error'] ?? "Ошибка сервера при получении комнаты";
    }

    return AuthResponse(success: false, message: errorMessage + e.toString());
  } catch (e) {
    print("$e");
    return AuthResponse(success: false, message: "Ошибка инициализации данных: $e");
  }
}


