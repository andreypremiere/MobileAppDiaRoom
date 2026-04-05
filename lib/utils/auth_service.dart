import 'package:dia_room/utils/utils.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'dart:convert';

import '../models/user.dart';

/// Сервис для работы с защищенным хранилищем устройства.
///
/// saveUser - Позволяет сохранить пользователя в хранилище в формате JSON.
///
/// getUser - Извлекает User из хранилища.
///
/// logout - Очищает хранилище (удаляет все данные о User (по ключу)).
class AuthService {
  static const _storage = FlutterSecureStorage();
  static const _userKey = 'user_data_secure';

  /// Сохранение объекта User в защищенное хранилище
  static Future<void> saveUser(User user) async {
    try {
      // Сериализуем объект в JSON-строку для записи
      String jsonString = json.encode(user.toMap());
      await _storage.write(key: _userKey, value: jsonString);
    } catch (e) {
      printError("""Возникла ошибка при сохранении User в хранилище.
Location: auth_service.dart - class AuthService - saveUser.
User перед сохранением $user.
Ошибка: $e.""");
    }
  }

  /// Получение объекта User из защищенного хранилища
  static Future<User?> getUser() async {
    String? jsonString;
    try {
      jsonString = await _storage.read(key: _userKey);

      if (jsonString == null) return null;

      // Декодируем строку и восстанавливаем объект через fromMap
      Map<String, dynamic> userMap = json.decode(jsonString);
      return User.fromMap(userMap);
    } catch (e) {
      printError("""Возникла ошибка при получении User из хранилища.
Location: auth_service.dart - class AuthService - getUser.
jsonString перед сохранением $jsonString.
Ошибка: $e.""");
    }
    return null;
  }

  /// Очистка хранилища при выходе из аккаунта
  static Future<void> logout() async {
    try {
      await _storage.delete(key: _userKey);
    }
    catch (e) {
      printError("""Возникла ошибка при очистке хранилища при выходе.
Location: auth_service.dart - class AuthService - logout.
Ошибка: $e.""");
    }
  }
}

/// Провайдер состояния авторизации для управления UI в реальном времени.
/// Хранит User и предоставляет доступ к нему из любого места в приложении.
class AuthProvider extends ChangeNotifier {
  User? _user;

  /// Геттер для безопасного доступа к текущему пользователю
  User? get user => _user;

  /// Геттер для получения статуса авторизации пользователя
  bool get isAuthenticated => _user != null;

  /// Метод для загрузки данных при старте приложения
  Future<void> loadUser() async {
    _user = await AuthService.getUser();
    if (_user == null) {
      logout();
      return;
    }
    notifyListeners();
  }

  /// Установка пользователя в состояние и запись в SecureStorage
  void login(User newUser) {
    _user = newUser;
    AuthService.saveUser(newUser);
    notifyListeners();
  }

  /// Сброс текущего сеанса и очистка дисковой памяти
  void logout() {
    _user = null;
    AuthService.logout();
    notifyListeners();
  }
}
