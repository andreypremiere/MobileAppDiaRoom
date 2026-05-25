import 'package:dia_room/utils/app_theme.dart';
import 'package:flutter/material.dart';

import '../../../models/post_view/author.dart';
import '../app_avatar.dart';
// Импортируй свой AppAvatar, если он лежит в другом месте
// import 'package:your_project/widgets/app_avatar.dart';

class AuthorTile extends StatelessWidget {
  final Author author;
  final VoidCallback? onTap;

  const AuthorTile({
    super.key,
    required this.author,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      // Скругление эффекта нажатия (splash) подгоняем под общую форму
      borderRadius: BorderRadius.circular(12),
      child: Padding(
        padding: const EdgeInsets.symmetric(
          horizontal: 4,
          vertical: 4,
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min, // Строго по контенту
          children: [
            // Аватар комнаты
            AppAvatar(
              avatarPath: author.avatar,
              radius: 18,
              enableFullScreenPreview: false,
            ),
            const SizedBox(width: 10),
            // Название комнаты
            Text(
              author.roomName,
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: context.ui.fontColorPrimary, // Твой фирменный цвет шрифта
              ),
            ),
          ],
        ),
      ),
    );
  }
}