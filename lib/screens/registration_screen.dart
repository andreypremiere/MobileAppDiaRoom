import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:go_router/go_router.dart';
import 'package:dia_room/api/user_api.dart';
import 'package:http/http.dart' as http;

// Registration представляет экран создания нового аккаунта и комнаты
class Registration extends StatefulWidget {
  const Registration({super.key});

  @override
  State<Registration> createState() => _RegistrationState();
}

class _RegistrationState extends State<Registration> {
  // Контроллеры для управления вводом данных пользователя
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _roomIdController = TextEditingController();
  final TextEditingController _roomNameController = TextEditingController();

  @override
  void dispose() {
    // Освобождение ресурсов всех контроллеров при уничтожении виджета
    _phoneController.dispose();
    _roomIdController.dispose();
    _roomNameController.dispose();
    super.dispose();
  }

  // _handleRegistration собирает данные и отправляет запрос на бэкенд
  void _handleRegistration() async {
    // Вызов функции API для регистрации (описана в user_api.dart)
    final String? userId = await requestRegistration(
      _phoneController.text,
      _roomIdController.text,
      _roomNameController.text,
    );

    if (userId != null) {
      // Проверка на mounted предотвращает ошибки навигации, если экран уже закрыт
      if (mounted) {
        // Переход на экран ввода OTP-кода с передачей ID пользователя
        context.go('/verifyCode', extra: userId.toString());
      } else {
        print("mounted is not true");
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    // GestureDetector позволяет закрыть клавиатуру при тапе по пустому месту
    return GestureDetector(
      onTap: () => FocusScope.of(context).unfocus(),
      child: Scaffold(
        backgroundColor: Theme.of(context).colorScheme.surface,
        appBar: AppBar(
          toolbarHeight: 0,
          // Скрываем стандартный AppBar, оставляя только системную строку
          elevation: 0,
          backgroundColor: Colors.transparent,
        ),
        body: Stack(
          children: [
            // Кнопка "Назад" в верхнем левом углу
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

            // Ссылка на политику конфиденциальности внизу экрана
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

            // Центральная карточка с формой ввода
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
                    ),
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

                    // Поле для ввода номера телефона
                    _buildTextField(
                      controller: _phoneController,
                      hint: "Номер телефона",
                      keyboardType: TextInputType.phone,
                    ),
                    const SizedBox(height: 10),

                    // Поле для выбора уникального ID комнаты
                    _buildTextField(
                      controller: _roomIdController,
                      hint: "Уникальный ID комнаты",
                    ),
                    const SizedBox(height: 10),

                    // Поле для названия комнаты
                    _buildTextField(
                      controller: _roomNameController,
                      hint: "Наименование комнаты",
                    ),
                    const SizedBox(height: 20),

                    // Кнопка отправки данных формы
                    SizedBox(
                      width: double.infinity,
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
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // _buildTextField — вспомогательный метод для создания стилизованных полей ввода
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
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 14,
        ),
      ),
    );
  }
}
