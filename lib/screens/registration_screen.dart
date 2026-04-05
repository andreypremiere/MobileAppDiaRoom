import 'dart:convert';

import 'package:dia_room/components/info_dialog_component.dart';
import 'package:dia_room/utils/utils.dart';
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
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _passwordAgainController =
      TextEditingController();
  bool _obscurePassword = true;

  @override
  void dispose() {
    // Освобождение ресурсов всех контроллеров при уничтожении виджета
    _emailController.dispose();
    _passwordController.dispose();
    _passwordAgainController.dispose();
    super.dispose();
  }

  // _handleRegistration собирает данные и отправляет запрос на бэкенд
  void _handleRegistration() async {
    final email = _emailController.text.trim();
    final password = _passwordController.text;
    final passwordAgain = _passwordAgainController.text;

    if (email.isEmpty) {
      AppInfoDialog.show(context, "Поле email не должно быть пустым :(");
      return;
    }
    if (!RegExp(
      r"^[a-zA-Z0-9.a-zA-Z0-9.!#$%&'*+-/=?^_`{|}~]+@[a-zA-Z0-9]+\.[a-zA-Z]+",
    ).hasMatch(email)) {
      AppInfoDialog.show(context, "Введите корректный email адрес :(");
      return;
    }

    if (password.isEmpty) {
      AppInfoDialog.show(context, "Поле пароля не должно быть пустым:(");
      return;
    }

    if (passwordAgain.isEmpty) {
      AppInfoDialog.show(context, "Второе поле пароля не должно быть пустым:(");
      return;
    }

    if (password != passwordAgain) {
      AppInfoDialog.show(context, "Пароли должны совпадать :(");
      return;
    }

    final response = await requestRegistration(email, password);

    if (response.success) {
      String userId = response.data!['userId'];
      print("Полученный userId от сервера: $userId");
      // if (mounted) {
      //   // Переход на экран ввода OTP-кода с передачей ID пользователя
      //   context.go('/verifyCode', extra: userId);
      // } else {
      //   print("mounted is not true");
      // }
    }
    else {
      AppInfoDialog.show(context, "${response.message} :(");
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

                    _buildTextField(
                      controller: _emailController,
                      hint: "Email",
                      keyboardType: TextInputType.emailAddress,
                    ),
                    const SizedBox(height: 10),

                    // Поле Пароль (скрываемое)
                    _buildTextField(
                      controller: _passwordController,
                      hint: "Пароль",
                      isPassword: true,
                      obscureText: _obscurePassword,
                      onSuffixIconPressed: () {
                        setState(() {
                          _obscurePassword = !_obscurePassword;
                        });
                      },
                    ),
                    const SizedBox(height: 10),

                    // Поле Повтор пароля (скрываемое)
                    _buildTextField(
                      controller: _passwordAgainController,
                      hint: "Введите пароль повторно",
                      isPassword: true,
                      obscureText: _obscurePassword,
                      onSuffixIconPressed: () {
                        setState(() {
                          _obscurePassword = !_obscurePassword;
                        });
                      },
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

  Widget _buildTextField({
    required TextEditingController controller,
    required String hint,
    TextInputType keyboardType = TextInputType.text,
    bool isPassword = false, // По умолчанию это не пароль
    bool obscureText = false, // Скрывать ли текст (передаем из стейта)
    VoidCallback? onSuffixIconPressed, // Колбэк для иконки
  }) {
    return TextField(
      controller: controller,
      keyboardType: isPassword ? TextInputType.visiblePassword : keyboardType,
      obscureText: isPassword ? obscureText : false,
      cursorColor: Colors.black,
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: const TextStyle(fontSize: 14, color: Colors.grey),
        filled: true,
        fillColor: const Color(0xFFF3F3F3),

        // Добавляем иконку только если поле помечено как isPassword
        suffixIcon: isPassword
            ? IconButton(
                icon: Icon(
                  obscureText ? Icons.visibility_off : Icons.visibility,
                  color: Colors.grey,
                  size: 20,
                ),
                onPressed: onSuffixIconPressed,
              )
            : null,

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
