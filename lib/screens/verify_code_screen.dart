import 'package:dia_room/api/account_api.dart';
import 'package:dia_room/components/info_dialog_component.dart';
import 'package:dia_room/models/user.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'dart:async';

import '../utils/auth_service.dart';

// VerifyCode — экран подтверждения входа/регистрации через SMS-код
class VerifyCode extends StatefulWidget {
  final String userId;
  final String email;

  const VerifyCode({super.key, required this.userId, required this.email});

  @override
  State<VerifyCode> createState() {
    return _VerifyCodeState();
  }
}

class _VerifyCodeState extends State<VerifyCode> {
  final TextEditingController _codeController = TextEditingController();

  Timer? _timer;
  int _startSeconds = 130;
  bool _canResend = false;

  @override
  void initState() {
    super.initState();
    _startTimer();
  }

  // Запуск обратного отсчета
  void _startTimer() {
    setState(() {
      _startSeconds = 130;
      _canResend = false;
    });
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_startSeconds == 0) {
        setState(() {
          _timer?.cancel();
          _canResend = true;
        });
      } else {
        setState(() {
          _startSeconds--;
        });
      }
    });
  }

  // Форматирование секунд в вид 02:10
  String _formatTime(int seconds) {
    int minutes = seconds ~/ 60;
    int remainingSeconds = seconds % 60;
    return '${minutes.toString().padLeft(2, '0')}:${remainingSeconds.toString().padLeft(2, '0')}';
  }

  @override
  void dispose() {
    _timer?.cancel(); // Важно отменить таймер при выходе
    _codeController.dispose();
    super.dispose();
  }

  void _handleResendCode() {
    if (!_canResend) return;
    print("Повторная отправка кода на ${widget.email}");
    // Здесь вызывай свой метод API для переотправки
    _startTimer(); // Перезапускаем таймер
  }

  void _handleWrongEmail() {
    // context.go('/registration');
    print("Возврат на специальное окно");
  }

  // _handleSendCode отправляет код на проверку и авторизует пользователя
  void _handleSendCode() async {
    final code = _codeController.text;
    if (code.isEmpty) {
      AppInfoDialog.show(context, "Поле кода не должно быть пустым :(");
      return;
    }
    if (code.length != 6) {
      AppInfoDialog.show(context, "Код должен быть шестизначный :(");
      return;
    }

    final response = await requestVerifyCode(widget.userId, code);

    if (response.success && response.data != null) {
      if (mounted) {
        final String access = response.data!['accessToken'];
        final String refresh = response.data!['refreshToken'];
        final bool configured = response.data!['isConfigured'] ?? false;

        context.read<AuthProvider>().login(access, refresh, configured);

        print('Авторизация успешна. Токены сохранены.');
      }
    } else {
      AppInfoDialog.show(context, response.message ?? "Неверный код");
    }
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
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
        body: Center(
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // ОСНОВНОЙ БЕЛЫЙ КОНТЕЙНЕР
                Container(
                  margin: const EdgeInsets.symmetric(horizontal: 10),
                  padding: const EdgeInsets.all(20),
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
                      const Text(
                        "Код отправлен на",
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 16,
                          fontFamily: "SNPro",
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      Text(
                        widget.email,
                        style: const TextStyle(
                          fontSize: 16,
                          fontFamily: "SNPro",
                          fontWeight: FontWeight.w600,
                          color: Color(0xFF990000),
                        ),
                      ),
                      const SizedBox(height: 15),
                      TextField(
                        controller: _codeController,
                        textAlign: TextAlign.center,
                        decoration: InputDecoration(
                          hintText: "Введите код",
                          counterText: "",
                          filled: true,
                          fillColor: const Color(0xFFF3F3F3),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                            borderSide: BorderSide.none,
                          ),
                          contentPadding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 12,
                          ),
                        ),
                        cursorColor: const Color(0xFF000000),
                        keyboardType: TextInputType.number,
                        maxLength: 6,
                        inputFormatters: [
                          FilteringTextInputFormatter.digitsOnly,
                        ],
                      ),
                      const SizedBox(height: 15),
                      if (!_canResend)
                        Text(
                          "Отправить код еще раз через ${_formatTime(_startSeconds)}",
                          style: const TextStyle(
                            fontFamily: "SNPro",
                            fontSize: 14,
                            color: Colors.grey,
                          ),
                        )
                      else
                        TextButton(
                          onPressed: _handleResendCode,
                          style: TextButton.styleFrom(
                            padding: EdgeInsets.zero,
                            // Убираем внутренние отступы
                            minimumSize: Size.zero,
                            // Убираем минимальный размер
                            tapTargetSize: MaterialTapTargetSize
                                .shrinkWrap, // Схлопываем область нажатия до размера текста
                          ),
                          child: const Text(
                            "Отправить код еще раз",
                            style: TextStyle(
                              fontFamily: "SNPro",
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                              color: Color(0xFF111111),
                            ),
                          ),
                        ),
                      const SizedBox(height: 15),
                      ElevatedButton(
                        onPressed: _handleSendCode,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF990000),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(
                              12,
                            ), // Скругление углов
                          ),
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

                // ТЕКСТ ПОД КОНТЕЙНЕРОМ
                const SizedBox(height: 20),
                GestureDetector(
                  onTap: _handleWrongEmail,
                  child: const Text(
                    "Указал неверный адрес почты",
                    style: TextStyle(
                      fontFamily: "SNPro",
                      fontSize: 15,
                      decoration: TextDecoration.underline,
                      color: Color(0xFF656565),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
