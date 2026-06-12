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

Future<AuthResponse> getPostsByRoomId({
  required String targetRoomId,
  required int limit,
  required int page,
}) async {
  try {
    final response = await ApiService.get(
      '/post_v2/getPostsByRoomId/$targetRoomId',
      queryParameters: {
        'limit': limit,
        'page': page,
      },
    );

    return AuthResponse(success: true, data: response.data);
  } on DioException catch (e) {
    return handleDioError(e, "Ошибка при получении постов комнаты");
  }
}

Future<AuthResponse> getGlobalFeed({
  required int limit,
  required int page,
}) async {
  try {
    final response = await ApiService.get(
      '/post_v2/posts/feed',
      queryParameters: {
        'limit': limit,
        'page': page,
      },
    );

    return AuthResponse(success: true, data: response.data);
  } on DioException catch (e) {
    return handleDioError(e, "Ошибка при загрузке глобальной ленты");
  }
}

Future<AuthResponse> likePost({
  required String postId,
}) async {
  try {
    final response = await ApiService.post(
      '/post_v2/posts/like',
      data: {'postId': postId},
    );

    return AuthResponse(success: true, data: response.data);
  } on DioException catch (e) {
    return handleDioError(e, "Ошибка при установке лайка");
  }
}

Future<AuthResponse> unlikePost({
  required String postId,
}) async {
  try {
    final response = await ApiService.delete(
      '/post_v2/posts/like',
      data: {'postId': postId},
    );

    return AuthResponse(success: true, data: response.data);
  } on DioException catch (e) {
    return handleDioError(e, "Ошибка при снятии лайка");
  }
}

Future<AuthResponse> getCountPostsV2(
    {required String roomId}
    ) async {
  try {
    final res = await ApiService.get('/post_v2/posts/count/$roomId');
    return AuthResponse(
      success: true,
      data: res.data,
    );
  } on DioException catch (e) {
    return handleDioError(e, "Ошибка получения количества постов");
  } catch (e) {
    return handleSystemError(e);
  }
}

Future<AuthResponse> createComment({
  required String postId,
  required String text,
}) async {
  try {
    final response = await ApiService.post(
      '/post_v2/comments/create',
      data: {'postId': postId, "text": text},
    );

    return AuthResponse(success: true, data: response.data);
  } on DioException catch (e) {
    return handleDioError(e, "Не удалось опубликовать комментарий");
  }
}

Future<AuthResponse> getComments({
  required String postId,
  required int page,
  required int limit,
}) async {
  try {
    final res = await ApiService.get('/post_v2/comments/$postId', queryParameters: {"page": page, "limit": limit});
    return AuthResponse(
      success: true,
      data: res.data,
    );
  } on DioException catch (e) {
    return handleDioError(e, "Не удалось получить комментарии");
  } catch (e) {
    return handleSystemError(e);
  }
}

Future<AuthResponse> searchPostsV2(
    {required int page, required int limit, required String value}
    ) async {
  try {
    final res = await ApiService.get('/post_v2/posts/search', queryParameters: {"page": page, "limit": limit, "hashtag": value});
    return AuthResponse(
      success: true,
      data: res.data,
    );
  } on DioException catch (e) {
    return handleDioError(e, "Ошибка во время поиска");
  } catch (e) {
    return handleSystemError(e);
  }
}

Future<AuthResponse> deletePost(
{required String postId}
) async {
  try {
    await ApiService.delete('/post_v2/posts/delete/$postId');
    return AuthResponse(success: true,);
  } on DioException catch (e) {
    return handleDioError(e, "Ошибка при удалени поста");
  } catch (e) {
    return handleSystemError(e);
  }
}