import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../api/auth_response.dart';
import '../../api/post_v2_api.dart';
import '../../utils/app_theme.dart';
import '../../contracts/posts_v2/responses/post_response.dart';
import '../loading_widget/loader_widget.dart';

class PinterestPostCard extends StatefulWidget {
  final PostResponse post;
  final VoidCallback? onTap;

  const PinterestPostCard({super.key, required this.post, this.onTap});

  @override
  State<PinterestPostCard> createState() => _PinterestPostCardState();
}

class _PinterestPostCardState extends State<PinterestPostCard> {
  int _currentImageIndex = 0;
  bool _isLikePending = false; // Оставляем только флаг блокировки кликов

  void _rollbackLike(bool oldIsLiked, int oldLikesCount, String message) {
    if (!mounted) return;
    setState(() {
      widget.post.isLiked = oldIsLiked;
      widget.post.likesCount = oldLikesCount;
    });
    print('⚠️ Откат лайка: $message');
  }

  Future<void> _toggleLike() async {
    if (_isLikePending) return;

    // 1. Сохраняем предыдущее состояние из объекта
    final bool oldIsLiked = widget.post.isLiked;
    final int oldLikesCount = widget.post.likesCount;

    // 2. Мгновенно обновляем сам объект (Optimistic UI)
    setState(() {
      _isLikePending = true;
      if (widget.post.isLiked) {
        widget.post.likesCount--;
      } else {
        widget.post.likesCount++;
      }
      widget.post.isLiked = !widget.post.isLiked;
    });

    try {
      final AuthResponse response;

      // 3. Отправляем запрос, ориентируясь на старое состояние
      if (oldIsLiked) {
        response = await unlikePost(postId: widget.post.id);
      } else {
        response = await likePost(postId: widget.post.id);
      }

      // 4. Если сервер ответил ошибкой — откатываемся
      if (!response.success) {
        _rollbackLike(oldIsLiked, oldLikesCount, response.message ?? "Не удалось обновить лайк");
      }
    } catch (e) {
      _rollbackLike(oldIsLiked, oldLikesCount, "Проблемы с соединением");
    } finally {
      if (mounted) {
        setState(() {
          _isLikePending = false;
        });
      }
    }
  }

  void _handleTap() {
    context.push(
      '/post_v2/${widget.post.id}',
      extra: widget.post,
    );
  }

  @override
  Widget build(BuildContext context) {
    double aspectRatio = 4 / 5;
    if (widget.post.files.isNotEmpty) {
      final firstMedia = widget.post.files.first;
      aspectRatio = firstMedia.width / firstMedia.height;
    }

    return GestureDetector(
      onTap: widget.onTap ?? _handleTap,
      onDoubleTap: _toggleLike,
      child: Container(
        decoration: BoxDecoration(
          color: context.ui.containerColor,
          borderRadius: BorderRadius.circular(12),
        ),
        clipBehavior: Clip.antiAlias,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            // 1. Блок с фото и индикаторами
            Stack(
              alignment: Alignment.bottomCenter,
              children: [
                AspectRatio(
                  aspectRatio: aspectRatio,
                  child: PageView.builder(
                    itemCount: widget.post.files.length,
                    onPageChanged: (index) {
                      setState(() {
                        _currentImageIndex = index;
                      });
                    },
                    itemBuilder: (context, index) {
                      final file = widget.post.files[index];
                      final rawUrl = file.urlSmall;

                      if (rawUrl == null || rawUrl.isEmpty) {
                        print('⚠️ PinterestCard: Empty image URL for post ${widget.post.id}');
                        return Container(
                          color: Colors.grey[200],
                          child: const Icon(Icons.image_not_supported_rounded, color: Colors.grey),
                        );
                      }

                      String finalImageUrl = rawUrl;
                      if (!rawUrl.startsWith('http')) {
                        const String baseUrl = 'https://api.yourdiaapp.com';
                        finalImageUrl = '$baseUrl$rawUrl';
                      }

                      return CachedNetworkImage(
                        imageUrl: finalImageUrl,
                        fit: BoxFit.cover,
                        placeholder: (context, url) => Container(
                          color: Colors.grey[100],
                          child: const Center(
                            child: DiaRoomLoader(),
                          ),
                        ),
                        errorWidget: (context, url, error) {
                          print('❌ ERROR CacheImage: Failed to load $url. Error: $error');
                          return Container(
                            color: Colors.grey[200],
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: const [
                                Icon(Icons.broken_image_rounded, color: Colors.grey, size: 28),
                                SizedBox(height: 4),
                                Text(
                                  'No image',
                                  style: TextStyle(color: Colors.grey, fontSize: 11),
                                ),
                              ],
                            ),
                          );
                        },
                      );
                    },
                  ),
                ),

                // Шарики (индикаторы)
                if (widget.post.files.length > 1)
                  Padding(
                    padding: const EdgeInsets.only(bottom: 8.0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: List.generate(
                        widget.post.files.length,
                            (index) => Container(
                          margin: const EdgeInsets.symmetric(horizontal: 3),
                          width: _currentImageIndex == index ? 7 : 5,
                          height: _currentImageIndex == index ? 7 : 5,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: _currentImageIndex == index
                                ? Colors.white
                                : Colors.white.withOpacity(0.5),
                          ),
                        ),
                      ),
                    ),
                  ),
              ],
            ),

            // 2. Блок с лайками и комментариями
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Row(
                children: [
                  Spacer(),
                  // Комментарии (Работаем напрямую с widget.post)
                  Icon(
                    Icons.chat_bubble_outline_rounded,
                    color: context.ui.fontColorHint,
                    size: 18,
                  ),
                  const SizedBox(width: 4),
                  Text(
                    "${widget.post.commentsCount}",
                    style: TextStyle(
                      fontSize: 13,
                      color: context.ui.fontColorHint,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Icon(
                    widget.post.isLiked ? Icons.favorite_rounded : Icons.favorite_border_rounded,
                    color: widget.post.isLiked ? Colors.redAccent : context.ui.fontColorHint,
                    size: 20,
                  ),
                  const SizedBox(width: 4),
                  Text(
                    '${widget.post.likesCount}',
                    style: TextStyle(
                      fontSize: 13,
                      color: context.ui.fontColorHint,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}