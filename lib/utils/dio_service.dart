import 'package:dio/dio.dart';

import '../configuration/urls.dart';

class ApiService {
  // Создаем экземпляр Dio с базовыми настройками
  static final Dio _dio = Dio(
    BaseOptions(
      baseUrl: baseUrl,
      connectTimeout: const Duration(seconds: 5),
      receiveTimeout: const Duration(seconds: 3),
      contentType: 'application/json',
    ),
  );

  static Dio get client => _dio;

  // Универсальный POST
  static Future<Response> post(String path, {dynamic data, Options? options}) async {
    return await _dio.post(path, data: data, options: options);
  }
}