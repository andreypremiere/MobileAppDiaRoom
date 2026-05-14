import 'package:dia_room/components/diary/video_note_card.dart';
import 'package:dia_room/components/diary/voice_card.dart';
import 'package:dia_room/contracts/diary/response/getting_messages.dart';
import 'package:dia_room/models/enums/diary/message_type.dart';
import 'package:dia_room/utils/app_theme.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../models/diary/message.dart';
import 'media_grid.dart';

class DiaryMessageCard extends StatelessWidget {
  final MessagePresentation message;

  const DiaryMessageCard({super.key, required this.message});

  String formatSmartDate(DateTime date) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final yesterday = today.subtract(const Duration(days: 1));
    final dateToCheck = DateTime(date.year, date.month, date.day);

    if (dateToCheck == today) {
      return "Сегодня в ${DateFormat('HH:mm').format(date)}";
    } else if (dateToCheck == yesterday) {
      return "Вчера в ${DateFormat('HH:mm').format(date)}";
    } else {
      return DateFormat('HH:mm · dd.MM.yy').format(date);
    }
  }

  Widget _buildStandardMessage(MessagePresentation message, BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min, // Чтобы колонка не занимала весь экран
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // 1. Текст сообщения
        if (message.message.content != null && message.message.content!.isNotEmpty)
          Padding(
            padding: const EdgeInsets.all(6),
            child: Text(
              message.message.content!,
              style: TextStyle(
                fontSize: 15,
                color: context.ui.fontColorPrimary,
              ),
            ),
          ),

        // 2. Вложения (Media Grid)
        if (message.attachments.isNotEmpty)
          MediaGrid(attachments: message.attachments),

        // 3. Кнопки ссылок (Объекты мастерской/посты)
        if (message.message.attachedObjectWorkshopId != null ||
            message.message.attachedObjectPostId != null)
          _buildLinkButtons(context),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    Widget messageContent;
    if (message.message.msgType == MessageType.standard) {
      messageContent = _buildStandardMessage(message, context);
    } else if (message.message.msgType == MessageType.voiceNote) {
      messageContent = VoiceMessageBubble(message: message);
    } else if (message.message.msgType == MessageType.videoNote) {
      messageContent = VideoMessageBubble(message: message);
    }
    else {
      return SizedBox.shrink();
    }

    return Container(
      padding: const EdgeInsets.all(4),
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: context.ui.containerColor,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withAlpha(5),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        spacing: 4,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          messageContent,

          // Общий футер с датой
          Padding(
            padding: const EdgeInsets.only(bottom: 6, right: 10, top: 2),
            child: Align(
              alignment: Alignment.bottomRight,
              child: Text(
                formatSmartDate(message.message.createdAt),
                style: TextStyle(
                  fontSize: 11,
                  color: context.ui.fontColorPrimary.withAlpha(120),
                ),
              ),
            ),
          ),
        ],
      ),
    );

  }

  Widget _buildLinkButtons(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 0),
      child: Column(
        spacing: 4,
        children: [
          if (message.message.attachedObjectWorkshopId != null)
            _linkButton(
              context,
              icon: Icons.burst_mode_outlined,
              label: "Перейти в мастерскую",
              onTap: () => print("Open Workshop: ${message.message.attachedObjectWorkshopId}"),
            ),
          if (message.message.attachedObjectPostId != null)
            _linkButton(
              context,
              icon: Icons.article_outlined,
              label: "Перейти к публикации",
              onTap: () => print("Open Post: ${message.message.attachedObjectPostId}"),
            ),
        ],
      ),
    );
  }

  Widget _linkButton(BuildContext context, {required IconData icon, required String label, required VoidCallback onTap}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 0),
      child: SizedBox(
        width: double.infinity,
        child: OutlinedButton.icon(
          onPressed: onTap,
          icon: Icon(icon, size: 18),
          label: Text(
            label,
            style: const TextStyle(fontWeight: FontWeight.w600),
          ),
          style: OutlinedButton.styleFrom(
            // Цвет текста и иконки
            foregroundColor: context.ui.primaryColor,
            // Прозрачный фон
            backgroundColor: Colors.transparent,
            // Настройка рамки
            side: BorderSide(
              color: context.ui.primaryColor,
              width: 1.5,
            ),
            elevation: 0,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12), // Скругление как у карточки
            ),
            // Выравнивание контента по левому краю
            alignment: Alignment.centerLeft,
          ),
        ),
      ),
    );
  }
}