import 'dart:convert';

import 'package:dia_room/utils/jwt_manager.dart';

class User {
  final String token;
  final String userId;
  final String roomId;
  final int exp;

  User._({required this.token, required this.userId, required this.roomId, required this.exp});

  static User? fromJwt(String token) {
    final data = decodeJwtToken(token);
    if (data == null) {
      return null;
    }

    return User._(token: token, userId: data['user_id'], roomId: data['room_id'], exp: data['exp']);
  }

  Map<String, dynamic> toMap() {
    return {
      'token': token,
      'userId': userId,
      'roomId': roomId,
      'exp': exp
    };
  }

  static User? fromMap(Map<String, dynamic> map) {
    if (!map.containsKey('token') || !map.containsKey('userId') || !map.containsKey('roomId')) {
      return null;
    }
    if (map['token'] == '' || map['userId'] == '' || map['roomId'] == '') {
      return null;
    }

    final int expSeconds = map['exp'] is int ? map['exp'] : int.parse(map['exp'].toString());

    final DateTime expiryDate = DateTime.fromMillisecondsSinceEpoch(expSeconds * 1000);

    if (DateTime.now().isAfter(expiryDate)) {
      print("Срок действия токена истек");
      return null;
    }

    return User._(
      token: map['token'],
      userId: map['userId'],
      roomId: map['roomId'],
      exp: map['exp']
    );
  }

  String toJson() => json.encode(toMap());

  static User? fromJson(String source) => User.fromMap(json.decode(source));
}
