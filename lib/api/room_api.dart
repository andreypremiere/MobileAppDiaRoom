import 'dart:convert';

import 'package:dia_room/configuration/urls.dart' as urls;
import 'package:dia_room/models/auth_response.dart';
import 'package:http/http.dart' as http;

import 'package:dio/dio.dart';
import '../utils/dio_service.dart';

Future<AuthResponse> getRoomByRoomId(String roomId) async {
  try {
    // Используем GET запрос, как указано в твоем пути
    final response = await ApiService.get(
      '/account/room/$roomId',
    );

    // Если сервер вернул 200, значит всё ок
    if (response.statusCode == 200) {
      return AuthResponse(
          success: true,
          data: response.data // Передаем весь объект комнаты (мапу)
      );
    }

    // Если статус не 200, но ответ пришел
    return AuthResponse(
        success: false,
        message: response.data['error'] ?? "Ошибка загрузки данных"
    );

  } on DioException catch (e) {
    String errorMessage = "Ошибка сети или сервера";

    if (e.response != null && e.response?.data is Map) {
      // Достаем сообщение об ошибке из ответа бэкенда
      errorMessage = e.response?.data['error'] ?? "Непредвиденная ошибка";
    } else if (e.type == DioExceptionType.connectionTimeout) {
      errorMessage = "Превышено время ожидания соединения";
    }

    print('[API Room] Ошибка: $errorMessage');

    return AuthResponse(
        success: false,
        message: errorMessage
    );
  } catch (e) {
    print("[API Room] Критическая ошибка: $e");
    return AuthResponse(
        success: false,
        message: "Произошла системная ошибка"
    );
  }
}