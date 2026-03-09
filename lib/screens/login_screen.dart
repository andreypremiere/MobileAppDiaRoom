import 'package:dia_room/api/user_api.dart';
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
  // Контроллер для извлечения текста из поля ввода (id или телефон)
  final TextEditingController _valueController = TextEditingController();

  @override
  void dispose() {
    // Обязательное освобождение ресурсов контроллера при закрытии экрана
    _valueController.dispose();
    super.dispose();
  }

  // _handleLogin вызывает API входа и перенаправляет на верификацию
  void _handleLogin() async {
    // Вызов функции запроса из папки api
    String? userId = await requestLogin(_valueController.text);

    if (userId != null) {
      // Проверка mounted гарантирует, что контекст еще существует после await
      if (mounted) {
        // Переход на экран ввода кода с передачей userId через extra
        context.go('/verifyCode', extra: userId.toString());
      }
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
                margin: const EdgeInsets.symmetric(horizontal: 14),
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
                      "Войти",
                      style: TextStyle(
                        fontFamily: "SNPro",
                        fontSize: 22,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 10),
                    // Поле ввода идентификатора пользователя
                    TextField(
                      controller: _valueController,
                      decoration: InputDecoration(
                        hintText: "user_id или номер телефона",
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
                    // Кнопка подтверждения входа
                    ElevatedButton(
                      onPressed: () {
                        _handleLogin();
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF990000),
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
