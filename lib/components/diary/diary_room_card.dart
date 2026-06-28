import 'package:dia_room/components/general/app_avatar.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../../utils/app_theme.dart';

class DiaryRoomCard extends StatelessWidget {
  final String nickname;
  final String? avatarUrl;
  final DateTime? lastMessageAt;
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
      return "Вчера";
    } else {
      return DateFormat('dd.MM.yy').format(localDate);
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

            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              mainAxisSize: MainAxisSize.min,
              children: [
                if (lastMessageAt != null)
                  Text(
                    _formatSmartDate(lastMessageAt!),
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w400,
                      color: context.ui.fontColorHint ?? Colors.grey,
                    ),
                  ),

                if (lastMessageAt != null && unreadCount > 0)
                  const SizedBox(height: 6),

                if (unreadCount > 0)
                  Container(
                    height: 22,
                    padding: const EdgeInsets.symmetric(horizontal: 6),
                    constraints: const BoxConstraints(
                      minWidth: 22,
                    ),
                    decoration: BoxDecoration(
                      color: context.ui.appBarColor,
                      borderRadius: BorderRadius.circular(12),
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