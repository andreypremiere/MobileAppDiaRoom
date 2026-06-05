import 'package:flutter/material.dart';
import '../../../utils/app_theme.dart'; // Твой импорт расширения темы

class DiaryRoomCard extends StatelessWidget {
  final String nickname;
  final String? avatarUrl;
  final String lastMessage;
  final int unreadCount;
  final VoidCallback onTap;

  const DiaryRoomCard({
    super.key,
    required this.nickname,
    required this.avatarUrl,
    required this.lastMessage,
    required this.unreadCount,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      // borderRadius: BorderRadius.circular(12),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        child: Row(
          children: [
            // Аватар пользователя
            CircleAvatar(
              radius: 24,
              backgroundColor: context.ui.containerColor,
              backgroundImage: avatarUrl != null && avatarUrl!.isNotEmpty
                  ? NetworkImage(avatarUrl!)
                  : null,
              child: avatarUrl == null || avatarUrl!.isEmpty
                  ? Icon(Icons.person_rounded, color: context.ui.iconColorPrimary, size: 24)
                  : null,
            ),
            const SizedBox(width: 12),

            // Никнейм и последнее сообщение
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    nickname,
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: context.ui.fontColorPrimary,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    lastMessage,
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w400,
                      color: context.ui.fontColorHint ?? Colors.grey,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
            const SizedBox(width: 8),

            // Счетчик непрочитанных сообщений (показываем, только если > 0)
            // Счетчик непрочитанных сообщений (показываем, только если > 0)
            if (unreadCount > 0)
              Container(
                height: 26,
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 4), // горизонтальный паддинг вместо minWidth
                constraints: const BoxConstraints(
                  minWidth: 26, // Теперь минимальная ширина задана правильно!
                ),
                decoration: BoxDecoration(
                  color: context.ui.appBarColor, // Серая круглая иконка в цвет аппбара
                  shape: BoxShape.circle,
                ),
                child: Center(
                  child: Text(
                    unreadCount > 99 ? '99+' : '$unreadCount',
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.bold,
                      color: context.ui.fontColorPrimary,
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}