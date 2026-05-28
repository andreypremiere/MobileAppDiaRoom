import 'package:dia_room/api/account_api.dart';
import 'package:dia_room/components/info_dialog_component.dart';
import 'package:dia_room/utils/app_theme.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'dart:async';

import '../../components/general/app_back_button.dart';
import '../../components/general/app_text_field.dart';

import '../../components/auth_screens/auth_button.dart';
import '../../components/auth_screens/auth_form_container.dart';
import '../../utils/auth_service.dart';

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
  int _startSeconds = 120;
  bool _canResend = false;

  @override
  void initState() {
    super.initState();
    _startTimer();
  }

  // Запуск обратного отсчета
  void _startTimer() {
    setState(() {
      _startSeconds = 120;
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

  Future<void> _handleResendCode() async {
    if (!_canResend) return;
    await requestRepeatCode(widget.userId);
    _startTimer();
  }

  // _handleSendCode отправляет код на проверку и авторизует пользователя
  void _handleSendCode() async {
    final code = _codeController.text.trim();
    if (code.isEmpty) {
      await AppInfoDialog.show(context, "Код не введен.");
      return;
    }
    if (code.length != 6) {
      await AppInfoDialog.show(context, "Код должен быть шестизначный.");
      return;
    }

    final response = await requestVerifyCode(widget.userId, code);

    if (response.success && response.data != null) {
      if (mounted) {
        final String access = response.data!['accessToken'];
        final String refresh = response.data!['refreshToken'];
        final bool configured = response.data!['isConfigured'] ?? false;

        context.read<AuthProvider>().login(access, refresh, configured);
        context.go('/');
      } else {
        return;
      }
    } else {
      if (mounted) {
        await AppInfoDialog.show(context, response.message ?? "Неверный код.");
      } else {
        return;
      }
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
        extendBody: true,
        extendBodyBehindAppBar: true,
        body:  SafeArea(child: Stack(
          children: [
          // Кнопка "Назад" в верхнем левом углу
          Positioned(
          top: 10,
          left: 10,
          child: const AppBackButton(),
        ), Center(
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // ОСНОВНОЙ БЕЛЫЙ КОНТЕЙНЕР
                AuthFormContainer(
                  padding: const EdgeInsets.all(14),
                  borderRadius: 18,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        "Код отправлен на",
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: context.ui.fontColorPrimary,
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      Text(
                        widget.email,
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: context.ui.primaryColor,
                        ),
                      ),
                      const SizedBox(height: 15),
                      AppTextField(
                        controller: _codeController,
                        hint: "Введите код",
                        textAlign: TextAlign.center,
                        keyboardType: TextInputType.number,
                        maxLength: 6,
                        inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                      ),
                      const SizedBox(height: 15),
                      if (!_canResend)
                        Text(
                          "Отправить код еще раз через ${_formatTime(_startSeconds)}",
                          style: TextStyle(
                            fontSize: 14,
                            color: context.ui.fontColorHint,
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
                          child: Text(
                            "Отправить код еще раз",
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                              color: context.ui.fontColorPrimary,
                            ),
                          ),
                        ),
                      const SizedBox(height: 15),
                      AuthButton(
                        text: "Проверить",
                        backgroundColor: context.ui.primaryColor,
                        onPressed: _handleSendCode,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),],),),
      ),
    );
  }
}
