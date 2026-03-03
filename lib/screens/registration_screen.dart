import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:go_router/go_router.dart';
import 'package:http/http.dart' as http;

class Registration extends StatefulWidget {
  const Registration({super.key});

  @override
  State<Registration> createState() => _RegistrationState();
}

class _RegistrationState extends State<Registration> {
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _roomIdController = TextEditingController();
  final TextEditingController _roomNameController = TextEditingController();

  @override
  void dispose() {
    _phoneController.dispose();
    _roomIdController.dispose();
    _roomNameController.dispose();
    super.dispose();
  }

  Future<void> _sendRegistrationData() async {
    // 1. Укажи адрес своего сервера (если используешь adb reverse, то localhost)
    final url = Uri.parse('http://192.168.0.101:8081/newUser');

    try {
      // 2. Формируем тело запроса
      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'numberPhone': _phoneController.text,
          'roomId': _roomIdController.text,
          'roomName': _roomNameController.text,
        }),
      );

      // 3. Проверяем ответ сервера
      if (response.statusCode == 200 || response.statusCode == 201) {
        final Map<String, dynamic> body = jsonDecode(response.body);
        final String userId = body['id'];
        if (mounted) {
          context.push('/verifyCode', extra: userId);
        }
      } else {
        print("Ошибка сервера: ${response.statusCode}");
        // Тут можно показать пользователю SnackBar с ошибкой
      }
    } catch (e) {
      print("Ошибка сети: $e");
    }
  }

  void _handleRegistration() {
    print("Телефон: ${_phoneController.text}");
    print("ID комнаты: ${_roomIdController.text}");
    print("Имя комнаты: ${_roomNameController.text}");

    _sendRegistrationData();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => FocusScope.of(context).unfocus(),
      child: Scaffold(
        backgroundColor: Theme.of(context).colorScheme.surface,
        appBar: AppBar(toolbarHeight: 0, elevation: 0, backgroundColor: Colors.transparent),
        body: Stack(
          children: [
            // Кнопка назад
            Positioned(
              top: 10,
              left: 10,
              child: IconButton(
                onPressed: () => context.pop(),
                icon: SvgPicture.asset(
                  'assets/icons/button_back.svg',
                  width: 30,
                  height: 30,
                ),
              ),
            ),

            // Политика конфиденциальности
            Positioned(
              bottom: 20,
              left: 0,
              right: 0,
              child: Center(
                child: GestureDetector(
                  onTap: () => print("Открыть политику"),
                  child: const Text(
                    "Политика конфиденциальности",
                    style: TextStyle(
                      color: Colors.grey,
                      fontSize: 12,
                      decoration: TextDecoration.underline,
                    ),
                  ),
                ),
              ),
            ),

            // Основная карточка
            Center(
              child: Container(
                margin: const EdgeInsets.symmetric(horizontal: 20),
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.05),
                      blurRadius: 20,
                      offset: const Offset(0, 4),
                    )
                  ],
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Text(
                      "Регистрация",
                      style: TextStyle(
                        fontSize: 22,
                        fontFamily: "SNPro",
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 20),

                    // Поле Телефона
                    _buildTextField(
                      controller: _phoneController,
                      hint: "Номер телефона",
                      keyboardType: TextInputType.phone,
                    ),
                    const SizedBox(height: 10),

                    // Поле ID
                    _buildTextField(
                      controller: _roomIdController,
                      hint: "Уникальный ID комнаты",
                    ),
                    const SizedBox(height: 10),

                    // Поле Наименования
                    _buildTextField(
                      controller: _roomNameController,
                      hint: "Наименование комнаты",
                    ),
                    const SizedBox(height: 20),

                    // Кнопка регистрации
                    SizedBox(
                      width: double.infinity, // Кнопка на всю ширину карточки
                      height: 50,
                      child: ElevatedButton(
                        onPressed: _handleRegistration,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF990000),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                          elevation: 0,
                        ),
                        child: const Text(
                          "Регистрация",
                          style: TextStyle(
                            fontFamily: "SNPro",
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    )
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Вспомогательный метод для создания однотипных полей
  Widget _buildTextField({
    required TextEditingController controller,
    required String hint,
    TextInputType keyboardType = TextInputType.text,
  }) {
    return TextField(
      controller: controller,
      keyboardType: keyboardType,
      cursorColor: Colors.black,
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: const TextStyle(fontSize: 14, color: Colors.grey),
        filled: true,
        fillColor: const Color(0xFFF3F3F3),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide.none,
        ),
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      ),
    );
  }
}

