import 'package:jwt_decoder/jwt_decoder.dart';

class JwtMetadata {
  final String userId;
  final String roomId;

  JwtMetadata({required this.userId, required this.roomId});
}

class JwtManager {
  static bool isTokenValid(String? token) {
    if (token == null || token.isEmpty) return false;
    try {
      return !JwtDecoder.isExpired(token);
    } catch (e) {
      return false;
    }
  }

  static JwtMetadata? getMetadata(String token) {
    try {
      Map<String, dynamic> payload = JwtDecoder.decode(token);

      final userId = payload['user_id'];
      final roomId = payload['room_id'];

      if (userId == null || roomId == null) return null;

      return JwtMetadata(
        userId: userId.toString(),
        roomId: roomId.toString(),
      );
    } catch (e) {
      return null;
    }
  }
}