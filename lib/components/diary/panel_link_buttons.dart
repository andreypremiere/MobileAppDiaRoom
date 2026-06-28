import 'package:flutter/material.dart';

import 'link_button.dart';

class AttachedLinksBlock extends StatelessWidget {
  final String labelWorkshop;
  final String labelPost;
  final String labelPostV2;
  final String? workshopLink;
  final String? postLink;
  final String? postV2Link;
  final VoidCallback? onRemoveWorkshop;
  final VoidCallback? onRemovePost;
  final VoidCallback? onRemovePostV2;
  final VoidCallback? onTapWorkshop;
  final VoidCallback? onTapPost;
  final VoidCallback? onTapPostV2;

  const AttachedLinksBlock({
    super.key,
    required this.labelWorkshop,
    required this.labelPost,
    required this.labelPostV2,
    this.workshopLink,
    this.postLink,
    this.postV2Link,
    this.onRemoveWorkshop,
    this.onRemovePost,
    this.onRemovePostV2,
    this.onTapPost,
    this.onTapWorkshop,
    this.onTapPostV2,
  });

  @override
  Widget build(BuildContext context) {
    // Если ссылок нет, ничего не рисуем
    if (workshopLink == null && postLink == null && postV2Link == null) {
      return const SizedBox.shrink();
    }

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 6),
      child: Column(
        // Используем Column с отступами между элементами
        children: [
          if (workshopLink != null)
            CustomLinkButton(
              icon: Icons.burst_mode_outlined,
              label: labelWorkshop,
              onTap: onTapWorkshop,
              onClose: onRemoveWorkshop,
            ),

          // Добавляем небольшой зазор между кнопками, если их две
          if (workshopLink != null && postLink != null)
            const SizedBox(height: 4),

          if (postLink != null)
            CustomLinkButton(
              icon: Icons.article_outlined,
              label: labelPost,
              onTap: onTapPost,
              onClose: onRemovePost,
            ),

          if (postLink != null && postV2Link != null)
            const SizedBox(height: 4),

          // 3. Блок второй Публикации (Новый)
          if (postV2Link != null)
            CustomLinkButton(
              icon: Icons.featured_video_outlined, // Можно заменить иконку, если нужно дифференцировать посты
              label: labelPostV2,
              onTap: onTapPostV2,
              onClose: onRemovePostV2,
            ),
        ],
      ),
    );
  }
}