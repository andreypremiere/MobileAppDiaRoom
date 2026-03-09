import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:go_router/go_router.dart';

import '../components/post_component.dart';
import '../configuration/urls.dart';
import '../utils/utils.dart';

// PersonalPostsScreen отображает список постов конкретной комнаты
class PersonalPostsScreen extends StatefulWidget {
  const PersonalPostsScreen({super.key});

  @override
  State<PersonalPostsScreen> createState() {
    return _StatePersonalPostsScreen();
  }
}

class _StatePersonalPostsScreen extends State<PersonalPostsScreen> {
  // Данные для тестов
  String? avatarUrl;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      // Убираем фокус с полей ввода при нажатии на свободную область
      onTap: () => FocusScope.of(context).unfocus(),
      child: Scaffold(
        appBar: AppBar(
          centerTitle: true,
          // Заголовок AppBar с аватаром и названием комнаты в центре
          title: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              CircleAvatar(
                radius: 16,
                // Проверка: загружать кастомный аватар из хранилища или дефолтный
                backgroundImage: (avatarUrl != null && avatarUrl!.isNotEmpty)
                    ? NetworkImage(
                        createFullPathAvatar(objectStoragePath, avatarUrl!),
                      )
                    : NetworkImage(
                        createFullPathAvatar(
                          objectStoragePath,
                          defaultAvatarPath,
                        ),
                      ),
              ),
              const SizedBox(width: 10),
              const Text(
                'Room name',
                style: TextStyle(
                  fontFamily: 'SNPro',
                  fontSize: 20,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
          // Установка прозрачного фона для AppBar (использование withAlpha для плавности)
          backgroundColor: const Color(0xFFFFA6A6).withAlpha(0),
          // Кастомная кнопка "Назад" с использованием SVG
          leading: IconButton(
            onPressed: () {
              context.pop();
            },
            icon: SvgPicture.asset(
              'assets/icons/button_back.svg',
              width: 30,
              height: 30,
            ),
          ),
        ),
        // Прокручиваемая колонка с постами
        body: SingleChildScrollView(
          child: Column(
            // Автоматические отступы между элементами списка
            spacing: 10,
            children: const [
              PostComponent(),
              PostComponent(),
              PostComponent(),
              PostComponent(),
            ],
          ),
        ),
      ),
    );
  }
}
