import 'package:dia_room/components/post-v2/post_article_link.dart';
import 'package:dia_room/components/post-v2/post_description.dart';
import 'package:dia_room/components/post-v2/post_hashtags.dart';
import 'package:dia_room/components/post-v2/post_media_carousel.dart';
import 'package:dia_room/components/post-v2/post_workshop_link.dart';
import 'package:dia_room/models/enums/post_v2/action_post.dart';
import 'package:dia_room/models/enums/post_v2/post_status.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:share_plus/share_plus.dart';
import '../../api/auth_response.dart';
import '../../api/post_v2_api.dart';
import '../../configuration/urls.dart';
import '../../contracts/posts_v2/responses/post_response.dart';
import '../../utils/app_theme.dart';
import '../../utils/utils.dart';


class PostManageCard extends StatefulWidget {
  final PostResponse post;
  final bool isMyPost;
  final Function(ActionPost, PostResponse) processAction;

  const PostManageCard({super.key, required this.post, required this.isMyPost,
  required this.processAction});

  @override
  State<PostManageCard> createState() => _PostManageCardState();
}

class _PostManageCardState extends State<PostManageCard> {
  late bool _isLiked;
  late int _likesCount;
  bool _isLikePending = false;

  late int _commentsCount;

  @override
  void initState() {
    super.initState();
    _isLiked = widget.post.isLiked;
    _likesCount = widget.post.likesCount;

    _commentsCount = widget.post.commentsCount;
  }

  Future<void> _openComments() async {
    final result = await context.push<int>('/posts_v2/comments/${widget.post.id}');

    if (result != null && result > 0 && mounted) {
      setState(() {
        _commentsCount += result;
        widget.post.commentsCount = _commentsCount;
      });
    }
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

      widget.post.likesCount = _likesCount;
      widget.post.isLiked = _isLiked;
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

  Future<void> _showPopUpFromButton(BuildContext buttonContext) async {
    // Находим координаты кнопки на экране
    final RenderBox renderBox = buttonContext.findRenderObject() as RenderBox;
    final Offset offset = renderBox.localToGlobal(Offset.zero);

    // Формируем прямоугольник ровно под кнопкой троеточия
    final RelativeRect position = RelativeRect.fromRect(
      Rect.fromLTWH(offset.dx, offset.dy + renderBox.size.height, renderBox.size.width, 0),
      Offset.zero & MediaQuery.of(context).size,
    );

    final result = await showMenu<ActionPost>(
      color: context.ui.containerColor,
      context: context,
      position: position, // Передаем вычисленную позицию кнопки
      items: ActionPost.values.map((action) {
        return PopupMenuItem<ActionPost>(
          value: action,
          child: Row(
            children: [
              Icon(action.icon, size: 20, color: action.color),
              const SizedBox(width: 12),
              Text(
                action.name,
                style: TextStyle(fontSize: 14, color: context.ui.fontColorPrimary),
              ),
            ],
          ),
        );
      }).toList(),
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
    );

    if (result != null && mounted) {
      await widget.processAction(result, widget.post);
    }
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
          // 1. Измененный Хедер под новый сценарий
          _buildManageHeader(),

          // 2. Общая Карусель
          PostMediaCarousel(files: widget.post.files),

          // 3. Панель кнопок
          _buildActionsBar(countStyle),

          // 4. Общее описание
          PostDescription(description: widget.post.description),

          // 5. Общие хэштеги
          PostHashtags(hashtags: widget.post.hashtags),

          // 6. Ссылка на мастерскую
          PostWorkshopLink(workshopLink: widget.post.workshopLink, roomId: widget.post.roomId),
          PostArticleLink(articleLink: widget.post.articleLink, roomId: widget.post.roomId),

          const SizedBox(height: 6),
        ],
      ),
    );
  }

  Widget _buildManageHeader() {
    // Проверяем статус (предполагаем, что поле называется status, подставь свою переменную, если это строка или enum)
    final bool isNotPublished = widget.post.status != PostStatus.published;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0, horizontal: 12),
      child: Row(
        children: [
          // Слева сверху: отображаем статус, если он не published
          if (isNotPublished)
            Text(
              widget.post.status.name, // Например, "ЧЕРНОВИК" или "МОДЕРАЦИЯ"
              style: const TextStyle(
                color: Colors.deepOrangeAccent, // Замени на нужный цвет из темы
                fontSize: 12,
                fontWeight: FontWeight.bold,
              ),
            )
          else
            const SizedBox.shrink(),

          const Spacer(),

          // Справа сверху: Кнопка Поделиться
          IconButton(
            onPressed: () async {
              // 1. Формируем ссылку и текст
              final String shareUrl = '$baseUrlClean/share/post/${widget.post.id}';
              final String shareText = 'Посмотри пост в DiaRoom! \n$shareUrl';

              // 2. Высчитываем координаты для iPad
              final box = context.findRenderObject() as RenderBox?;
              final sharePositionOrigin = box != null ? box.localToGlobal(Offset.zero) & box.size : null;

              // 3. Новый синтаксис share_plus 10.0+ через SharePlus.instance
              await SharePlus.instance.share(
                  ShareParams(
                      text: shareText,
                      subject: 'Пост из социальной сети DiaRoom',
                      sharePositionOrigin: sharePositionOrigin
                  )
              );
            },
            icon: Icon(Icons.share_outlined, color: context.ui.fontColorHint),
          ),

          if (widget.isMyPost)
            PopupMenuButton<ActionPost>(
              // Задаем иконку троеточия
              icon: Icon(Icons.more_vert_rounded, color: context.ui.fontColorHint),
              // Настройка внешнего вида самого меню
              color: context.ui.containerColor,
              elevation: 4,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              // Сдвиг меню чуть ниже иконки (опционально, подгони под дизайн)
              offset: const Offset(0, 40),

              // Логика выбора элемента
              onSelected: (ActionPost action) async {
                await widget.processAction(action, widget.post);
              },

              // Генерация элементов меню
              itemBuilder: (BuildContext context) {
                return ActionPost.values.map((action) {
                  return PopupMenuItem<ActionPost>(
                    value: action,
                    child: Row(
                      children: [
                        Icon(action.icon, size: 20, color: action.color),
                        const SizedBox(width: 12),
                        Text(
                          action.name,
                          style: TextStyle(
                            fontSize: 14,
                            color: context.ui.fontColorPrimary,
                          ),
                        ),
                      ],
                    ),
                  );
                }).toList();
              },
            ),
        ],
      ),
    );
  }

  Widget _buildActionsBar(TextStyle countStyle) {
    // Оставляем как в базовой карточке (лайки и комментарии)
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 2.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.end,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          // Слева: Текст с датой публикации по центру высоты
          Text(
            formatSmartDate(widget.post.createdAt),
            style: TextStyle(
              color: context.ui.fontColorHint,
              fontSize: 13,
              fontWeight: FontWeight.w400,
            ),
          ),

          // Расталкивает левую (дату) и правую (лайки/комменты) части по краям
          const Spacer(),
          Row(
            children: [
              IconButton(
                onPressed: _openComments,
                icon: Icon(Icons.mode_comment_outlined, color: context.ui.fontColorHint),
              ),
              Text('$_commentsCount', style: countStyle),
            ],
          ),
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
}