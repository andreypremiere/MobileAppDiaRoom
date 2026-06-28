import 'package:dia_room/components/general/app_avatar.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart'; // Не забудь про импорт intl для DateFormat внутри функции
import '../../../utils/app_theme.dart';

class DiaryRoomCard extends StatelessWidget {
  final String nickname;
  final String? avatarUrl;
  final DateTime? lastMessageAt; // Теперь активно используем!
  final String lastMessage;
  final int unreadCount;
  final VoidCallback onTap;

  const DiaryRoomCard({
    super.key,
    required this.nickname,
    required this.avatarUrl,
    required this.lastMessage,
    this.lastMessageAt,
    required this.unreadCount,
    required this.onTap,
  });

  // Твоя умная функция форматирования даты
  String _formatSmartDate(DateTime date) {
    final localDate = date.toLocal();
    final now = DateTime.now();

    final today = DateTime(now.year, now.month, now.day);
    final yesterday = today.subtract(const Duration(days: 1));
    final dateToCheck = DateTime(localDate.year, localDate.month, localDate.day);

    final String timePart = DateFormat('HH:mm').format(localDate);

    if (dateToCheck == today) {
      return timePart;
    } else if (dateToCheck == yesterday) {
      return "Вчера"; // Для краткости в списке чатов "в $timePart" обычно опускают, но если нужно — верни свой вариант
    } else {
      return DateFormat('dd.MM.yy').format(localDate); // В списке чатов красивее смотрится просто компактная дата
    }
  }

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            AppAvatar(
              avatarPath: avatarUrl ?? "",
              radius: 24,
              enableFullScreenPreview: false,
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

            // Правая колонка: Время и Счетчик непрочитанных
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              mainAxisSize: MainAxisSize.min,
              children: [
                // Показываем дату, только если она передана (lastMessageAt != null)
                if (lastMessageAt != null)
                  Text(
                    _formatSmartDate(lastMessageAt!),
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w400,
                      color: context.ui.fontColorHint ?? Colors.grey,
                    ),
                  ),

                // Делаем отступ между датой и счетчиком, только если счетчик будет отображаться
                if (lastMessageAt != null && unreadCount > 0)
                  const SizedBox(height: 6),

                // Счетчик непрочитанных
                if (unreadCount > 0)
                  Container(
                    height: 22, // Чуть уменьшил высоту для компактности рядом с датой
                    padding: const EdgeInsets.symmetric(horizontal: 6),
                    constraints: const BoxConstraints(
                      minWidth: 22,
                    ),
                    decoration: BoxDecoration(
                      color: context.ui.appBarColor,
                      borderRadius: BorderRadius.circular(12), // Скругленные углы лучше подходят для '99+'
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

                // Корректирующая заглушка-распорка, чтобы высота правой колонки не прыгала,
                // когда счетчика нет, удерживая никнейм и сообщение по центру аватарки
                if (unreadCount == 0 && lastMessageAt != null)
                  const SizedBox(height: 16),
              ],
            ),
          ],
        ),
      ),
    );
  }
}