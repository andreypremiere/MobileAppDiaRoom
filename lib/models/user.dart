import 'dart:convert';

import 'package:dia_room/utils/jwt_manager.dart';

// User представляет авторизованного пользователя с данными из JWT токена
class User {
  final String token; // Оригинальная строка JWT токена
  final String userId; // Уникальный ID пользователя
  final String roomId; // ID комнаты, принадлежащей пользователю
  final int exp; // Время истечения токена в формате Unix Timestamp

  // Приватный конструктор для создания объекта только через фабричные методы
  User._({
    required this.token,
    required this.userId,
    required this.roomId,
    required this.exp,
  });

  // fromJwt создает объект User, декодируя Payload переданного токена
  static User? fromJwt(String token) {
    // Вызов внешней функции для парсинга Base64 части токена
    final data = decodeJwtToken(token);
    if (data == null) {
      return null;
    }

    // Извлечение данных из мапы, которую вернул декодер
    return User._(
      token: token,
      userId: data['user_id'],
      roomId: data['room_id'],
      exp: data['exp'],
    );
  }

  // toMap преобразует объект в Map для сохранения (например, в SharedPreferences)
  Map<String, dynamic> toMap() {
    return {'token': token, 'userId': userId, 'roomId': roomId, 'exp': exp};
  }

  // fromMap восстанавливает пользователя из сохраненной Map с проверкой валидности
  static User? fromMap(Map<String, dynamic> map) {
    // Проверка наличия всех необходимых ключей в структуре
    if (!map.containsKey('token') ||
        !map.containsKey('userId') ||
        !map.containsKey('roomId')) {
      return null;
    }
    // Проверка на пустые значения полей
    if (map['token'] == '' || map['userId'] == '' || map['roomId'] == '') {
      return null;
    }

    // Приведение времени истечения к целому числу (защита от разных типов в JSON)
    final int expSeconds = map['exp'] is int
        ? map['exp']
        : int.parse(map['exp'].toString());

    // Преобразование Unix секунд в объект DateTime для сравнения
    final DateTime expiryDate = DateTime.fromMillisecondsSinceEpoch(
      expSeconds * 1000,
    );

    // Проверка: не истек ли срок действия токена относительно текущего времени
    if (DateTime.now().isAfter(expiryDate)) {
      print("Срок действия токена истек");
      return null;
    }

    return User._(
      token: map['token'],
      userId: map['userId'],
      roomId: map['roomId'],
      exp: map['exp'],
    );
  }

  // toJson сериализует данные пользователя в строку JSON
  String toJson() => json.encode(toMap());

  // fromJson десериализует строку JSON обратно в объект User
  static User? fromJson(String source) => User.fromMap(json.decode(source));
}
