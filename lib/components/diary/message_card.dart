import 'package:dia_room/components/diary/panel_link_buttons.dart';
import 'package:dia_room/components/diary/video_note_card.dart';
import 'package:dia_room/components/diary/voice_card.dart';
import 'package:dia_room/contracts/diary/response/getting_messages.dart';
import 'package:dia_room/models/enums/diary/message_type.dart';
import 'package:dia_room/utils/app_theme.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import '../../configuration/constants.dart';
import 'media_grid.dart';

class DiaryMessageCard extends StatelessWidget {
  final MessagePresentation message;

  const DiaryMessageCard({super.key, required this.message});

  String formatSmartDate(DateTime date) {
    final localDate = date.toLocal();

    final now = DateTime.now();

    final today = DateTime(now.year, now.month, now.day);
    final yesterday = today.subtract(const Duration(days: 1));
    final dateToCheck = DateTime(localDate.year, localDate.month, localDate.day);

    final String timePart = DateFormat('HH:mm').format(localDate);

    if (dateToCheck == today) {
      return timePart;
    } else if (dateToCheck == yesterday) {
      return "Вчера в $timePart";
    } else {
      // Для старых дат выводим день и время
      return "$timePart · ${DateFormat('dd.MM.yy').format(localDate)}";
    }
  }

  void _handleOnTapWorkshop(BuildContext context) {
    print('Там по мастерской');
    final workshopId = message.message.attachedObjectWorkshopId;
    final roomId = message.message.roomId;

    if (workshopId == null) return;

    // Если это "нулевой" ID, переходим только по roomId, иначе добавляем folderId
    final String path = (workshopId == uuidNil)
        ? '/workshop/$roomId'
        : '/workshop/$roomId/$workshopId';

    context.push(path);
  }

  void _handleOnTapPost(BuildContext context) {
    print('Там по посту');
    final postId = message.message.attachedObjectPostId;
    if (postId == null) return;
    final String path = "/showPost/$postId";
    context.push(path);
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
          AttachedLinksBlock(
              workshopLink: message.message.attachedObjectWorkshopId,
              postLink: message.message.attachedObjectPostId,
              labelWorkshop: 'Ссылка в мастерской', labelPost: 'Ссылка в публикациях',
              onTapWorkshop: () => _handleOnTapWorkshop(context),
              onTapPost: () => _handleOnTapPost(context)),

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
}