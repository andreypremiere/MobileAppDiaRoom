import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:carousel_slider/carousel_slider.dart';

import '../../models/post_v2/post_response.dart';
// Убедись, что путь к твоим моделям верный
// import 'package:diaroom/models/post_models.dart';
// import 'package:share_plus/share_plus.dart'; // В будущем для шеринга

class PostCard extends StatefulWidget {
  final PostResponse post;

  const PostCard({super.key, required this.post});

  @override
  State<PostCard> createState() => _PostCardState();
}

class _PostCardState extends State<PostCard> {
  // Состояние для раскрытия описания
  bool _isDescriptionExpanded = false;

  // ЛОКАЛЬНОЕ Состояние лайка для UI (только чтобы показать, как работает вид)
  // В реальности логика установки лайка должна быть в BLoC/Provider
  late bool _isLiked;
  late int _likesCount;

  @override
  void initState() {
    super.initState();
    // Инициализируем локальное состояние данными с бэкенда
    _isLiked = widget.post.isLiked;
    _likesCount = widget.post.likesCount;
  }

  @override
  Widget build(BuildContext context) {
    // Константы стилей для счетчиков
    const TextStyle countStyle = TextStyle(
      fontSize: 14,
      color: Colors.grey,
      fontWeight: FontWeight.w600,
    );

    return Container(
      width: double.infinity,
      margin: const EdgeInsets.symmetric(vertical: 8), // Отступ между карточками
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16), // Скругленные края
        // Легкая тень для эффекта карточки
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            spreadRadius: 1,
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 1. Шапка поста (Аватар, имя, поделиться)
          _buildHeader(context),

          // 2. Карусель фотографий
          _buildMediaCarousel(),

          // 3. Панель статистики (Лайки, комментарии)
          _buildActionsBar(countStyle),

          // 4. Описание поста
          _buildDescription(),

          // 5. Кнопка WorkshopLink (если есть)
          if (widget.post.workshopLink != null) _buildWorkshopLink(context),

          // Отступ снизу карточки
          const SizedBox(height: 12),
        ],
      ),
    );
  }

  // --- Вспомогательные методы сборки UI ---

  Widget _buildHeader(BuildContext context) {
    final author = widget.post.roomInfo;
    return Padding(
      padding: const EdgeInsets.all(12.0),
      child: Row(
        children: [
          // Круглый аватар
          CircleAvatar(
            radius: 20,
            backgroundColor: Colors.grey[200],
            backgroundImage: author?.avatarUrl != null && author!.avatarUrl.isNotEmpty
                ? CachedNetworkImageProvider(author.avatarUrl)
                : null,
            child: author?.avatarUrl == null || author!.avatarUrl.isEmpty
                ? const Icon(Icons.person, color: Colors.grey)
                : null,
          ),
          const SizedBox(width: 10),
          // Имя комнаты
          Expanded(
            child: Text(
              author?.roomName ?? "Загрузка...",
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
              overflow: TextOverflow.ellipsis,
            ),
          ),
          // Иконка поделиться (заглушка)
          IconButton(
            onPressed: () {
              // Реализация шеринга через share_plus в будущем
              // Share.share('Посмотри пост в DiaRoom: https://diaroom.ru/rooms/${widget.post.roomId}/posts/${widget.post.id}');
              ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Поделиться (заглушка)")));
            },
            icon: const Icon(Icons.share_outlined, color: Colors.grey),
          ),
        ],
      ),
    );
  }

  Widget _buildMediaCarousel() {
    if (widget.post.files.isEmpty) return const SizedBox.shrink();

    // ВАЖНО: Определяем соотношение сторон по ПЕРВОЙ фотографии
    double ar = 1.0;
    if (widget.post.files.first.width > 0 && widget.post.files.first.height > 0) {
      ar = widget.post.files.first.width / widget.post.files.first.height;
    }

    return AspectRatio(
      aspectRatio: ar, // Контейнер карусели принимает размер первой фото
      child: Container(
        color: Colors.grey[100], // Фон, если фото BoxFit.contain не заполнит всё
        child: CarouselSlider(
          options: CarouselOptions(
            viewportFraction: 1.0, // Фото на всю ширину
            enableInfiniteScroll: widget.post.files.length > 1,
            aspectRatio: ar, // Соотношение сторон самой карусели
          ),
          items: widget.post.files.map((file) {
            return Builder(
              builder: (BuildContext context) {
                // Оптимизированная загрузка изображений
                return CachedNetworkImage(
                  imageUrl: file.urlMedium, // Основное изображение (Medium)
                  // ТРЕБОВАНИЕ: Вся влезла, не деформировалась -> BoxFit.contain
                  fit: BoxFit.contain,
                  width: double.infinity,
                  // Оптимизация: пока грузится Medium, показываем Small
                  placeholder: (context, url) => CachedNetworkImage(
                    imageUrl: file.urlSmall, // Предзагрузка Small
                    fit: BoxFit.contain,
                  ),
                  errorWidget: (context, url, error) => const Icon(Icons.error_outline, size: 40),
                );
              },
            );
          }).toList(),
        ),
      ),
    );
  }

  Widget _buildActionsBar(TextStyle countStyle) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 4.0, vertical: 4.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // Слева: Комментарии
          Row(
            children: [
              IconButton(
                onPressed: () {
                  // Переход к комментариям
                },
                icon: const Icon(Icons.mode_comment_outlined, color: Colors.grey),
              ),
              Text('${widget.post.commentsCount}', style: countStyle),
            ],
          ),
          // Справа: Лайки
          Row(
            children: [
              Text('$_likesCount', style: countStyle),
              IconButton(
                onPressed: () {
                  // ЛОГИКА ТОЛЬКО ДЛЯ UI. В реальности вызов BLoC.
                  setState(() {
                    if (_isLiked) {
                      _likesCount--;
                    } else {
                      _likesCount++;
                    }
                    _isLiked = !_isLiked;
                  });
                },
                icon: Icon(
                  _isLiked ? Icons.favorite : Icons.favorite_border,
                  color: _isLiked ? Colors.red : Colors.grey,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildDescription() {
    final description = widget.post.description;
    if (description == null || description.isEmpty) return const SizedBox.shrink();

    // Логика обрезки текста
    bool isTooLong = description.length > 100;
    String textToDisplay = description;

    if (isTooLong && !_isDescriptionExpanded) {
      // Показываем первые 100 символов + троеточие
      textToDisplay = "${description.substring(0, 100)}...";
    }

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          RichText(
            text: TextSpan(
              style: const TextStyle(
                color: Colors.black87,
                fontSize: 14,
                height: 1.4, // Межстрочный интервал
              ),
              children: [
                TextSpan(text: textToDisplay),
              ],
            ),
          ),
          // Кнопка "Показать полностью/скрыть"
          if (isTooLong)
            InkWell(
              onTap: () {
                setState(() {
                  _isDescriptionExpanded = !_isDescriptionExpanded;
                });
              },
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 4.0),
                child: Text(
                  _isDescriptionExpanded ? "Скрыть" : "Показать полностью",
                  style: const TextStyle(
                    color: Colors.blue,
                    fontWeight: FontWeight.bold,
                    fontSize: 13,
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildWorkshopLink(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(left: 12.0, right: 12.0, top: 12.0),
      child: SizedBox(
        width: double.infinity,
        child: ElevatedButton.icon(
          onPressed: () {
            // Placeholder для открытия ссылки Deep Link на Мастерскую
            // launchUrl(Uri.parse('diaroom://workshop/${widget.post.workshopLink}'));
            ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Открыть Workshop: ${widget.post.workshopLink}")));
          },
          icon: const Icon(Icons.build_circle_outlined, size: 18),
          label: const Text("Перейти к Мастерской", style: TextStyle(fontSize: 14)),
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.blue[50], // Светло-голубой фон
            foregroundColor: Colors.blue[700], // Синий текст/иконка
            elevation: 0,
            padding: const EdgeInsets.symmetric(vertical: 12),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
          ),
        ),
      ),
    );
  }
}