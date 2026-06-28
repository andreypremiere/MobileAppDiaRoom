import 'package:dia_room/api/account_api.dart';
import 'package:dia_room/contracts/account-microservice/requests/check_version_request.dart';
import 'package:dia_room/contracts/account-microservice/responses/check_version_response.dart';
import 'package:dia_room/utils/utils.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'jwt_manager.dart';

/// Сервис для работы с защищенным хранилищем устройства.
class AuthService {
  static const _storage = FlutterSecureStorage();

  static const _keyAccessToken = 'access_token';
  static const _keyRefreshToken = 'refresh_token';
  static const _keyIsConfigured = 'is_configured';

  static Future<void> saveAuthData({
    required String access,
    required String refresh,
    required bool configured
  }) async {
    await saveTokens(access: access, refresh: refresh);
    await saveStatusConfigured(status: configured);
  }

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

  static Future<Map<String, String?>> getAuthData() async {
    return await _storage.readAll();
  }

  static Future<String?> getRefreshToken() async {
    return await _storage.read(key: _keyRefreshToken);
  }

  static Future<void> clearTokens() async {
    await _storage.delete(key: _keyAccessToken);
    await _storage.delete(key: _keyRefreshToken);
  }

}

/// Провайдер состояния авторизации для управления UI в реальном времени.
class AuthProvider extends ChangeNotifier {
  String? _accessToken;
  String? _userId;
  String? _roomId;
  bool _isConfigured = false;

  String _versionStatus = 'NO_UPDATE'; // Может быть: NO_UPDATE, UPDATE, UPDATE_CRITICAL
  String _versionMessage = '';
  bool _isOptionalUpdateDismissed = false;

  String get versionStatus => _versionStatus;
  String get versionMessage => _versionMessage;
  bool get isOptionalUpdateDismissed => _isOptionalUpdateDismissed;

  String? get userId => _userId;
  String? get roomId => _roomId;
  String? get accessToken => _accessToken;
  bool get isAuthenticated => _accessToken != null;
  bool get isConfigured => _isConfigured;

  Future<void> loadSession() async {
    final data = await AuthService.getAuthData();
    final access = data['access_token'];

    _isConfigured = data['is_configured'] == 'true';

    if (access != null) {
      _parseAndSetToken(access);
    } else {
      await logout();
      return;
    }
    notifyListeners();
  }

  void _parseAndSetToken(String token) {
    JwtMetadata? decodedToken = JwtManager.getMetadata(token);
    if (decodedToken == null) {
      return;
    }
    _accessToken = token;
    _userId = decodedToken.userId;
    _roomId = decodedToken.roomId;
  }

  void login(String access, String refresh, bool configured) {
    final result = JwtManager.isTokenValid(access);

    if (result) {
      _parseAndSetToken(access);
      _isConfigured = configured;
      AuthService.saveAuthData(access: access, refresh: refresh, configured: configured);
    }
    notifyListeners();
  }

  Future<void> saveStatusConfigure(bool status) async {
    _isConfigured = status;
    await AuthService.saveStatusConfigured(status: status);
    notifyListeners();
  }

  Future<void> logout() async {
    _accessToken = null;
    _userId = null;
    _roomId = null;
    await AuthService.clearTokens();
    notifyListeners();
  }

  Future<String?> getRefreshToken() async {
    return await AuthService.getRefreshToken();
  }

  Future<void> saveTokensSilently(String accessToken, String refreshToken) async {
    _parseAndSetToken(accessToken);
    await AuthService.saveTokens(access: accessToken, refresh: refreshToken);
  }

  Future<void> checkApplicationVersion() async {
    try {
      CheckVersionRequest info = await getAppVersionRequest();

      final response = await checkVersion(info);

      CheckVersionResponse data;
      if (response.success) {
        data = CheckVersionResponse.fromMap(response.data);
      } else {
        return;
      }

      if (response.data != null) {
        _versionStatus = data.status;
        _versionMessage = data.message;
      }
    } catch (e) {
      _versionStatus = 'NO_UPDATE';
    } finally {
      notifyListeners();
    }
  }

  void dismissOptionalUpdate() {
    _isOptionalUpdateDismissed = true;
    notifyListeners();
  }

}
