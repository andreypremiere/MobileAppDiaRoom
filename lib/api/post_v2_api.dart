import 'package:dia_room/contracts/posts_v2/requests/creating_post.dart';
import 'package:dio/dio.dart';

import '../contracts/posts_v2/requests/updating_media_post_status.dart';
import '../contracts/posts_v2/requests/updating_post_status.dart';
import '../utils/dio_service.dart';
import 'auth_response.dart';
import 'exception_handler.dart';

Future<AuthResponse> createPost({
  required PostCreateRequest post,
}) async {
  try {
    final response = await ApiService.post('/post_v2/createPost', data: post.toMap());

    return AuthResponse(success: true, data: response.data);
  } on DioException catch (e) {
    return handleDioError(e, "Ошибка при создании поста");
  }
}

Future<AuthResponse> updatePostStatus({
  required UpdatingPostStatus postStatus,
}) async {
  try {
    final response = await ApiService.post(
      '/post_v2/updatePostStatus',
      data: postStatus.toMap()
    );

    return AuthResponse(success: true, data: response.data);
  } on DioException catch (e) {
    return handleDioError(e, "Ошибка при обновлении статуса поста");
  }
}

Future<AuthResponse> updateMediaStatus({
  required UpdatingMediaPostStatus mediaStatus,
}) async {
  try {
    final response = await ApiService.post(
      '/post_v2/updateMediaStatus',
      data: mediaStatus.toMap(),
    );

    return AuthResponse(success: true, data: response.data);
  } on DioException catch (e) {
    return handleDioError(e, "Ошибка при обновлении статуса медиафайла");
  }
}