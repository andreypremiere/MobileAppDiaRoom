import 'package:dia_room/utils/utils.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'dart:convert';

import '../models/user.dart';
import 'jwt_manager.dart';

/// Сервис для работы с защищенным хранилищем устройства.
class AuthService {
  static const _storage = FlutterSecureStorage();

  static const _keyAccessToken = 'access_token';
  static const _keyRefreshToken = 'refresh_token';
  static const _keyIsConfigured = 'is_configured';

  /// Сохранение токенов и статуса
  static Future<void> saveAuthData({
    required String access,
    required String refresh,
    required bool configured
  }) async {
    await saveTokens(access: access, refresh: refresh);
    await Future.wait([
      _storage.write(key: _keyIsConfigured, value: configured.toString()),
    ]);
  }

  /// Сохранение токенов
  static Future<void> saveTokens({
    required String access,
    required String refresh,
}) async {
    await Future.wait([
      _storage.write(key: _keyAccessToken, value: access),
      _storage.write(key: _keyRefreshToken, value: refresh),
    ]);
  }

  static Future<void> saveStatusConfigured({required bool status}) async {
    await Future.wait([
      _storage.write(key: _keyIsConfigured, value: status.toString())
    ]);
  }

  /// Получение данных для восстановления сессии
  static Future<Map<String, String?>> getAuthData() async {
    return await _storage.readAll();
  }

  /// Удаление данных при выходе
  static Future<void> clearAll() async => await _storage.deleteAll();

}

/// Провайдер состояния авторизации для управления UI в реальном времени.
class AuthProvider extends ChangeNotifier {
  String? _accessToken;
  String? _userId;
  String? _roomId;
  bool _isConfigured = false;
  bool _isLoading = true;

  // Геттеры
  String? get userId => _userId;
  String? get roomId => _roomId;
  String? get accessToken => _accessToken;
  bool get isAuthenticated => _accessToken != null;
  bool get isConfigured => _isConfigured;
  bool get isLoading => _isLoading;

  /// Загрузка при старте приложения
  Future<void> loadSession() async {
    _isLoading = true;
    notifyListeners();

    final data = await AuthService.getAuthData();
    final access = data['access_token'];

    if (access != null && JwtManager.isTokenValid(access)) {
      _parseAndSetToken(access);
      _isConfigured = data['is_configured'] == 'true';
    } else {
      // Если токен просрочен, здесь можно вызвать автоматический Refresh
      // или просто сбросить сессию
      _accessToken = null;
    }

    _isLoading = false;
    notifyListeners();
  }

  /// Вспомогательный метод для извлечения ID из JWT
  void _parseAndSetToken(String token) {
    JwtMetadata? decodedToken = JwtManager.getMetadata(token);
    if (decodedToken == null) {
      return;
    }
    _accessToken = token;
    _userId = decodedToken.userId;
    _roomId = decodedToken.roomId;
  }

  /// Вход / Подтверждение кода
  void login(String access, String refresh, bool configured) {
    _parseAndSetToken(access);
    _isConfigured = configured;
    AuthService.saveAuthData(access: access, refresh: refresh, configured: configured);
    notifyListeners();
  }

  void saveStatusConfigure(bool status) {
    _isConfigured = status;
    AuthService.saveStatusConfigured(status: status);
    notifyListeners();
  }

  Future<void> logout() async {
    _accessToken = null;
    _userId = null;
    _roomId = null;
    _isConfigured = false;
    await AuthService.clearAll();
    notifyListeners();
  }
}
