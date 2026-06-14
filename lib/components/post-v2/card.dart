import 'package:dia_room/components/post-v2/post_article_link.dart';
import 'package:dia_room/components/post-v2/post_description.dart';
import 'package:dia_room/components/post-v2/post_hashtags.dart';
import 'package:dia_room/components/post-v2/post_media_carousel.dart';
import 'package:dia_room/components/post-v2/post_workshop_link.dart';
import 'package:dia_room/utils/app_theme.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../api/auth_response.dart';
import '../../api/post_v2_api.dart';
import '../../contracts/posts_v2/responses/post_response.dart';
import '../../models/post_view/author.dart';
import '../../utils/utils.dart';
import '../general/author_tile_appbar/author_tile.dart';

class PostCard extends StatefulWidget {
  final PostResponse post;
  const PostCard({super.key, required this.post});
  @override
  State<PostCard> createState() => _PostCardState();
}

class _PostCardState extends State<PostCard> {
  // Сюда инкапсулируем только логику лайка, остальной стейт ушел в дочерние компоненты
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

  @override
  Widget build(BuildContext context) {
    TextStyle countStyle = TextStyle(fontSize: 14, color: context.ui.fontColorHint, fontWeight: FontWeight.w600);

    return Container(
      width: double.infinity,
      decoration: BoxDecoration(color: context.ui.containerColor, borderRadius: BorderRadius.circular(16)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildHeader(context),
          PostMediaCarousel(files: widget.post.files), // Используем общий виджет
          _buildActionsBar(countStyle),
          PostDescription(description: widget.post.description), // Используем общий виджет
          PostHashtags(hashtags: widget.post.hashtags), // Используем общий виджет
          PostWorkshopLink(workshopLink: widget.post.workshopLink, roomId: widget.post.roomId), // Используем общий виджет
          PostArticleLink(articleLink: widget.post.articleLink, roomId: widget.post.roomId),
          const SizedBox(height: 6),
        ],
      ),
    );
  }

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

  Widget _buildActionsBar(TextStyle countStyle) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 2.0),
      child: Row(
        // Выравниваем все элементы в Row строго по центру вертикали
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

          // Справа: Комментарии
          Row(
            children: [
              IconButton(
                onPressed: _openComments,
                icon: Icon(Icons.mode_comment_outlined, color: context.ui.fontColorHint),
              ),
              Text('$_commentsCount', style: countStyle),
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
}