import 'package:dia_room/components/info_dialog_component.dart';
import 'package:dia_room/utils/app_theme.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:dia_room/api/account_api.dart';
import '../../components/auth_screens/app_text_field.dart';
import '../../components/auth_screens/auth_button.dart';
import '../../components/auth_screens/auth_form_container.dart';
import '../../components/auth_screens/keyboard_dismissible.dart';

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
      if (mounted) {
        context.push(
          Uri(
            path: '/verifyCode/$userId',
            queryParameters: {'email': email},
          ).toString(),
        );
      } else {
        print("mounted is not true");
      }
    } else {
      if (mounted) {
        AppInfoDialog.show(context, "${response.message} :(");
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return KeyboardDismissible(
      child: Scaffold(
        extendBody: true,
        extendBodyBehindAppBar: true,
        body: SafeArea(child: Stack(
          children: [
            // Кнопка "Назад" в верхнем левом углу
            Positioned(
              top: 10,
              left: 10,
              child: IconButton(
                onPressed: () => context.pop(),
                icon: Icon(Icons.arrow_back_rounded,
                size: context.ui.iconSizePanel),
                color: context.ui.fontColorPrimary,
              ),
            ),

            // Ссылка на политику конфиденциальности внизу экрана
            Positioned(
              bottom: 20,
              left: 0,
              right: 0,
              child: Center(
                child: GestureDetector(
                  onTap: () => AppInfoDialog.show(context, "Пока что политики нет, но мы обязательно ее добавим!"),
                  child: Text(
                    "Политика конфиденциальности",
                    style: TextStyle(
                      color: context.ui.fontColorHint,
                      fontSize: 12,
                      decoration: TextDecoration.underline,
                    ),
                  ),
                ),
              ),
            ),

            // Центральная карточка с формой ввода
            Center(
              child: AuthFormContainer(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      "Регистрация",
                      style: TextStyle(
                        fontSize: context.ui.fontSizeTitle,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 20),

                    AppTextField(controller: _emailController, hint: "Email", keyboardType: TextInputType.emailAddress),
                    const SizedBox(height: 10),

                    AppTextField(
                      controller: _passwordController,
                      hint: "Пароль",
                      isPassword: true,
                      obscureText: _obscurePassword,
                      onVisibilityToggle: () => setState(() => _obscurePassword = !_obscurePassword),
                    ),
                    const SizedBox(height: 10),

                    AppTextField(
                      controller: _passwordAgainController,
                      hint: "Пароль повторно",
                      isPassword: true,
                      obscureText: _obscurePassword,
                      onVisibilityToggle: () => setState(() => _obscurePassword = !_obscurePassword),
                    ),
                    const SizedBox(height: 20),

                    // Кнопка отправки данных формы
                    AuthButton(
                      text: "Регистрация",
                      backgroundColor: context.ui.primaryColor,
                      onPressed: _handleRegistration,
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),),
      ),
    );
  }
}
