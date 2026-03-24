import 'dart:convert';
import 'dart:io';

import 'package:dia_room/configuration/urls.dart';
import 'package:dia_room/models/post_creator/preview_request.dart';
import 'package:http/http.dart' as http;

import '../models/post_creator/block_photos.dart';
import '../models/post_creator/block_video.dart';
import '../models/post_creator/upload_file_info.dart';
import '../models/post_creator/upload_task.dart';

Future<Map<String, dynamic>> requestPresignedUrls(List<Map<String, dynamic>> files, String token, String postId, PreviewRequest? previewReq) async {
  final requestBody = {
    "files": files,
    "postId": postId
    //   Здесь потом добавить отдельно картинку для всего поста
  };


  if (previewReq != null) {
    requestBody['previewRequest'] = previewReq;
  }
  print("previewRequest перед отправкой ${requestBody['previewRequest']}");

  final response = await http.post(
    Uri.parse(getPresignedUrls),
    headers: {
      'Content-Type': 'application/json',
      'Authorization': 'Bearer $token',
    },
    body: jsonEncode(requestBody),
  );

  if (response.statusCode != 200) {
    // Добавь это, чтобы увидеть реальную причину (например, ошибку из Go)
    print("Server Error: ${response.statusCode}");
    print("Server Body: ${response.body}");
    throw Exception("Failed to get presigned URLs: ${response.statusCode}");
  }

  if (response.statusCode == 200) {
    print('Ответ от сервера пришел положительный.');
    return jsonDecode(response.body);
  } else {
    throw Exception('Failed to get presigned URLs: ${response.body}');
  }

}

Future<void> uploadSingleMediaFile(UploadTask task) async {
  final file = File(task.fileInfo.localPath);
  if (!await file.exists()) {
    throw Exception('Файл не найден: ${task.fileInfo.localPath}');
  }

  final bytes = await file.readAsBytes();

  final response = await http.put(
    Uri.parse(task.presignedUrl),
    body: bytes,
    headers: {
      'Content-Type': task.fileInfo.contentType,
    },
  );

  if (response.statusCode != 200) {
    throw Exception('S3 Upload failed: ${response.statusCode} | Body: ${response.body}');
  }
}

Future<Map<dynamic, dynamic>?> createPostRequest({
  required Map<String, dynamic> postCreating,
  required Map<String, dynamic> modelPreview,
  required String token,
}) async {
  try {
    final response = await http.post(
      Uri.parse('$baseUrl/post/createPost'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
      // Отправляем оба объекта в одном JSON
      body: jsonEncode({
        "post": postCreating,
        "preview": modelPreview,
      }),
    );

    // Проверяем на 200 (OK) или 201 (Created)
    if (response.statusCode == 200 || response.statusCode == 201) {
      return jsonDecode(response.body) as Map<dynamic, dynamic>;
    } else {
      print('Ошибка сервера (${response.statusCode}): ${response.body}');
      return null;
    }
  } catch (e) {
    print('Ошибка при выполнении запроса createPost: $e');
    return null;
  }
}

Future<void> publishPostRequest({
  required String postId,
  required List<Map<dynamic, dynamic>> payload, // результат toJsonPayload()
  required String token,
  String? previewUrl,
  List<String>? hashtags
}) async {
  final response = await http.post(
    Uri.parse('$baseUrl/post/publishPost'),
    headers: {
      'Content-Type': 'application/json',
      'Authorization': 'Bearer $token',
    },
    body: jsonEncode({
      "postId": postId,
      "payload": payload,
      "previewUrl": previewUrl,
      "hashtags": hashtags,
    }),
  );

  print('body: ${jsonEncode({
    "postId": postId,
    "payload": payload,
    "previewUrl": previewUrl,
    "hashtags": hashtags,
  })}');

  if (response.statusCode != 200 && response.statusCode != 201) {
    throw Exception('Failed to publish post: ${response.body}');
  }
}