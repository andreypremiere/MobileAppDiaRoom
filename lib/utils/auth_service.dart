import 'package:flutter/foundation.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'dart:convert';

import '../models/user.dart';

// Сервис для работы с защищенным хранилищем устройства
class AuthService {
  // Используем SecureStorage для шифрования чувствительных данных (токенов)
  static const _storage = FlutterSecureStorage();
  static const _userKey = 'user_data_secure';

  // Сохранение объекта User в хранилище после успешного входа
  static Future<void> saveUser(User user) async {
    // Сериализуем объект в JSON-строку для записи
    String jsonString = json.encode(user.toMap());
    await _storage.write(key: _userKey, value: jsonString);
  }

  // Получение данных пользователя из хранилища
  static Future<User?> getUser() async {
    try {
      String? jsonString = await _storage.read(key: _userKey);
      print("JsonString $jsonString");

      if (jsonString == null) return null;

      // Декодируем строку и восстанавливаем объект через fromMap
      Map<String, dynamic> userMap = json.decode(jsonString);
      return User.fromMap(userMap);
    } catch (e) {
      print('Ошибка во время получения User');
      return null;
    }
  }

  // Быстрая проверка наличия активной сессии
  static Future<bool> isAuthenticated() async {
    User? user = await getUser();
    return user != null;
  }

  // Очистка хранилища при выходе из аккаунта
  static Future<void> logout() async {
    await _storage.delete(key: _userKey);
  }
}

// Провайдер состояния авторизации для управления UI в реальном времени
class AuthProvider extends ChangeNotifier {
  User? _user;

  // Геттеры для безопасного доступа к текущему пользователю и его статусу
  User? get user => _user;

  bool get isAuthenticated => _user != null;

  // Метод для первичной загрузки данных при старте приложения
  Future<void> loadUser() async {
    _user = await AuthService.getUser();
    // Уведомляем систему о том, что статус авторизации загружен
    notifyListeners();
  }

  // Установка пользователя в состояние и запись в SecureStorage
  void login(User newUser) {
    _user = newUser;
    AuthService.saveUser(newUser);
    notifyListeners();
  }

  // Сброс текущего сеанса и очистка дисковой памяти
  void logout() {
    _user = null;
    AuthService.logout();
    notifyListeners();
  }
}
