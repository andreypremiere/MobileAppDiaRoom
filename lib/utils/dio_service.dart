import 'dart:io';

import 'package:dia_room/api/auth_response.dart';
import 'package:dio/dio.dart';
import 'package:dio/io.dart';

import '../api/exception_handler.dart';
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

        options.headers['X-Client-Secret'] = 'fcdf2735-c13b-4aa5-9b7c-1de0597baa88';

        // Если пути нет в списке исключений — добавляем заголовок
        if (!whiteList.any((path) => options.path.contains(path))) {
          final token = authProvider.accessToken;
          if (token != null) {
            options.headers['Authorization'] = 'Bearer $token';
          }
        }
        return handler.next(options);
      },

      // Обработка ошибок
      onError: (e, handler) async {
        // Если упал запрос на обновление токенов, то возвращаем ошибку,которую вернул запрос attemptRefresh
        if (e.requestOptions.path.contains('/account/refreshSession')) {
          return handler.next(e);
        }

        // Обработка 401 ошибки
        if (e.response?.statusCode == 401) {
          if (e.requestOptions.extra['isRetry'] == true) {
            await authProvider.logout();
            return handler.next(e);
          }

          // Запрос обновления токена
          final success = await attemptRefresh(authProvider);

          // Сработает, если нет refreshToken в хранилище,
          // Если не найдено значение в бд
          // Если истек срок токена ( запрос attemptRefresh вернул 401 ошибку)
          if (success == null) {
            // Сервер ответил 401 или 404 (NOT_FOUND) на рефреш — жесткий логаут
            await authProvider.logout();
            return handler.next(e); // Возвращаем изначальную ошибку
          }

          else if (success.success) {
            // Токен успешно обновился! Повторяем исходный запрос
            final String? newToken = authProvider.accessToken;
            final options = e.requestOptions;
            options.headers['Authorization'] = 'Bearer $newToken';

            // Помечаем запрос, что он отправляется повторно
            options.extra['isRetry'] = true;

            try {
              final response = await _dio.fetch(options);
              return handler.resolve(response);
            } catch (retryError) {
              return handler.next(retryError is DioException ? retryError : e);
            }
          }

          else {
            print("Результат обновления токена false");
            return handler.next(e);
          }
        }

        print("Конец обработки ошибки.");
        return handler.next(e);
      },
    ));

    bool checkCertificateHash(List<int> der) {
      // Реализация сверки хэша вашего Let's Encrypt сертификата
      return true;
    }

    void enableSSLPinning(Dio dio) {
      dio.httpClientAdapter = IOHttpClientAdapter(
        createHttpClient: () {
          final SecurityContext context = SecurityContext(withTrustedRoots: true);
          final HttpClient client = HttpClient(context: context);

          client.badCertificateCallback = (X509Certificate cert, String host, int port) {
            // Жестко проверяем SHA-256 хэш сертификата сервера
            final serverDer = cert.der;
            // Здесь должна быть логика сравнения хэша с зашитым в приложение константным хэшем
            bool isTrusted = checkCertificateHash(serverDer);
            return isTrusted;
          };
          return client;
        },
      );
    }
  }

  // Внутренний метод для рефреша
  static Future<AuthResponse?> attemptRefresh(AuthProvider authProvider) async {
    try {
      final refreshToken = await authProvider.getRefreshToken();
      if (refreshToken == null) return null;

      final refreshDio = Dio(BaseOptions(
        baseUrl: baseUrl,
        connectTimeout: const Duration(seconds: 5),
        receiveTimeout: const Duration(seconds: 3),
      ));

      final response = await refreshDio.post(
        '/account/refreshSession',
        data: {'refreshToken': refreshToken},
      );

      // Токены успешно обновлены
      String refreshTokenUpdated = response.data['refreshToken'];
      String accessToken = response.data['accessToken'];

      // Обновляет значения в провайдере и сохраняет в хранилище
      await authProvider.saveTokensSilently(accessToken, refreshTokenUpdated);

      return AuthResponse(success: true);

    } on DioException catch (e) {
      final response = e.response;

      print("пришедший response: $response");

      if (response != null) {
        print("Статус-код рефреша: ${response.statusCode}");
        print("Тип данных response.data: ${response.data.runtimeType}");
        print("Содержимое response.data: ${response.data}");

        // 2. Проверяем 404 с конкретным кодом ошибки
        if (response.statusCode == 404 && response.data?["error_code"] == "NOT_FOUND") {
          print("Сессия не найдена на сервере (404 NOT_FOUND). Запускаем logout.");
          return null; // Вернет null -> сработает logout()
        }
        // 3. Проверяем 401 Unauthorized
        else if (response.statusCode == 401) {
          print("Истек срок жизни токена (401). Запускаем logout.");
          return null; // Вернет null -> сработает logout()
        }
      }
      return handleDioError(e, "Ошибка при обновлении токенов. Пожалуйста, сообщите в поддержку.");
    } catch (e) {
      print("Выполнился последний блок");
      return AuthResponse(success: false, message: "Ошибка при обновлении токенов. Пожалуйста, сообщите в поддержку.");
    }
  }

  // Универсальный POST
  static Future<Response> post(String path, {dynamic data, Options? options}) async {
    return await _dio.post(path, data: data, options: options);
  }

  static Future<Response> delete(String path, {dynamic data, Options? options}) async {
    return await _dio.delete(path, data: data, options: options);
  }

  static Future<Response> patch(String path, {dynamic data, Options? options}) async {
    return await _dio.patch(path, data: data, options: options);
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