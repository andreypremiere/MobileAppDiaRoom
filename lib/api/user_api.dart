import 'dart:convert';

import 'package:dia_room/configuration/urls.dart';
import 'package:dia_room/models/user.dart';
import 'package:http/http.dart' as http;

Future<String?> requestRegistration(
  String phone,
  String roomId,
  String roomName,
) async {
  final url = Uri.parse(newUserUrl);

  try {
    final response = await http.post(
      url,
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        "numberPhone": phone,
        "roomId": roomId,
        "roomName": roomName,
      }),
    );

    if (response.statusCode == 200) {
      final Map<String, dynamic> body = jsonDecode(response.body);
      final String? userId = body['id'];
      return userId;
    } else {
      final Map<String, dynamic> body = jsonDecode(response.body);
      print("Ошибка сервера: ${response.statusCode}. Ошибка: ${body['error']}");
      return null;
    }
  } catch (e) {
    print("Ошибка при выполении запроса. Ошибка сети. $e");
    return null;
  }
}

Future<User?> requestVerifyCode(String userId, String code) async {
  final url = Uri.parse(verifyUserUrl);

  try {
    final response = await http.post(
      url,
      headers: {'Content-Type': "application/json"},
      body: jsonEncode({'userId': userId, 'code': code}),
    );

    if (response.statusCode == 200) {
      User? user = User.fromJwt(jsonDecode(response.body)['token']);
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

Future<String?> requestLogin(String value) async {
  final url = Uri.parse(findUser);

  try {
    final response = await http.post(
      url,
      headers: {'Content-Type': "application/json"},
      body: jsonEncode({'value': value}),
    );

    if (response.statusCode == 200) {
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
