import 'dart:io';

import 'package:dio/dio.dart';

import '../configuration/urls.dart';
import 'auth_service.dart';

class ApiService {
  static final Dio _dio = Dio(
    BaseOptions(
      baseUrl: baseUrl,
      connectTimeout: const Duration(seconds: 5),
      receiveTimeout: const Duration(seconds: 3),
      contentType: 'application/json',
    ),
  );

  static void init(AuthProvider authProvider) {
    _dio.interceptors.clear();
    _dio.interceptors.add(QueuedInterceptorsWrapper(
      // 1. ПЕРЕД ОТПРАВКОЙ (Добавляем Access Token)
      onRequest: (options, handler) async {
        // Список путей-исключений
        const whiteList = ['/account/login', '/account/register', '/account/verifyCode', '/account/refreshSession', '/account/logout'];

        // Если пути нет в списке исключений — добавляем заголовок
        if (!whiteList.any((path) => options.path.contains(path))) {
          final token = authProvider.accessToken; // Нужен метод получения Access токена
          if (token != null) {
            options.headers['Authorization'] = 'Bearer $token';
          }
        }
        return handler.next(options);
      },

      // 2. ПРИ ОШИБКЕ (Обработка 401 и Refresh)
      onError: (e, handler) async {
        if (e.response?.statusCode == 401) {
          // Пытаемся обновить токен
          final success = await _attemptRefresh(authProvider);

          if (success) {
            // Если обновили — повторяем старый запрос с новым токеном
            final String? newToken = authProvider.accessToken;
            final options = e.requestOptions;
            options.headers['Authorization'] = 'Bearer $newToken';

            // Делаем повторный запрос
            final response = await _dio.fetch(options);
            return handler.resolve(response);
          } else {
            // Если рефреш не удался (токен протух совсем) — выкидываем из приложения
            authProvider.logout();
          }
        }
        return handler.next(e);
      },
    ));
  }

  // Внутренний метод для рефреша
  static Future<bool> _attemptRefresh(AuthProvider authProvider) async {
    try {
      final refreshToken = await authProvider.getRefreshToken();
      if (refreshToken == null) return false;

      // Вызываем твой Go-метод /refresh
      final response = await _dio.post(
          '/account/refreshSession',
          data: {'refreshToken': refreshToken}
      );

      if (response.statusCode == 200) {
        try {
          String refreshToken = response.data['refreshToken'];
          String accessToken = response.data['accessToken'];
          // Сохраняем новые токены (реализуй этот метод в AuthProvider)

          await authProvider.saveTokensSilently(accessToken, refreshToken);
        } catch (e) {
          print("Ошибка при сохранении или извлечении токенов dio_service: $e");
        }

        return true;
      }
    } catch (e) {
      print("Refresh failed: $e");
    }
    return false;
  }

  // Универсальный POST
  static Future<Response> post(String path, {dynamic data, Options? options}) async {
    return await _dio.post(path, data: data, options: options);
  }

  static Future<Response> delete(String path, {dynamic data, Options? options}) async {
    return await _dio.delete(path, data: data, options: options);
  }

  static Future<Response> get(String path, {Map<String, dynamic>? queryParameters, Options? options}) async {
    return await _dio.get(
      path,
      queryParameters: queryParameters,
      options: options,
    );
  }

  static Future<Response> putBinaryFile({
    required String url,
    required File file,
    required String contentType,
  }) async {
    // Создаем отдельный экземпляр Dio, чтобы не срабатывали интерцепторы авторизации
    // (S3 не примет наш Bearer токен в заголовке)
    final uploadDio = Dio();

    final bytes = await file.readAsBytes();

    return await uploadDio.put(
      url,
      data: Stream.fromIterable([bytes]),
      options: Options(
        headers: {
          Headers.contentLengthHeader: bytes.length,
        },
        contentType: contentType,
      ),
    );
  }

  // Можно оставить как обертку для совместимости или удалить
  static Future<Response> uploadImage(String presignedUrl, File file) async {
    return await putBinaryFile(
      url: presignedUrl,
      file: file,
      contentType: 'image/jpeg',
    );
  }
}