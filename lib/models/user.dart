import 'package:dia_room/utils/jwt_manager.dart';

class User {
  final String token;
  final String userId;
  final String roomId;

  User._({required this.token, required this.userId, required this.roomId});

  static User? fromJwt(String token) {
    final data = decodeJwtToken(token);
    if (data == null) {
      return null;
    }

    return User._(token: token, userId: data['user_id'], roomId: data['room_id']);
  }
}
