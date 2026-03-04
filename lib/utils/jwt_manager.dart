import 'package:jwt_decoder/jwt_decoder.dart';

Map<String, dynamic>? decodeJwtToken(String jwtToken) {
  Map<String, dynamic>? result;
  try {
    result = JwtDecoder.decode(jwtToken);
    print('Токен успешно декодирован: $result');
  } catch (e) {
    print('Ошибка декодирования токена: $e');
    return null;
  }
  return result;
}