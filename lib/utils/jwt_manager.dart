import 'package:jwt_decoder/jwt_decoder.dart';

// Функция для безопасного извлечения данных из JWT токена
Map<String, dynamic>? decodeJwtToken(String jwtToken) {
  Map<String, dynamic>? result;
  try {
    // Декодируем Base64-часть токена в Map
    result = JwtDecoder.decode(jwtToken);
    print('Токен успешно декодирован: $result');
  } catch (e) {
    // В случае неверного формата токена или ошибки библиотеки возвращаем null
    print('Ошибка декодирования токена: $e');
    return null;
  }
  return result;
}
