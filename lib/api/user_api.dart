import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:dia_room/configuration/urls.dart';
import 'package:dia_room/models/user.dart';
import 'package:dia_room/utils/utils.dart';
import 'package:http/http.dart' as http;

import '../models/auth_response.dart';

// requestRegistration отправляет данные для регистрации нового пользователя и комнаты
Future<AuthResponse> requestRegistration(
    String email,
    String password,
    ) async {
  try {
    final url = Uri.parse(newUserUrl);
    final response = await http.post(
      url,
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        "email": email,
        "password": password,
      }),
    ).timeout(const Duration(seconds: 10)); // Добавляем таймаут

    final body = jsonDecode(response.body);

    if (response.statusCode == 200 || response.statusCode == 201) {
      return AuthResponse(success: true, data: body);
    } else {
      // Пытаемся достать текст ошибки из ответа бэкенда
      final String errorMessage = body['error'] ?? "Неизвестная ошибка сервера";
      return AuthResponse(success: false, message: errorMessage);
    }
  } on SocketException {
    return AuthResponse(success: false, message: "Нет соединения с интернетом");
  } on TimeoutException {
    return AuthResponse(success: false, message: "Сервер не отвечает, попробуйте позже");
  } catch (e) {
    return AuthResponse(success: false, message: "Произошла ошибка: $e");
  }
}

// requestVerifyCode проверяет OTP код и возвращает объект пользователя из JWT
Future<User?> requestVerifyCode(String userId, String code) async {
  final url = Uri.parse(verifyUserUrl);

  try {
    // Отправка ID пользователя и введенного кода для проверки
    final response = await http.post(
      url,
      headers: {'Content-Type': "application/json"},
      body: jsonEncode({'userId': userId, 'code': code}),
    );

    if (response.statusCode == 200) {
      // Декодирование токена в модель пользователя
      User? user = User.fromJwt(jsonDecode(response.body)['token']);
      print("User при получении после верификации из jwt: $user");
      return user;
    } else {
      final Map<String, dynamic> body = jsonDecode(response.body);
      print("Ошибка сервера: ${response.statusCode}. Ошибка: ${body['error']}");
      return null;
    }
  } catch (e) {
    print('Ошибка во время выполнения запроса: $e');
    return null;
  }
}

// requestLogin инициирует вход по номеру телефона или ID комнаты
Future<String?> requestLogin(String value) async {
  try {
    final url = Uri.parse(findUser);
    // Отправка универсального идентификатора для поиска пользователя
    final response = await http.post(
      url,
      headers: {'Content-Type': "application/json"},
      body: jsonEncode({'value': value}),
    );

    if (response.statusCode == 200) {
      // Получение UUID пользователя для последующего этапа верификации
      String? userId = jsonDecode(response.body)['userId'];
      return userId;
    } else {
      final Map<String, dynamic> body = jsonDecode(response.body);
      print("Ошибка сервера: ${response.statusCode}. Ошибка: ${body['error']}");
      return null;
    }
  } catch (e) {
    printError('Ошибка во время выполнения запроса: $e. Location: user_api.dart - requestLogin.');
    return null;
  }
}
