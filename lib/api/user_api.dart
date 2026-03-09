import 'dart:convert';

import 'package:dia_room/configuration/urls.dart';
import 'package:dia_room/models/user.dart';
import 'package:http/http.dart' as http;

// requestRegistration отправляет данные для регистрации нового пользователя и комнаты
Future<String?> requestRegistration(
  String phone,
  String roomId,
  String roomName,
) async {
  // Парсинг строки URL из конфигурации
  final url = Uri.parse(newUserUrl);

  try {
    // Выполнение POST запроса с JSON телом
    final response = await http.post(
      url,
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        "numberPhone": phone,
        "roomId": roomId,
        "roomName": roomName,
      }),
    );

    // Проверка успешного статуса ответа от микросервиса
    if (response.statusCode == 200) {
      final Map<String, dynamic> body = jsonDecode(response.body);
      final String? userId = body['id'];
      return userId;
    } else {
      // Логирование ошибки при неверном статус-коде
      final Map<String, dynamic> body = jsonDecode(response.body);
      print("Ошибка сервера: ${response.statusCode}. Ошибка: ${body['error']}");
      return null;
    }
  } catch (e) {
    // Обработка исключений при отсутствии интернета или недоступности хоста
    print("Ошибка при выполении запроса. Ошибка сети. $e");
    return null;
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
  final url = Uri.parse(findUser);

  try {
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
    print('Ошибка во время выполнения запроса: $e');
    return null;
  }
}
