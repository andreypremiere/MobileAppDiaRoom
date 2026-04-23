import 'package:cached_network_image/cached_network_image.dart';
import 'package:dia_room/utils/app_theme.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

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
              CachedNetworkImage(
                imageUrl: avatarUrl ?? '',
                imageBuilder: (context, imageProvider) => CircleAvatar(
                  radius: 18,
                  backgroundImage: imageProvider,
                ),
                placeholder: (context, url) => CircleAvatar(
                  radius: 18,
                  backgroundColor: context.ui.primaryColor,
                ),
                errorWidget: (context, url, error) => CircleAvatar(
                  radius: 18,
                  backgroundColor: context.ui.primaryColor,
                  child: Icon(Icons.person, color: Colors.white, size: 20),
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
          actions: [
            Padding(padding: EdgeInsets.only(right: 0),
                child: IconButton(onPressed: () {
                  print('Переход в черновики');
                }, icon: Icon(Icons.folder_copy_outlined,
                  size: 30,
                  color: Color(0xFF1F1F1F),))),
            // SizedBox(width: 2,),
            Padding(padding: EdgeInsets.only(right: 4),
            child: IconButton(onPressed: () {
              context.push('/newPublicPost');
            }, icon: Icon(Icons.add,
            size: 34,
            color: Color(0xFF1F1F1F),))),
          ],
          // Установка прозрачного фона для AppBar (использование withAlpha для плавности)
          backgroundColor: const Color(0xFFFFA6A6).withAlpha(0),
          // Кастомная кнопка "Назад" с использованием SVG
          leading: IconButton(
            onPressed: () {
              context.pop();
            },
            icon: Icon(Icons.arrow_back_rounded, size: 34,
              color: Color(0xFF1F1F1F),)
          ),
        ),
        // Прокручиваемая колонка с постами
        body: SingleChildScrollView(
          child: Column(
            // Автоматические отступы между элементами списка
            spacing: 10,
            children: const [
              // PostComponent(),
              // PostComponent(),
              // PostComponent(),
              // PostComponent(),
            ],
          ),
        ),
      ),
    );
  }
}
