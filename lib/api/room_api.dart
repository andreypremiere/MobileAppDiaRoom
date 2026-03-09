import 'dart:convert';

import 'package:dia_room/configuration/urls.dart' as urls;
import 'package:http/http.dart' as http;

Future<Map<String, dynamic>?> getRoomByRoomId(String roomId, String token) async {
  final urlPath = Uri.parse(urls.getRoomByRoomId);

  try {
    final response = await http.post(
      urlPath,
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token'
      },
      body: jsonEncode({'roomId': roomId})
    );
    
    if (response.statusCode == 200) {
      final decodedBody = jsonDecode(response.body);
      print('Декодированный ответ: $decodedBody');
      return decodedBody;
    }
    else {
      final error = jsonDecode(response.body)['error'];
      print('Ошибка от сервера: $error');
      return null;
    }
  } catch (e) {
    print("Ошибка во время выполнения запроса");
    return null;
  }
}