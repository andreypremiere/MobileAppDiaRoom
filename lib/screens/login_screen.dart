import 'package:dia_room/api/account_api.dart';
import 'package:dia_room/components/info_dialog_component.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

// Login представляет экран входа пользователя в систему
class Login extends StatefulWidget {
  const Login({super.key});

  @override
  State<Login> createState() {
    return _LoginState();
  }
}

class _LoginState extends State<Login> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  bool _obscurePassword = true;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void _handleLogin() async {
    final email = _emailController.text.trim();
    final password = _passwordController.text;

    if (email.isEmpty) {
      AppInfoDialog.show(context, "Email пустой :(. Заполните поле.");
      return;
    }
    if (password.isEmpty) {
      AppInfoDialog.show(context, "Пароль пустой :(. Заполните поле.");
      return;
    }

    final response = await requestLogin(email, password);

    if (response.success && response.data != null) {
      final String userId = response.data!['userId'].toString();

      if (mounted) {
        context.go(
          Uri(
            path: '/verifyCode/$userId',
            queryParameters: {'email': email},
          ).toString(),
        );
      }
    } else {
      // Если success == false, показываем сообщение об ошибке из бэкенда
      AppInfoDialog.show(context, response.message ?? "Ошибка входа");
    }
  }

  @override
  Widget build(BuildContext context) {
    // GestureDetector используется для скрытия клавиатуры при нажатии на пустую область
    return GestureDetector(
      onTap: () {
        FocusScopeNode currentFocus = FocusScope.of(context);
        if (!currentFocus.hasPrimaryFocus) {
          currentFocus.unfocus();
        }
      },
      child: Scaffold(
        // Невидимый AppBar для корректного отображения системного статус-бара
        appBar: PreferredSize(
          preferredSize: const Size.fromHeight(0.0),
          child: AppBar(),
        ),
        body: Stack(
          children: [
            // Кнопка перехода к регистрации в верхнем углу
            Positioned(
              top: 10,
              right: 10,
              child: ElevatedButton(
                onPressed: () {
                  context.push('/registration');
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.white,
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                child: const Text(
                  'Регистрация',
                  style: TextStyle(
                    fontFamily: 'SNPro',
                    fontWeight: FontWeight.w500,
                    fontSize: 16,
                    color: Colors.black,
                  ),
                ),
              ),
            ),
            // Центрированная форма входа
            Center(
              child: Container(
                margin: const EdgeInsets.symmetric(horizontal: 10),
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(18),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withAlpha(10),
                      blurRadius: 18,
                      offset: const Offset(0, 0),
                    ),
                  ],
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Text(
                      "Вход",
                      style: TextStyle(
                        fontFamily: "SNPro",
                        fontSize: 22,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 10),
                    // Поле ввода идентификатора пользователя
                    TextField(
                      controller: _emailController,
                      decoration: InputDecoration(
                        hintText: "Email",
                        filled: true,
                        fillColor: const Color(0xFFF3F3F3),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                          borderSide: BorderSide.none,
                        ),
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 8,
                        ),
                      ),
                      cursorColor: const Color(0xFF000000),
                    ),
                    const SizedBox(height: 10),
                    TextField(
                      controller: _passwordController,
                      obscureText: _obscurePassword,
                      decoration: InputDecoration(
                        hintText: "Пароль",
                        filled: true,
                        fillColor: const Color(0xFFF3F3F3),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                          borderSide: BorderSide.none,
                        ),
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 8,
                        ),
                        suffixIcon: IconButton(
                          icon: Icon(
                            _obscurePassword ? Icons.visibility_off : Icons.visibility,
                            color: Colors.grey,
                            size: 20,
                          ),
                          onPressed: () {
                            setState(() {
                              _obscurePassword = !_obscurePassword;
                            });}
                        ),
                      ),
                      cursorColor: const Color(0xFF000000),
                    ),
                    const SizedBox(height: 10),
                    // Кнопка подтверждения входа
                    ElevatedButton(
                      onPressed: () {
                        _handleLogin();
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF990000),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(
                            12,
                          ), // Скругление углов
                        ),
                      ),
                      child: const Text(
                        "Войти",
                        style: TextStyle(
                          fontFamily: "SNPro",
                          fontSize: 18,
                          fontWeight: FontWeight.w600,
                          color: Colors.white,
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
}
