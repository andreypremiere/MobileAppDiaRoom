import 'dart:convert';
import 'dart:io';

import 'package:dia_room/configuration/urls.dart';
import 'package:dia_room/models/post_creator/preview_request.dart';
import 'package:http/http.dart' as http;

import '../models/post_creator/block_photos.dart';
import '../models/post_creator/block_video.dart';
import '../models/post_creator/upload_file_info.dart';
import '../models/post_creator/upload_task.dart';

Future<Map<dynamic, dynamic>?> requestPresignedUrls({
  required List<UploadFileInfo> mediaForUrls,
  required String token,
  required String postId,
}) async {
  try {
    final response = await http.post(
      Uri.parse(getPresignedUrls),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
      body: jsonEncode({"files": mediaForUrls.map((e) => e.toJson()).toList(), "postId": postId}),
    );

    if (response.statusCode != 200) {
      // Добавь это, чтобы увидеть реальную причину (например, ошибку из Go)
      print("Server Error: ${response.statusCode}");
      print("Server Body: ${response.body}");
      return null;
    }

    if (response.statusCode == 200) {
      print('Ответ от сервера пришел положительный.');
      return jsonDecode(response.body);
    } else {
      print('Failed to get presigned URLs: ${response.body}');
      return null;
    }
  } catch (e) {
    print('Ошибка во время выполнения запроса');
    return null;
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
      throw Exception('Файл не найден: ${filePath}');
    }

    final bytes = await file.readAsBytes();

    final response = await http.put(
      Uri.parse(presignedUrl),
      body: bytes,
      headers: {'Content-Type': contentType},
    );

    if (response.statusCode != 200) {
      print('Bad response во время загрузки медиа в хранилище');
      return false;
    }
  } catch (e) {
    print('Возникла ошибка во время выполнения запроса: $e');
    return false;
  }
  return true;
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
      body: jsonEncode({"post": postCreating, "preview": modelPreview}),
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

Future<bool> savePostCanvas({
  required String postId,
  required List<Map<String, dynamic>> canvasPayload,
  required String token,
}) async {
  try {
    final url = Uri.parse('$baseUrl/post/$postId/canvas');

    final response = await http.post(
      url,
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
      // Оборачиваем payload в ключ, как ожидает сервер
      body: jsonEncode({
        'payload': canvasPayload,
      }),
    );

    if (response.statusCode == 200 || response.statusCode == 201) {
      print('Canvas успешно сохранен и привязан к посту.');
      return true;
    } else {
      print('Ошибка сервера [${response.statusCode}]: ${response.body}');
      return false;
    }
  } catch (e, stack) {
    print('Сетевая ошибка при сохранении canvas: $e\n$stack');
    return false;
  }
}
