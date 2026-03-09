import 'package:dia_room/api/user_api.dart';
import 'package:dia_room/models/user.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../utils/auth_service.dart';

// VerifyCode — экран подтверждения входа/регистрации через SMS-код
class VerifyCode extends StatefulWidget {
  final String userId; // ID пользователя, полученный на предыдущем шаге

  const VerifyCode({super.key, required this.userId});

  @override
  State<VerifyCode> createState() {
    return _VerifyCodeState();
  }
}

class _VerifyCodeState extends State<VerifyCode> {
  // Контроллер для захвата введенного кода
  final TextEditingController _codeController = TextEditingController();

  @override
  void dispose() {
    // Освобождаем ресурсы контроллера
    _codeController.dispose();
    super.dispose();
  }

  // _handleSendCode отправляет код на проверку и авторизует пользователя
  void _handleSendCode() async {
    // Запрос к API для верификации пары userId + code
    User? user = await requestVerifyCode(widget.userId, _codeController.text);

    if (user != null) {
      if (mounted) {
        // Если код верный, сохраняем объект User в провайдере (авторизуем сессию)
        context.read<AuthProvider>().login(user);
        print('Переход на главную страницу, а также передача объекта User');
      }
    } else {
      // Здесь можно добавить показ SnackBar с ошибкой
      print('Ошибка верификации кода');
    }
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      // Убираем фокус (скрываем клавиатуру) при нажатии вне поля ввода
      onTap: () {
        FocusScopeNode currentFocus = FocusScope.of(context);
        if (!currentFocus.hasPrimaryFocus) {
          currentFocus.unfocus();
        }
      },
      child: Scaffold(
        appBar: PreferredSize(
          preferredSize: const Size.fromHeight(0.0),
          child: AppBar(),
        ),
        body: Stack(
          children: [
            Center(
              child: Container(
                margin: const EdgeInsets.symmetric(horizontal: 10),
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
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
                    // Отладочная информация (удалить перед релизом)
                    Text(widget.userId),

                    const Text(
                      "Введите код",
                      style: TextStyle(
                        fontSize: 22,
                        fontFamily: "SNPro",
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const Text(
                      "Код отправлен на ваш номер телефона",
                      style: TextStyle(
                        fontSize: 14,
                        fontFamily: "SNPro",
                        fontWeight: FontWeight.w400,
                      ),
                    ),
                    const SizedBox(height: 10),
                    // Поле ввода кода с жесткой валидацией формата
                    TextField(
                      controller: _codeController,
                      textAlign: TextAlign.center,
                      decoration: InputDecoration(
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
                      keyboardType: TextInputType.number,
                      // Цифровая клавиатура
                      maxLength: 6,
                      // Лимит на длину кода
                      inputFormatters: [
                        // Разрешаем ввод только цифр, предотвращаем вставку спецсимволов
                        FilteringTextInputFormatter.digitsOnly,
                      ],
                    ),
                    ElevatedButton(
                      onPressed: () {
                        _handleSendCode();
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF990000),
                      ),
                      child: const Text(
                        "Отправить",
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
