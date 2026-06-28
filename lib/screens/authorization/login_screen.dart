import 'package:dia_room/api/account_api.dart';
import 'package:dia_room/components/info_dialog_component.dart';
import 'package:dia_room/utils/app_theme.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../components/general/app_text_field.dart';
import '../../components/auth_screens/auth_button.dart';
import '../../components/auth_screens/auth_form_container.dart';
import '../../components/general/keyboard_dismissible.dart';


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
      await AppInfoDialog.show(context, "Email не может быть пустым.");
      return;
    }
    if (password.isEmpty) {
      await AppInfoDialog.show(context, "Пароль не может быть пустым.");
      return;
    }

    final response = await requestLogin(email, password);

    if (response.success && response.data != null) {
      final String userId = response.data!['userId'].toString();

      if (mounted) {
        context.push(
          Uri(
            path: '/verifyCode/$userId',
            queryParameters: {'email': email},
          ).toString(),
        );
      } else {
        return;
      }
    } else {
      if (mounted) {
        await AppInfoDialog.show(context, "${response.message}.");
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
            Positioned(
              top: 10,
              right: 10,
              child: ElevatedButton(
                onPressed: () {
                  context.push('/registration');
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: context.ui.buttonColorSecondary,
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                child: Text(
                  'Регистрация',
                  style: TextStyle(
                    fontWeight: FontWeight.w500,
                    fontSize: 16,
                    color: context.ui.fontColorPrimary,
                  ),
                ),
              ),
            ),
            Center(
              child: AuthFormContainer(
                padding: const EdgeInsets.all(14),
                borderRadius: 18,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      "Вход",
                      style: TextStyle(
                        fontSize: context.ui.fontSizeTitle,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 10),
                    AppTextField(controller: _emailController, hint: "Email"),
                    const SizedBox(height: 10),
                    AppTextField(
                      controller: _passwordController,
                      hint: "Пароль",
                      isPassword: true,
                      obscureText: _obscurePassword,
                      onVisibilityToggle: () => setState(() => _obscurePassword = !_obscurePassword),
                    ),
                    const SizedBox(height: 10),
                    AuthButton(
                      text: "Войти",
                      backgroundColor: context.ui.primaryColor,
                      onPressed: _handleLogin,
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
