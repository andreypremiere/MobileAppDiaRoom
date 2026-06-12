import 'package:dia_room/contracts/posts_v2/responses/comment_response.dart';
import 'package:dia_room/utils/app_theme.dart';
import 'package:dia_room/utils/utils.dart';
import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';



class CommentCard extends StatelessWidget {
  final CommentResponse comment;
  final VoidCallback? onLongPress;

  const CommentCard({
    super.key,
    required this.comment,
    this.onLongPress,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onLongPress: onLongPress,
      borderRadius: BorderRadius.circular(12),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 12.0),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 1. Аватарка пользователя слева
            ClipRRect(
              borderRadius: BorderRadius.circular(20),
              child: CachedNetworkImage(
                imageUrl: comment.author?.avatar ?? '',
                width: 40,
                height: 40,
                fit: BoxFit.cover,
                placeholder: (context, url) => Container(
                  color: context.ui.fontColorHint.withOpacity(0.1),
                ),
                errorWidget: (context, url, error) => Container(
                  color: context.ui.fontColorHint.withOpacity(0.2),
                  child: Icon(Icons.person_rounded, color: context.ui.fontColorHint, size: 20),
                ),
              ),
            ),
            const SizedBox(width: 12),

            // 2. Никнейм, текст комментария и дата справа
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    comment.author?.roomName ?? "Empty",
                    style: TextStyle(
                      color: context.ui.fontColorPrimary,
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    comment.text,
                    style: TextStyle(
                      color: context.ui.fontColorPrimary,
                      fontSize: 15,
                      height: 1.3,
                    ),
                  ),
                  const SizedBox(height: 6),
                  // Прижимаем дату к правому нижнему углу внутри колонки
                  Align(
                    alignment: Alignment.bottomRight,
                    child: Text(
                      formatSmartDate(comment.createdAt), // Метод форматирования даты в твоей модели (напр. "12:40")
                      style: TextStyle(
                        color: context.ui.fontColorHint,
                        fontSize: 11,
                        fontWeight: FontWeight.w500,
                      ),
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