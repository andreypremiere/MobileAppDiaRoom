import 'package:dia_room/components/diary/link_button.dart';
import 'package:dia_room/components/loading_widget/loader_widget.dart';
import 'package:dia_room/models/post_view/author.dart';
import 'package:dia_room/utils/app_theme.dart';
import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:go_router/go_router.dart';

import '../../api/auth_response.dart';
import '../../api/post_v2_api.dart';
import '../../configuration/constants.dart';
import '../../models/enums/file_type.dart';
import '../../models/post_v2/post_response.dart';
import '../general/author_tile_appbar/author_tile.dart';


class PostCard extends StatefulWidget {
  final PostResponse post;

  const PostCard({super.key, required this.post});

  @override
  State<PostCard> createState() => _PostCardState();
}

class _PostCardState extends State<PostCard> {
  // Состояние для раскрытия описания
  bool _isDescriptionExpanded = false;
  int _currentPhotoIndex = 0; // Следим за текущей фоткой в карусели

  late bool _isLiked;
  bool _isLikePending = false;
  late int _likesCount;

  @override
  void initState() {
    super.initState();
    _isLiked = widget.post.isLiked;
    _likesCount = widget.post.likesCount;
  }

  Future<void> _toggleLike() async {
    if (_isLikePending) return; // Если запрос уже выполняется, игнорируем клик

    // 1. Сохраняем предыдущее состояние на случай ошибки сервера
    final bool oldIsLiked = _isLiked;
    final int oldLikesCount = _likesCount;

    // 2. Мгновенно обновляем UI (Optimistic UI)
    setState(() {
      _isLikePending = true;
      if (_isLiked) {
        _likesCount--;
      } else {
        _likesCount++;
      }
      _isLiked = !_isLiked;
    });

    try {
      final AuthResponse response;

      // 3. Вызываем соответствующий метод API в зависимости от СТАРОГО состояния
      if (oldIsLiked) {
        response = await unlikePost(postId: widget.post.id);
      } else {
        response = await likePost(postId: widget.post.id);
      }

      // 4. Проверяем успешность серверного экшена
      if (!response.success) {
        // Если сервер вернул ошибку, откатываем UI назад
        _rollbackLike(oldIsLiked, oldLikesCount, response.message ?? "Не удалось обновить лайк");
      }
    } catch (e) {
      // На случай критической ошибки сети также делаем откат
      _rollbackLike(oldIsLiked, oldLikesCount, "Проблемы с соединением");
    } finally {
      if (mounted) {
        setState(() {
          _isLikePending = false; // Разрешаем кликать снова
        });
      }
    }
  }

// Вспомогательный метод для отката состояния
  void _rollbackLike(bool oldIsLiked, int oldLikesCount, String errorMessage) {
    if (!mounted) return;
    setState(() {
      _isLiked = oldIsLiked;
      _likesCount = oldLikesCount;
    });
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(errorMessage),
        duration: const Duration(seconds: 2),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    TextStyle countStyle = TextStyle(
      fontSize: 14,
      color: context.ui.fontColorHint,
      fontWeight: FontWeight.w600,
    );

    return Container(
      width: double.infinity,
      // margin: const EdgeInsets.symmetric(vertical: 4),
      decoration: BoxDecoration(
        color: context.ui.containerColor,
        borderRadius: BorderRadius.circular(16),
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

          _buildHashtags(),

          _buildWorkshopLink(),

          // Отступ снизу карточки
          const SizedBox(height: 6),
        ],
      ),
    );
  }

  // --- Вспомогательные методы сборки UI ---

  Widget _buildHeader(BuildContext context) {
    final author = widget.post.roomInfo;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0, horizontal: 12),
      child: Row(
        children: [
          author == null ? Text("Ошибка") : AuthorTile(
              author: Author(roomId: author.roomId, roomName: author.roomName, avatar: author.avatarUrl),
          onTap: () => context.push("/room/${author.roomId}"),),
          Spacer(),
          IconButton(
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Поделиться (заглушка)")));
            },
            icon: Icon(Icons.share_outlined, color: context.ui.fontColorHint),
          ),
        ],
      ),
    );
  }

  Widget _buildMediaCarousel() {
    if (widget.post.files.isEmpty) return const SizedBox.shrink();

    // Определяем соотношение сторон по ПЕРВОЙ фотографии
    double ar = 1.0;
    if (widget.post.files.first.width > 0 && widget.post.files.first.height > 0) {
      ar = widget.post.files.first.width / widget.post.files.first.height;
    }

    // Заранее готовим плоский список urlMedium для передачи в полноэкранный режим
    final List<String> photoList = widget.post.files.map((f) => f.urlMedium).toList();

    return AspectRatio(
      aspectRatio: ar,
      child: Stack(
        children: [
          // 1. Сама карусель
          Container(
            color: context.ui.fontColorHint,
            child: CarouselSlider(
              options: CarouselOptions(
                viewportFraction: 1.0,
                aspectRatio: ar,
                enableInfiniteScroll: false, // ТРЕБОВАНИЕ 1: Убрали бесконечную прокрутку
                // Отслеживаем смену слайда, чтобы обновить индикатор
                onPageChanged: (index, reason) {
                  setState(() {
                    _currentPhotoIndex = index;
                  });
                },
              ),
              items: widget.post.files.asMap().entries.map((entry) {
                final int index = entry.key;
                final file = entry.value;

                return Builder(
                  builder: (BuildContext context) {
                    // Добавляем кликабельность для открытия на весь экран
                    return GestureDetector(
                      onTap: () {
                        // ТРЕБОВАНИЕ 3: Открытие полноэкранного режима
                        context.push(
                          '/full_image_screen',
                          extra: {
                            'urls': photoList,
                            'index': index,
                            'type': FileType.network,
                          },
                        );
                      },
                      child: CachedNetworkImage(
                        imageUrl: file.urlSmall, // Используем ТОЛЬКО Small
                        fit: BoxFit.contain,
                        width: double.infinity,
                        // Пока грузится Small, показываем аккуратный стандартный лоадер
                        placeholder: (context, url) => const Center(
                          child: DiaRoomLoader(),
                        ),
                        errorWidget: (context, url, error) => const Icon(
                          Icons.error_outline,
                          size: 40,
                        ),
                      ),
                    );
                  },
                );
              }).toList(),
            ),
          ),

          // 2. ТРЕБОВАНИЕ 2: Полупрозрачный индикатор страниц (показываем, только если фото > 1)
          if (widget.post.files.length > 1)
            Positioned(
              top: 12,
              right: 12,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                decoration: BoxDecoration(
                  color: Colors.black.withOpacity(0.6), // Темный полупрозрачный фон
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  '${_currentPhotoIndex + 1}/${widget.post.files.length}',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildActionsBar(TextStyle countStyle) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 2.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          // Слева: Комментарии
          Row(
            children: [
              IconButton(
                onPressed: () {
                  // Переход к комментариям
                },
                icon: Icon(Icons.mode_comment_outlined, color: context.ui.fontColorHint),
              ),
              Text('${widget.post.commentsCount}', style: countStyle),
            ],
          ),
          // Справа: Лайки
          Row(
            children: [
              IconButton(
                onPressed: _toggleLike,
                icon: Icon(
                  _isLiked ? Icons.favorite : Icons.favorite_border,
                  color: _isLiked ? Colors.red : context.ui.fontColorHint,
                ),
              ),
              Text('$_likesCount', style: countStyle),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildDescription() {
    final description = widget.post.description;
    if (description == null || description.isEmpty) return const SizedBox.shrink();

    // Задаем общий стиль текста, чтобы и при расчетах, и при рендере он был одинаковым
    final TextStyle textStyle = TextStyle(
      color: context.ui.fontColorPrimary,
      fontWeight: FontWeight.w400,
      fontSize: 15,
      height: 1.4,
    );

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12.0),
      child: LayoutBuilder(
        builder: (context, constraints) {
          // 1. Создаем математический инструмент для рассчета размеров текста
          final textPainter = TextPainter(
            text: TextSpan(text: description, style: textStyle),
            textDirection: TextDirection.ltr,
            maxLines: 2, // Ограничиваем расчет двумя строками
          );

          // 2. «Примеряем» текст к доступной ширине карточки
          textPainter.layout(maxWidth: constraints.maxWidth);

          // 3. Проверяем, превысил ли текст лимит в 2 строки
          // didExceedMaxLines вернет true, если реальный текст длиннее, чем вмещается в 2 строки
          final bool isTooLong = textPainter.didExceedMaxLines;

          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Сам текст поста
              RichText(
                // Если текст свернут, ставим лимит в 2 строки и включаем троеточие
                maxLines: _isDescriptionExpanded ? null : 2,
                overflow: _isDescriptionExpanded ? TextOverflow.visible : TextOverflow.ellipsis,
                text: TextSpan(
                  style: textStyle,
                  children: [
                    TextSpan(text: description), // Передаем ВСЮ строку, Flutter сам ее красиво обрежет
                  ],
                ),
              ),

              // Кнопка "Показать полностью/скрыть" (появляется только если текст реально занял больше 2 строк)
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
                      style: TextStyle(
                        color: context.ui.fontColorHint,
                        fontWeight: FontWeight.bold,
                        fontSize: 13,
                      ),
                    ),
                  ),
                ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildHashtags() {
    if (widget.post.hashtags.isEmpty) return const SizedBox.shrink();

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 4.0),
      // Используем Wrap, чтобы теги красиво переносились на новую строку, если их много
      child: Wrap(
        spacing: 6.0, // Расстояние между хэштегами по горизонтали
        runSpacing: 4.0, // Расстояние между строками хэштегов
        children: widget.post.hashtags.map((tag) {
          // Гарантируем, что тег начинается с решетки
          final formattedTag = tag.startsWith('#') ? tag : '#$tag';

          return Material(
            color: Colors.transparent,
            child: InkWell(
              onTap: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text("Поиск по тегу: $formattedTag")),
                );
              },
              borderRadius: BorderRadius.circular(4),
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 2.0, vertical: 1.0),
                child: Text(
                  formattedTag,
                  style: TextStyle(
                    color: context.ui.fontColorPrimary, // Или любой акцентный цвет из темы DiaRoom
                    fontWeight: FontWeight.w500,
                    fontSize: 14,
                  ),
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildWorkshopLink() {
    return widget.post.workshopLink != null ? Padding(
      padding: const EdgeInsets.only(left: 12.0, right: 12.0, top: 6),
      child:
        CustomLinkButton(
      icon: Icons.burst_mode_outlined,
      label: 'Открыть каталог',
      onTap: () {
        final String path = (widget.post.workshopLink == uuidNil)
            ? '/workshop/${widget.post.roomId}'
            : '/workshop/${widget.post.roomId}/${widget.post.workshopLink}';

        context.push(path);
      },
    ) ,
    ) : SizedBox.shrink();
  }
}