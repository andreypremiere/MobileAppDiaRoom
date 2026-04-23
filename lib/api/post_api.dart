import 'dart:convert';
import 'dart:io';

import 'package:dia_room/configuration/urls.dart';
import 'package:dia_room/models/post_creator/preview_request.dart';
import 'package:dia_room/models/post_view/feed_post.dart';
import 'package:dio/dio.dart';
import 'package:http/http.dart' as http;

import '../models/auth_response.dart';
import '../models/content_post/content_post.dart';
import '../models/post_creator/block_photos.dart';
import '../models/post_creator/block_video.dart';
import '../models/post_creator/upload_file_info.dart';
import '../models/post_creator/upload_task.dart';
import '../utils/dio_service.dart';

Future<AuthResponse> requestPresignedUrls({
  required List<UploadFileInfo> mediaForUrls,
  required String postId,
}) async {
  try {
    final response = await ApiService.post(
      '/post/getPresignedUrls',
      data: {
        "files": mediaForUrls.map((e) => e.toJson()).toList(),
        "postId": postId
      },
    );

    return AuthResponse(success: true, data: response.data);

  } on DioException catch (e) {
    return AuthResponse(
        success: false,
        message: e.response?.data['error'] ?? "Ошибка получения ссылок для загрузки"
    );
  } catch (e) {
    return AuthResponse(success: false, message: "Системная ошибка: $e");
  }
}

Future<bool> uploadSingleMediaFile(
    String filePath,
    String presignedUrl,
    String contentType,
    ) async {
  try {
    final file = File(filePath);
    if (!await file.exists()) {
      print("Файл не существует. Файл не будет загружен. UploadSingleMediaFile");
      return false;
    }

    // Используем уже готовый метод из твоего ApiService
    final response = await ApiService.putBinaryFile(url: presignedUrl, file: file, contentType: contentType);

    return response.statusCode == 200 || response.statusCode == 201;
  } catch (e) {
    print('Ошибка загрузки медиа: $e');
    return false;
  }
}

Future<AuthResponse> createPostRequest({
  required Map<String, dynamic> postCreating,
  required Map<String, dynamic> modelPreview,
}) async {
  try {
    final response = await ApiService.post(
      '/post/createPost',
      data: {
        "post": postCreating,
        "preview": modelPreview
      },
    );

    return AuthResponse(success: true, data: response.data);

  } on DioException catch (e) {
    return AuthResponse(
        success: false,
        message: e.response?.data['error'] ?? "Ошибка при создании поста"
    );
  } catch (e) {
    return AuthResponse(success: false, message: "Непредвиденная ошибка: $e");
  }
}

Future<AuthResponse> savePostCanvas({
  required String postId,
  required List<Map<String, dynamic>> canvasPayload,
}) async {
  try {
    final response = await ApiService.post(
      '/post/saveCanvas/$postId',
      data: {
        'payload': canvasPayload,
      },
    );

    return AuthResponse(success: true, data: response.data);

  } on DioException catch (e) {
    return AuthResponse(
        success: false,
        message: e.response?.data['error'] ?? "Ошибка сохранения холста"
    );
  } catch (e) {
    return AuthResponse(success: false, message: "Ошибка: $e");
  }
}

Future<AuthResponse> getAllPosts() async {
  try {
    // 1. Выполняем GET запрос
    final response = await ApiService.get('/post/allPosts');

    if (response.data is List) {
      final List<dynamic> data = response.data;

      List<FeedPost> listPosts = data.map((json) => FeedPost.fromMap(json)).toList();

      return AuthResponse(success: true, data: {"listPosts": listPosts});
    }

    return AuthResponse(success: false, data: {"error": "Ошибка при преобразовании объектов"});

  } on DioException catch (e) {
    // Логируем ошибку или выбрасываем исключение для обработки в UI
    final errorMessage = e.response?.data['message'] ?? "Ошибка получения ленты";
    return AuthResponse(success: false, data: {"error": errorMessage});

  } catch (e) {
    return AuthResponse(success: false, data: {"error": "Непредвиденная ошибка $e"});}
}

Future<AuthResponse> getPost(String postId) async {
  try {
    // 1. Выполняем GET запрос с передачей postId в URL
    // Соответствует роуту mux: "GET /getPost/{postId}"
    final response = await ApiService.get('/post/getPost/$postId');

    // 2. Проверяем, что пришел объект (Map), а не список
    if (response.data is Map<String, dynamic>) {
      final Map<String, dynamic> data = response.data;

      // Мапим данные в модель ShowingPost, которую мы создали ранее
      final ShowingPost post = ShowingPost.fromMap(data);

      return AuthResponse(
        success: true,
        data: {"post": post},
      );
    }

    return AuthResponse(
      success: false,
      data: {"error": "Неверный формат данных от сервера"},
    );

  } on DioException catch (e) {
    // Обработка ошибок Dio (404, 500 и т.д.)
    final errorMessage = e.response?.data['error'] ?? "Ошибка при загрузке поста";
    return AuthResponse(success: false, data: {"error": errorMessage});

  } catch (e) {
    return AuthResponse(
      success: false,
      data: {"error": "Непредвиденная ошибка: $e"},
    );
  }
}

Future<AuthResponse> updateStatusPost({
  required String postId,
}) async {
  try {
    await ApiService.post(
      '/post/updateStatusUploaded/$postId',
    );

    return AuthResponse(success: true, data: null);

  } on DioException catch (e) {
    return AuthResponse(
        success: false,
        message: e.response?.data['error'] ?? "Ошибка сохранения холста"
    );
  } catch (e) {
    return AuthResponse(success: false, message: "Ошибка: $e");
  }
}
