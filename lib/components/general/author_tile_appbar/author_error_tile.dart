import 'package:flutter/material.dart';

class AuthorEmptyTile extends StatelessWidget {
  final String message;
  final VoidCallback? onRetry;

  const AuthorEmptyTile({
    super.key,
    this.message = 'Ошибка',
    this.onRetry,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    // Тонкие, не отвлекающие цвета для плейсхолдера
    final placeholderColor = isDark ? Colors.grey[700] : Colors.grey[300];
    final textColor = isDark ? Colors.grey[500] : Colors.grey[600];

    return GestureDetector(
      onTap: onRetry, // Если передали колбэк — при тапе можно перезапустить запрос
      child: Row(
        mainAxisSize: MainAxisSize.min, // Тоже строго по контенту
        children: [
          // Заглушка аватара
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: placeholderColor,
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.account_circle_outlined,
              size: 20,
              color: isDark ? Colors.grey[500] : Colors.grey[500],
            ),
          ),
          const SizedBox(width: 10),
          // Текст ошибки
          Text(
            message,
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w400,
              color: textColor,
              fontStyle: FontStyle.italic, // Легкий курсив подчеркнет, что это статус
            ),
          ),
          if (onRetry != null) ...[
            const SizedBox(width: 6),
            Icon(Icons.refresh_rounded, size: 16, color: textColor),
          ],
        ],
      ),
    );
  }
}