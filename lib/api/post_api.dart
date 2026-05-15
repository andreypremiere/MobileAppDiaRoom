import 'dart:io';
import 'package:dia_room/models/post_view/base_post.dart';
import 'package:dia_room/models/post_view/feed_post.dart';
import 'package:dia_room/models/post_view/personal_post.dart';
import 'package:dio/dio.dart';
import 'auth_response.dart';
import '../models/content_post/showing_post.dart';
import '../models/post_creator/upload_file_info.dart';
import '../utils/dio_service.dart';
import 'exception_handler.dart';

Future<AuthResponse> requestPresignedUrls({
  required List<UploadFileInfo> mediaForUrls,
  required String postId,
}) async {
  try {
    final res = await ApiService.post('/post/getPresignedUrls',
      data: {"files": mediaForUrls.map((e) => e.toJson()).toList(), "postId": postId},
    );
    return AuthResponse(success: true, data: res.data);
  } on DioException catch (e) {
    return handleDioError(e, "Ошибка получения ссылок");
  }
  catch (e) {
    return handleSystemError(e);
  }
}

Future<bool> uploadSingleMediaFile(String filePath, String presignedUrl, String contentType) async {
  try {
    final file = File(filePath);
    if (!await file.exists()) return false;
    final res = await ApiService.putBinaryFile(url: presignedUrl, file: file, contentType: contentType);
    return res.statusCode == 200 || res.statusCode == 201;
  } catch (e) {
    print('Ошибка загрузки: $e');
    return false;
  }
}

Future<AuthResponse> createPostRequest({
  required Map<String, dynamic> postCreating,
  required Map<String, dynamic> modelPreview,
}) async {
  try {
    final res = await ApiService.post('/post/createPost',
      data: {"post": postCreating, "preview": modelPreview},
    );
    return AuthResponse(success: true, data: res.data);
  } on DioException catch (e) {
    return handleDioError(e, "Ошибка при создании поста");
  } catch (e) {
    return handleSystemError(e);
  }
}

Future<AuthResponse> savePostCanvas({
  required String postId,
  required List<Map<String, dynamic>> canvasPayload,
}) async {
  try {
    final res = await ApiService.post('/post/saveCanvas/$postId',
      data: {'payload': canvasPayload},
    );
    return AuthResponse(success: true, data: res.data);
  } on DioException catch (e) {
    return handleDioError(e, "Ошибка сохранения холста");
  } catch (e) {
    return handleSystemError(e);
  }
}

Future<AuthResponse> getAllPosts(
{required int page, required int limit}
    ) async {
  try {
    final res = await ApiService.get('/post/allPosts', queryParameters: {"page": page, "limit": limit});
    final List<dynamic> data = res.data;
    return AuthResponse(
      success: true,
      data: {"listPosts": data.map((j) => FeedPost.fromMap(j)).toList()},
    );
  } on DioException catch (e) {
    return handleDioError(e, "Ошибка получения ленты");
  } catch (e) {
    return handleSystemError(e);
  }
}


Future<AuthResponse> getPost(String postId) async {
  try {
    final response = await ApiService.get('/post/getPost/$postId');
    final ShowingPost post = ShowingPost.fromMap(response.data);
    return AuthResponse(
      success: true,
      data: {"post": post},
    );

  } on DioException catch (e) {
    return handleDioError(e, "Ошибка получения поста");
  } catch (e) {
    return handleSystemError(e);
  }
}

Future<AuthResponse> updateStatusPost({required String postId}) async {
  try {
    await ApiService.post('/post/updateStatusUploaded/$postId');
    return AuthResponse(success: true);
  } on DioException catch (e) {
    return handleDioError(e, "Ошибка обновления статуса");
  } catch (e) {
    return handleSystemError(e);
  }
}

Future<AuthResponse> getOwnPosts() async {
  try {
    final res = await ApiService.get('/post/getPersonalPosts');
    final List<dynamic> data = res.data;
    return AuthResponse(
      success: true,
      data: {"listPosts": data.map((j) => PersonalPost.fromMap(j)).toList()},
    );
  } on DioException catch (e) {
    return handleDioError(e, "Ошибка получения личных постов");
  } catch (e) {
    return handleSystemError(e);
  }
}

Future<AuthResponse> getRoomPosts(String roomId) async {
  try {
    final response = await ApiService.get('/post/getRoomPosts/$roomId');

    if (response.data is List) {
      final List<dynamic> data = response.data;

      final List<BasePost> listPosts = data
          .map((json) => BasePost.fromMap(json))
          .toList();

      return AuthResponse(
          success: true,
          data: {"listPosts": listPosts}
      );
    }
    return AuthResponse(
        success: false,
        data: {"error": "Ошибка при получении на клиенте"}
    );

  } on DioException catch (e) {
    return handleDioError(e, "Ошибка получения постов");
  } catch (e) {
    return handleSystemError(e);
  }
}

Future<void> sendView({
  required String postId,
}) async {
  try {
    await ApiService.post(
      '/post/view/$postId',
    );

  } catch (e) {
    return;
  }
}

Future<AuthResponse> toggleLike(String postId, bool isLike) async {
  try {
    if (isLike) {
      await ApiService.post('/post/like/$postId');
    } else {
      await ApiService.delete('/post/like/$postId');
    }
    return AuthResponse(success: true);
  } on DioException catch (e) {
    return handleDioError(e, "Ошибка при изменении лайка");
  } catch (e) {
    return handleSystemError(e);
  }
}

Future<bool> getLikeStatus(String postId) async {
  try {
    final response = await ApiService.get('/post/isLiked/$postId');
    return response.data['isLiked'] ?? false;
  } catch (e) {
    return false;
  }
}

Future<AuthResponse> requestGetLikers({
  required String postId,
  required int page,
  required int limit,
}) async {
  try {
    final response = await ApiService.get(
      '/post/likers/$postId',
      queryParameters: {
        'page': page,
        'limit': limit,
      },
    );

    return AuthResponse(
      success: true,
      data: response.data,
    );

  } on DioException catch (e) {
    return handleDioError(e, "Ошибка получения комнат");
  } catch (e) {
    return handleSystemError(e);
  }
}

Future<AuthResponse> requestDeletePost(String postId) async {
  try {
    await ApiService.delete('/post/deletePost/$postId');

    return AuthResponse(
        success: true,
    );

  } on DioException catch (e) {
    return handleDioError(e, "Ошибка получения комнат");
  } catch (e) {
    return handleSystemError(e);
  }
}