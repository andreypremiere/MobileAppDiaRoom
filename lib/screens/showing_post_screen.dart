import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';

import '../components/post_component.dart';
import '../configuration/urls.dart';
import '../utils/utils.dart';
import '../models/canvas.dart' as canvCust;

class ShowingPostScreen extends StatefulWidget {
  const ShowingPostScreen({super.key});

  @override
  State<ShowingPostScreen> createState() {
    return _StateShowingPostScreen();
  }
}

class _StateShowingPostScreen extends State<ShowingPostScreen> {
  final testCanvas = canvCust.Canvas(
    id: "canvas_id",
    payload: [
      {
        "text":
            "Привет! Это мой новый концепт для MASTERio. Оцените освещение на рендере ниже! 🎨",
      },
      {
        "photo":
            "https://img.freepik.com/free-photo/vividly-colored-hummingbird-nature_23-2151495435.jpg?semt=ais_hybrid&w=740&q=80",
      }, // Абстрактный арт
      {
        "text":
            "Кстати, я использовал Blender для моделирования и Octane для финального прохода. Весь процесс занял около 12 часов.",
      },
      {
        "video":
            "https://rutube.ru/video/0d18fd147b83c840d0c8a67be4b5b21c/?r=wd",
      },
      {"text": "Скоро выложу туториал по этому проекту. Не переключайтесь! 🚀"},
      {
        "text":
        "Привет! Это мой новый концепт для MASTERio. Оцените освещение на рендере ниже! 🎨",
      },
      {
        "photo":
        "https://img.freepik.com/free-photo/vividly-colored-hummingbird-nature_23-2151495435.jpg?semt=ais_hybrid&w=740&q=80",
      }, // Абстрактный арт
      {
        "text":
        "Кстати, я использовал Blender для моделирования и Octane для финального прохода. Весь процесс занял около 12 часов.",
      },
      {
        "video":
        "https://rutube.ru/video/0d18fd147b83c840d0c8a67be4b5b21c/?r=wd",
      },
      {"text": "Скоро выложу туториал по этому проекту. Не переключайтесь! 🚀"},
    ],
  );
  String? avatarUrl;

  Widget _buildCanvasElement(String key, dynamic value) {
    // Общие отступы для всех блоков
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: _getWidgetByType(key, value.toString()),
    );
  }

  Widget _getWidgetByType(String type, String content) {
    switch (type) {
      case 'text':
        return Text(
          content,
          style: const TextStyle(
            fontSize: 16,
            fontFamily: 'SNPro',
            height: 1.4, // Межстрочный интервал для читаемости
            color: Color(0xFF1A1A1A),
          ),
        );

      case 'photo':
        return ClipRRect(
          borderRadius: BorderRadius.circular(16),
          child: Image.network(
            content,
            fit: BoxFit.cover,
            // Пока фото грузится, показываем серый прямоугольник
            loadingBuilder: (context, child, loadingProgress) {
              if (loadingProgress == null) return child;
              return Container(
                height: 200,
                decoration: BoxDecoration(
                  color: Colors.white.withAlpha(100),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: const Center(child: CircularProgressIndicator(strokeWidth: 2)),
              );
            },
          ),
        );

      case 'video':
        return Container(
          height: 220,
          width: double.infinity,
          decoration: BoxDecoration(
            color: Colors.black,
            borderRadius: BorderRadius.circular(16),
            gradient: const LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                Color(0xFFB2B2B2), // Темно-серый
                Color(0xFF4F1F1F), // Почти черный
              ],
            ),
          ),
          child: const Center(
            child: Icon(Icons.play_circle_outline, size: 60, color: Colors.white),
          ),
        );

      default:
        return const SizedBox.shrink();
    }
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => FocusScope.of(context).unfocus(),
      child: Scaffold(
        backgroundColor: Color(0xFFFFFFFF),
        appBar: AppBar(
          surfaceTintColor: Color(0xFFB9B9B9),
          centerTitle: true,
          title: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              CircleAvatar(
                radius: 16,
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
              Text(
                'Room name',
                style: TextStyle(
                  fontFamily: 'SNPro',
                  fontSize: 20,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
          backgroundColor: Color(0xFFB9B9B9),
          // backgroundColor: Colors.transparent.withAlpha(0),
          leading: IconButton(
            onPressed: () {},
            icon: SvgPicture.asset(
              'assets/icons/button_back.svg',
              width: 30,
              height: 30,
            ),
          ),
        ),
        body: SingleChildScrollView(
          child: Container(
            width: double.infinity,
            child: Column(
              mainAxisSize: MainAxisSize.max,
              spacing: 10,
              children: [
                for (var element in testCanvas.payload) ...[
                  _buildCanvasElement(element.keys.first, element.values.first),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
}
