import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:go_router/go_router.dart';

import '../components/post_component.dart';
import '../configuration/urls.dart';
import '../utils/utils.dart';
import '../models/canvas.dart' as canvCust;

// ShowingPostScreen — экран для детального просмотра контента поста
class ShowingPostScreen extends StatefulWidget {
  const ShowingPostScreen({super.key});

  @override
  State<ShowingPostScreen> createState() {
    return _StateShowingPostScreen();
  }
}

class _StateShowingPostScreen extends State<ShowingPostScreen> {
  // Тестовые данные для холста (Canvas). Эмулируют структуру, приходящую с бэкенда.
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
      },
      {
        "text":
            "Кстати, я использовал Blender для моделирования и Octane для финального прохода.",
      },
      {
        "video":
            "https://rutube.ru/video/0d18fd147b83c840d0c8a67be4b5b21c/?r=wd",
      },
      {"text": "Скоро выложу туториал по этому проекту. Не переключайтесь! 🚀"},
    ],
  );

  String? avatarUrl;

  // _buildCanvasElement оборачивает каждый блок контента в стандартные отступы
  Widget _buildCanvasElement(String key, dynamic value) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: _getWidgetByType(key, value.toString()),
    );
  }

  // _getWidgetByType определяет, какой виджет отрисовать в зависимости от типа данных (text/photo/video)
  Widget _getWidgetByType(String type, String content) {
    switch (type) {
      case 'text':
        return Text(
          content,
          style: const TextStyle(
            fontSize: 16,
            fontFamily: 'SNPro',
            height: 1.4,
            // Межстрочный интервал для лучшей читаемости длинных текстов
            color: Color(0xFF1A1A1A),
          ),
        );

      case 'photo':
        return ClipRRect(
          borderRadius: BorderRadius.circular(16),
          child: Image.network(
            content,
            fit: BoxFit.cover,
            // Обработка состояния загрузки изображения
            loadingBuilder: (context, child, loadingProgress) {
              if (loadingProgress == null) return child;
              return Container(
                height: 200,
                decoration: BoxDecoration(
                  color: Colors.white.withAlpha(100),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: const Center(
                  child: CircularProgressIndicator(strokeWidth: 2),
                ),
              );
            },
          ),
        );

      case 'video':
        // Заглушка для видео-плеера с градиентным фоном и иконкой Play
        return Container(
          height: 220,
          width: double.infinity,
          decoration: BoxDecoration(
            color: Colors.black,
            borderRadius: BorderRadius.circular(16),
            gradient: const LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [Color(0xFFB2B2B2), Color(0xFF4F1F1F)],
            ),
          ),
          child: const Center(
            child: Icon(
              Icons.play_circle_outline,
              size: 60,
              color: Colors.white,
            ),
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
        backgroundColor: const Color(0xFFFFFFFF),
        appBar: AppBar(
          surfaceTintColor: const Color(0xFFB9B9B9),
          centerTitle: true,
          title: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Аватар автора поста в шапке
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
          backgroundColor: const Color(0xFFB9B9B9),
          leading: IconButton(
            onPressed: () => context.pop(),
            icon: SvgPicture.asset(
              'assets/icons/button_back.svg',
              width: 30,
              height: 30,
            ),
          ),
        ),
        // Построение ленты контента на основе payload холста
        body: SingleChildScrollView(
          child: SizedBox(
            width: double.infinity,
            child: Column(
              mainAxisSize: MainAxisSize.max,
              spacing: 10, // Современный способ задания отступов между блоками
              children: [
                // Итерация по элементам холста и их динамическая отрисовка
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
