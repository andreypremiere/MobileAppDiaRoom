import 'package:flutter/material.dart';

import 'link_button.dart';

class AttachedLinksBlock extends StatelessWidget {
  final String labelWorkshop;
  final String labelPost;
  final String? workshopLink;
  final String? postLink;
  final VoidCallback? onRemoveWorkshop;
  final VoidCallback? onRemovePost;
  final VoidCallback? onTapWorkshop;
  final VoidCallback? onTapPost;

  const AttachedLinksBlock({
    super.key,
    required this.labelWorkshop,
    required this.labelPost,
    this.workshopLink,
    this.postLink,
    this.onRemoveWorkshop,
    this.onRemovePost,
    this.onTapPost,
    this.onTapWorkshop
  });

  @override
  Widget build(BuildContext context) {
    // Если ссылок нет, ничего не рисуем
    if (workshopLink == null && postLink == null) {
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
        ],
      ),
    );
  }
}