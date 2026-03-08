import 'package:flutter/foundation.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'dart:convert';

import '../models/user.dart';

class AuthService {
  static const _storage = FlutterSecureStorage();
  static const _userKey = 'user_data_secure';

  // 1. Метод для СОХРАНЕНИЯ объекта User
  static Future<void> saveUser(User user) async {
    String jsonString = json.encode(user.toMap());
    await _storage.write(key: _userKey, value: jsonString);
  }

  // 2. Метод для ПОЛУЧЕНИЯ объекта User
  static Future<User?> getUser() async {
    try {
      String? jsonString = await _storage.read(key: _userKey);
      print("JsonString $jsonString");

      if (jsonString == null) return null;

      Map<String, dynamic> userMap = json.decode(jsonString);

      return User.fromMap(userMap);
    } catch (e) {
      print('Ошибка во время получения User');
      return null;
    }
  }

  // Проверка аутентифицирован ли пользователь
  static Future<bool> isAuthenticated() async {
    User? user = await getUser();
    return user != null;
  }

  // Удаление данных при выходе
  static Future<void> logout() async {
    await _storage.delete(key: _userKey);
  }
}

class AuthProvider extends ChangeNotifier {
  User? _user;
  User? get user => _user;
  bool get isAuthenticated => _user != null;

  Future<void> loadUser() async {
    _user = await AuthService.getUser();
    notifyListeners();
  }

  void login(User newUser) {
    _user = newUser;
    AuthService.saveUser(newUser);
    notifyListeners();
  }

  void logout() {
    _user = null;
    AuthService.logout();
    notifyListeners();
  }
}