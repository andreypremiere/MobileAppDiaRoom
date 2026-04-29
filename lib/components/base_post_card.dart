import 'package:cached_network_image/cached_network_image.dart';
import 'package:dia_room/models/enums/post_categories.dart';
import 'package:dia_room/models/post_view/base_post.dart';
import 'package:dia_room/utils/app_theme.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../models/post_view/feed_post.dart';
import '../models/post_view/personal_post.dart';

class BasePostCard extends StatelessWidget {
  final String title;
  final String? previewUrl;
  final PostCategory category;
  final VoidCallback onTap;
  final Widget bottomPanel;
  final Widget? topAction;

  const BasePostCard({
    super.key,
    required this.title,
    required this.previewUrl,
    required this.category,
    required this.onTap,
    required this.bottomPanel,
    this.topAction
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(borderRadius: BorderRadius.circular(10)),
      child: Material(
        color: context.ui.containerColor,
        borderRadius: BorderRadius.circular(10),
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          onTap: onTap,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              AspectRatio(
                aspectRatio: 16 / 9,
                child: Stack(
                  children: [
                    _buildImage(context),
                    _buildCategoryBadge(context),
                    if (topAction != null)
                      Positioned(
                        top: 4,
                        right: 4,
                        child: topAction!,
                      ),
                  ],
                ),
              ),

              Padding(
                padding: const EdgeInsets.fromLTRB(10, 8, 10, 0),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: Text(
                        title,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          fontWeight: FontWeight.w600,
                          fontSize: 16,
                          color: context.ui.fontColorPrimary,
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                child: bottomPanel,
              ),
            ],
          ),
        ),
      ),
    );
  }

  // Вспомогательные методы для чистоты кода
  Widget _buildImage(BuildContext context) {
    return CachedNetworkImage(
      imageUrl: previewUrl ?? '',
      fit: BoxFit.cover,
      width: double.infinity,
      height: double.infinity,
      placeholder: (context, url) => Center(child: CircularProgressIndicator()),
      errorWidget: (context, url, error) => Container(
        color: const Color(0xFFE0E0E0),
        child: const Icon(Icons.broken_image_outlined, size: 40, color: Color(0xFF888888)),
      ),
    );
  }

  Widget _buildCategoryBadge(BuildContext context) {
    return Positioned(
      left: 8, bottom: 8,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
        decoration: BoxDecoration(
          color: context.ui.containerColor.withAlpha(85),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Text(
          category.label,
          style: TextStyle(fontSize: 12, fontWeight: FontWeight.w500, color: context.ui.fontColorPrimary),
        ),
      ),
    );
  }
}

class FeedPostComponent extends StatelessWidget {
  final FeedPost post;

  const FeedPostComponent({super.key, required this.post});

  @override
  Widget build(BuildContext context) {
    return BasePostCard(
      title: post.data.title,
      previewUrl: post.data.preview,
      category: post.data.category,
      onTap: () => context.push("/showPost/${post.data.postId}"),
      bottomPanel: Column(
        children: [
          Row(
            children: [
              _buildAuthorInfo(context),
              const Spacer(),
              buildStats(context, post.stats.views, post.stats.likes),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildAuthorInfo(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        CachedNetworkImage(
          imageUrl: post.author.avatar,
          imageBuilder: (context, imageProvider) => CircleAvatar(
            radius: 12,
            backgroundImage: imageProvider,
          ),
          errorWidget: (context, url, error) => CircleAvatar(
            radius: 12,
            backgroundColor: context.ui.primaryColor,
            child: const Icon(Icons.person, size: 14, color: Colors.white),
          ),
        ),
        const SizedBox(width: 8),
        Text(
          post.author.roomName,
          style: TextStyle(
            color: context.ui.fontColorHint,
            fontSize: 14,
            fontWeight: FontWeight.w400,
          ),
        ),
      ],
    );
  }
}

Widget buildStats(BuildContext context, int views, int likes) {
  return Row(
    mainAxisSize: MainAxisSize.min,
    children: [
      // Просмотры
      Text(
        '${views}',
        style: TextStyle(color: context.ui.fontColorHint, fontSize: 13),
      ),
      const SizedBox(width: 4),
      Icon(Icons.remove_red_eye_outlined, size: 16, color: context.ui.fontColorHint),

      const SizedBox(width: 10),

      // Лайки
      Text(
        '${likes}',
        style: TextStyle(color: context.ui.fontColorHint, fontSize: 13),
      ),
      const SizedBox(width: 4),
      Icon(Icons.favorite_border_rounded, size: 16, color: context.ui.fontColorHint),
    ],
  );
}

class OwnPostComponent extends StatelessWidget {
  final PersonalPost post;
  final VoidCallback onDelete;
  const OwnPostComponent({super.key, required this.post, required this.onDelete});


  Widget _buildTopMenu(BuildContext context) {
    return PopupMenuButton<String>(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      color: context.ui.containerColor, 
      elevation: 4,
      offset: const Offset(0, 40),

      child: Container(
        padding: const EdgeInsets.all(6),
        decoration: BoxDecoration(
          // Белая слегка прозрачная подложка
          color: Colors.white.withAlpha(85),
          shape: BoxShape.circle,
        ),
        child: Icon(
          Icons.more_vert_rounded,
          color: context.ui.fontColorPrimary,
          size: 22,
        ),
      ),

      // Элементы меню
      onSelected: (value) {
        if (value == 'delete') {
          onDelete.call();
        }
      },
      itemBuilder: (context) => [
        _buildPopupItem(
          context,
          value: 'delete',
          icon: Icons.delete_outline_rounded,
          label: 'Удалить',
          isDanger: true,
        ),
      ],
    );
  }

  /// Вспомогательный метод для создания пунктов меню в едином стиле
  PopupMenuItem<String> _buildPopupItem(
      BuildContext context, {
        required String value,
        required IconData icon,
        required String label,
        bool isDanger = false,
      }) {
    final color = isDanger ? Colors.redAccent : context.ui.fontColorPrimary;

    return PopupMenuItem<String>(
      value: value,
      height: 44,
      child: Row(
        children: [
          Icon(icon, color: color, size: 20),
          const SizedBox(width: 12),
          Text(
            label,
            style: TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w500,
              color: color,
            ),
          ),
        ],
      ),
    );
  }

  Widget _StatusBadge({required String status}) {
    Color color;
    String label;

    switch (status) {
      case 'published':
        color = Colors.green;
        label = 'Опубликовано';
        break;
      case 'processing':
        color = Colors.blue;
        label = 'Загрузка';
        break;
      case 'checking':
        color = Colors.blue;
        label = 'Идет проверка';
        break;
      case 'hidden':
        color = Color(0xFF4F4F4F);
        label = 'Скрыт';
        break;
      case 'rejected':
        color = Colors.red;
        label = 'Отказано';
        break;
      case 'failed':
        color = Colors.red;
        label = 'Ошибка';
        break;
      default:
        color = Colors.grey;
        label = status;
    }

    return _BadgeContainer(label: label, color: color);
  }

  // Бейджик статуса проверки нейросетью
  Widget _AiStatusBadge({required String status}) {
    Color color;
    String label;

    switch (status) {
      case 'notChecked':
        color = Colors.blue;
        label = 'Не проверен';
        break;
      case 'passed':
        color = Colors.green;
        label = 'Пост проверен';
        break;
      case 'failed':
        color = Colors.redAccent;
        label = 'Проверка не пройдена';
        break;
      default:
        return const SizedBox.shrink();
    }

    return _BadgeContainer(label: label, color: color, isAi: true);
  }

  // Универсальный контейнер для бейджиков
  Widget _BadgeContainer({required String label, required Color color, bool isAi = false}) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      decoration: BoxDecoration(
        color: color.withAlpha(30), // Легкий полупрозрачный фон
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: color.withAlpha(150), width: 1),
      ),
      child: Text(
        label,
        style: TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.w600,
          color: color,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return BasePostCard(
      title: post.data.title,
      previewUrl: post.data.preview,
      category: post.data.category,
      onTap: () => context.push("/showPost/${post.data.postId}"),
      bottomPanel: Row(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
            _StatusBadge(status: post.status),
            const SizedBox(height: 4),
            _AiStatusBadge(status: post.statusAi),
          ],),
          const Spacer(),
          buildStats(context, post.stats.views, post.stats.likes)
        ],
      ),
      topAction: _buildTopMenu(context),
    );
  }
}

class AnotherPostComponent extends StatelessWidget {
  final BasePost post;

  const AnotherPostComponent({super.key, required this.post});

  @override
  Widget build(BuildContext context) {
    return BasePostCard(
      title: post.data.title,
      previewUrl: post.data.preview,
      category: post.data.category,
      onTap: () => context.push("/showPost/${post.data.postId}"),
      bottomPanel: Column(
        children: [
          Row(
            children: [
              const Spacer(),
              buildStats(context, post.stats.views, post.stats.likes),
            ],
          ),
        ],
      ),
    );
  }
}