import 'package:dia_room/components/diary/panel_link_buttons.dart';
import 'package:dia_room/components/diary/tags_widget.dart';
import 'package:dia_room/components/diary/video_note_card.dart';
import 'package:dia_room/components/diary/voice_card.dart';
import 'package:dia_room/contracts/diary/response/getting_messages.dart';
import 'package:dia_room/models/enums/diary/message_action.dart';
import 'package:dia_room/models/enums/diary/message_type.dart';
import 'package:dia_room/utils/app_theme.dart';
import 'package:flutter/material.dart';
import 'package:flutter_quill/flutter_quill.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import '../../configuration/constants.dart';
import '../../models/enums/diary/search_method.dart';
import 'media_grid.dart';

class DiaryMessageCard extends StatelessWidget {
  final MessagePresentation message;
  final Function(MessageAction action, MessagePresentation message)? onLongPress;
  final VoidCallback? onCommentsTap;

  const DiaryMessageCard({super.key, required this.message, this.onLongPress, this.onCommentsTap});

  Future<void> _showPopUp(BuildContext context, LongPressStartDetails details) async {
    final Offset tapPosition = details.globalPosition;
    final double screenWidth = MediaQuery.of(context).size.width;
    final double screenHeight = MediaQuery.of(context).size.height;
    const double menuWidth = 200.0;
    const double menuHeight = 120.0;

    double left = tapPosition.dx;
    double top = tapPosition.dy;

    if (left + menuWidth > screenWidth) {
    left = screenWidth - menuWidth - 16;
    }
    if (left < 16) left = 16;

    if (top + menuHeight > screenHeight) {
    top = tapPosition.dy - menuHeight;
    }
    if (top < 16) top = 16;

    final result = await showMenu<MessageAction>(
      color: context.ui.containerColor,
      context: context,
      position: RelativeRect.fromLTRB(
          left,
          top,
          left + menuWidth,
          top + menuHeight,
      ),
      items: MessageAction.values.map((action) {
        return PopupMenuItem<MessageAction>(
          value: action,
          child: Row(
            children: [
              Icon(
                action.icon,
                size: 20,
                color: action == MessageAction.delete ? Colors.redAccent : context.ui.fontColorHint,
              ),
              const SizedBox(width: 12),
              Text(
                action.label,
                style: TextStyle(
                  fontSize: 14,
                  color: context.ui.fontColorPrimary,
                ),
              ),
            ],
          ),
        );
      }).toList(),
      elevation: 4,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
    );

    if (result != null) {
      await onLongPress!(result, message);
    }
  }

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
      return "$timePart · ${DateFormat('dd.MM.yy').format(localDate)}";
    }
  }

  void _handleOnTapWorkshop(BuildContext context) {
    final workshopId = message.message.attachedObjectWorkshopId;
    final roomId = message.message.roomId;

    if (workshopId == null) return;

    final String path = (workshopId == uuidNil)
        ? '/workshop/$roomId'
        : '/workshop/$roomId/$workshopId';

    context.push(path);
  }

  void _handleOnTapPost(BuildContext context) {
    final postId = message.message.attachedObjectPostId;
    if (postId == null) return;
    final String path = "/showPost/${message.message.roomId}/$postId";
    context.push(path);
  }

  void _handleOnTapPostV2(BuildContext context) {
    final postId = message.message.attachedObjectPostV2Id;
    if (postId == null) return;
    final String path = "/post_v2/$postId";
    context.push(path);
  }

  Widget _buildStandardMessage(MessagePresentation message, BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (message.message.contentJson != null && message.message.contentJson!.isNotEmpty)
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 4),
            child: Builder(
              builder: (context) {
                try {
                  final doc = Document.fromJson(message.message.contentJson!);

                  return DefaultTextStyle(
                    style: TextStyle(color: context.ui.fontColorPrimary, fontSize: 15),
                    child: QuillEditor(
                      focusNode: FocusNode(),
                      scrollController: ScrollController(),
                      controller: QuillController(
                        document: doc,
                        selection: const TextSelection.collapsed(offset: 0),
                        readOnly: true,
                      ),
                      config: QuillEditorConfig(
                        autoFocus: false,
                        expands: false,
                        scrollable: false,
                        showCursor: false,
                        enableInteractiveSelection: true,
                        enableSelectionToolbar: true,

                        customStyles: DefaultStyles(
                          paragraph: DefaultTextBlockStyle(
                            TextStyle(
                              fontSize: 16,
                              color: context.ui.fontColorPrimary,
                              height: 1.3,
                            ),
                            const HorizontalSpacing(0, 0),
                            const VerticalSpacing(0, 0),
                            const VerticalSpacing(0, 0),
                            null,
                          ),
                          placeHolder: DefaultTextBlockStyle(
                            TextStyle(
                              fontSize: 16,
                              color: context.ui.fontColorHint,
                              height: 1.3,
                            ),
                            const HorizontalSpacing(0, 0),
                            const VerticalSpacing(0, 0),
                            const VerticalSpacing(0, 0),
                            null,
                          ),
                          quote: DefaultTextBlockStyle(
                            TextStyle(
                              fontSize: 15,
                              color: context.ui.fontColorPrimary.withAlpha(220),
                              fontStyle: FontStyle.italic,
                              height: 1.4,
                            ),
                            const HorizontalSpacing(2, 2),
                            const VerticalSpacing(8, 8),
                            const VerticalSpacing(6, 6),
                            BoxDecoration(
                              color: context.ui.primaryColor.withAlpha(25),
                              borderRadius: BorderRadius.circular(4),
                              border: Border(
                                left: BorderSide(
                                  width: 4,
                                  color: context.ui.primaryColor,
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                  );
                } catch (e) {
                  return Text(
                    message.message.content ?? "Ошибка отображения формата текста",
                    style: TextStyle(fontSize: 15, color: context.ui.fontColorPrimary),
                  );
                }
              },
            ),
          ),

        if (message.attachments.isNotEmpty)
          MediaGrid(attachments: message.attachments),

        if (message.message.attachedObjectWorkshopId != null ||
            message.message.attachedObjectPostId != null || message.message.attachedObjectPostV2Id != null)
          AttachedLinksBlock(
              workshopLink: message.message.attachedObjectWorkshopId,
              postLink: message.message.attachedObjectPostId,
              postV2Link: message.message.attachedObjectPostV2Id,
              labelWorkshop: 'Каталог', labelPost: 'Статья', labelPostV2: "Публикация",
              onTapWorkshop: () => _handleOnTapWorkshop(context),
              onTapPost: () => _handleOnTapPost(context),
              onTapPostV2: () => _handleOnTapPostV2(context)),

        if (message.tags.isNotEmpty)
          TagsWidget(
            tags: message.tags,
            onTagTap: (tag) {
              context.push('/search-messages/${message.message.roomId}', extra: {
                'text': tag.name,
                'method': SearchMethod.byTag,
              });
            },
          ),
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
    } else {
      return const SizedBox.shrink();
    }

    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          GestureDetector(
            onLongPressStart: onLongPress != null
                ? (details) async => _showPopUp(context, details)
                : null,
            child: Container(
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

                  Padding(
                    padding: const EdgeInsets.only(bottom: 16, right: 10, top: 2),
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
            ),
          ),

          Positioned(
            bottom: 0,
            left: 16,
            child: GestureDetector(
              behavior: HitTestBehavior.opaque,
              onTap: onCommentsTap,
              child: Container(
                height: 32,
                padding: const EdgeInsets.symmetric(horizontal: 12),
                decoration: BoxDecoration(
                  color: context.ui.containerColor,
                  borderRadius: BorderRadius.circular(32),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withAlpha(15),
                      blurRadius: 8,
                      offset: const Offset(0, 3),
                    ),
                  ],
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      '${message.message.countComments}',
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w500,
                        color: context.ui.fontColorHint,
                      ),
                    ),
                    const SizedBox(width: 6),
                    Icon(
                      Icons.chat_bubble_outline_rounded,
                      size: 16,
                      color: context.ui.fontColorHint,
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}