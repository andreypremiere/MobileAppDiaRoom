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
    final placeholderColor = isDark ? Colors.grey[700] : Colors.grey[300];
    final textColor = isDark ? Colors.grey[500] : Colors.grey[600];

    return GestureDetector(
      onTap: onRetry,
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
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
          Text(
            message,
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w400,
              color: textColor,
              fontStyle: FontStyle.italic,
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