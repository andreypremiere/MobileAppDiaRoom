import 'package:dia_room/components/post_card/stats_widget.dart';
import 'package:dia_room/utils/app_theme.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../models/post_view/personal_post.dart';
import 'base_post_card.dart';

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
