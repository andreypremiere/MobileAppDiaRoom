import 'package:dio/dio.dart';

import '../models/auth_response.dart';

// Метод для обработки исключений запросов
AuthResponse handleDioError(DioException e, String defaultMessage) {
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
AuthResponse handleSystemError(Object e) {
  return AuthResponse(success: false, message: "Непредвиденная ошибка: $e");
}