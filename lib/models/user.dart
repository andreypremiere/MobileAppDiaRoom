import 'dart:convert';
import '../utils/jwt_manager.dart';
import '../utils/utils.dart';

/// Представляет авторизованного пользователя в системе DiaRoom.
///
/// Содержит идентификаторы пользователя и комнаты, а также данные
/// о времени жизни сессии, извлеченные из JWT токена.
class User {
  final String token;
  final String userId;
  final String roomId;
  // final int exp;

  User._({
    required this.token,
    required this.userId,
    required this.roomId,
    // required this.exp,
  });

  /// Создает экземпляр [User] напрямую из строки JWT токена.
  ///
  /// Декодирует полезную нагрузку (payload) токена. Возвращает `null`,
  /// если токен некорректен или отсутствуют обязательные поля.
  static User? fromJwt(String token) {
    try {
      final data = JwtManager.getMetadata(token);
      if (data == null) {
        return null;
      }

      return User._(
        token: token,
        userId: data.userId,
        roomId: data.roomId,
        // exp: data['exp'],
      );
    } catch (e) {
      printError("""Возникла ошибка при создании пользователя из JWT.
Location: user.dart - class User - fromJwt.
Ошибка: $e.""");
    }
    return null;
  }

  /// Преобразует данные пользователя в [Map].
  ///
  /// Используется для подготовки данных к сохранению в локальное хранилище.
  Map<String, dynamic> toMap() {
    return {'token': token, 'userId': userId, 'roomId': roomId,
      // 'exp': exp
    };
  }

  /// Сериализует объект пользователя в JSON-строку.
  String toJson() => json.encode(toMap());

  /// Восстанавливает объект [User] из JSON-строки.
  static User? fromJson(String source) {
    return User.fromMap(json.decode(source));
  }

  /// Создает экземпляр [User] из [Map] с валидацией данных.
  ///
  /// Проверяет наличие обязательных ключей, отсутствие пустых строк
  /// и актуальность срока действия токена ([exp]).
  /// Если токен просрочен, возвращает `null`.
  static User? fromMap(Map<String, dynamic> map) {
    try {
      if (!map.containsKey('token') ||
          !map.containsKey('userId') ||
          !map.containsKey('roomId')) {
        return null;
      }

      if (map['token'] == '' || map['userId'] == '' || map['roomId'] == '') {
        return null;
      }

      final int expSeconds = map['exp'] is int
          ? map['exp']
          : int.parse(map['exp'].toString());

      final DateTime expiryDate = DateTime.fromMillisecondsSinceEpoch(
        expSeconds * 1000,
      );

      if (DateTime.now().isAfter(expiryDate)) {
        print("Срок действия токена истек");
        return null;
      }

      return User._(
        token: map['token'],
        userId: map['userId'],
        roomId: map['roomId'],
        // exp: map['exp'],
      );
    } catch (e) {
      printError("""Возникла непредвиденная ошибка...
Location: user.dart - User - fromMap
Ошибка: $e""");
      return null;
    }
  }

  @override
  String toString() {
    // final expiryDate = DateTime.fromMillisecondsSinceEpoch(exp * 1000);
    // final timeLeft = expiryDate.difference(DateTime.now());
    // final isExpired = timeLeft.isNegative;

    return '''
User {
  userId: $userId,
  roomId: $roomId,
  token: ${token.substring(0, 10)}...${token.substring(token.length - 10)}, 
}''';
  }
}