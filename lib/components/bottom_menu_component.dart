import 'package:dia_room/components/info_dialog_component.dart';
import 'package:dia_room/utils/auth_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../api/account_api.dart';

// BottomMenu представляет собой навигационную панель в нижней части экрана
class BottomMenu extends StatelessWidget {
  const BottomMenu({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      // Внутренние отступы для элементов меню
      padding: EdgeInsets.all(3),
      // Стилизация контейнера: белый фон и скругление углов
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(26),
        boxShadow: [
          BoxShadow(
            blurRadius: 10,
            color: Colors.black.withAlpha(30),
            spreadRadius: 4,
          ),
        ],
      ),
      // Фиксированная высота панели меню
      height: 52,
      child: Row(
        // Минимальный размер строки для центрирования кнопок
        mainAxisSize: MainAxisSize.min,
        children: [
          // Кнопка перехода в профиль пользователя
          IconButton(
            onPressed: () {
              final roomId = context.read<AuthProvider>().userId!;
              // Навигация на экран комнаты через GoRouter
              context.push('/room', extra: roomId);
            },
            icon: SvgPicture.asset(
              'assets/icons/profile.svg',
              width: 30,
              height: 30,
            ),
          ),
          // Кнопка раздела подписок/подписчиков (заглушка)
          IconButton(
            onPressed: () {},
            icon: SvgPicture.asset(
              'assets/icons/subs.svg',
              width: 30,
              height: 30,
            ),
          ),
          // Кнопка настроек
          IconButton(
            onPressed: () async {
              // Выполнить запрос выхода
              final result = await requestLogout(context);
              if (result == null) {
                context.read<AuthProvider>().logout();
              } else {
                if (result.success) {
                  context.read<AuthProvider>().logout();
                } else {
                  AppInfoDialog.show(context, "${result.message}");
                }
              }

            },
            icon: SvgPicture.asset(
              'assets/icons/settings.svg',
              width: 30,
              height: 30,
            ),
          ),
        ],
      ),
    );
  }
}
