import 'dart:io';
import 'package:dia_room/components/diary/panel_link_buttons.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:dia_room/utils/app_theme.dart';
import 'package:dia_room/models/diary/selected_media.dart';
import 'package:dia_room/models/enums/diary/attachment_type.dart';
import 'package:dia_room/services/diary/upload_manager.dart';

class DiaryInputPanel extends StatelessWidget {
  final TextEditingController controller;
  final List<SelectedMedia> selectedMedia;
  final VoidCallback onSend;
  final Function(int) onRemoveMediaAt;
  final Widget addMenu;
  final String? linkWorkshop;
  final String? linkPost;
  final VoidCallback? onCloseWorkshop;
  final VoidCallback? onClosePost;

  const DiaryInputPanel({
    super.key,
    required this.controller,
    required this.selectedMedia,
    required this.onSend,
    required this.onRemoveMediaAt,
    required this.addMenu,
    this.linkWorkshop,
    this.linkPost,
    this.onCloseWorkshop,
    this.onClosePost
  });

  @override
  Widget build(BuildContext context) {
    final uploadProvider = context.watch<UploadManager>();
    final isUploading = uploadProvider.isUploading;
    final progress = uploadProvider.progress;

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        // 1. Прогресс загрузки
        _buildUploadProgress(context, isUploading, progress),

        if (linkWorkshop != null || linkPost != null)
          AttachedLinksBlock(
              workshopLink: linkWorkshop,
              postLink: linkPost,
              labelWorkshop: 'Ссылка в мастерской', labelPost: 'Ссылка в публикациях', onRemovePost: onClosePost, onRemoveWorkshop: onCloseWorkshop),

        // 2. Список выбранных медиа
        if (selectedMedia.isNotEmpty) _buildMediaPreview(context),

        // 3. Поле ввода и кнопки
        _buildInputRow(context, isUploading),
      ],
    );
  }

  Widget _buildUploadProgress(BuildContext context, bool isUploading, double progress) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      height: isUploading ? 30 : 0,
      clipBehavior: Clip.hardEdge,
      decoration: const BoxDecoration(),
      child: isUploading
          ? OverflowBox(
        alignment: Alignment.topCenter,
        minHeight: 0,
        maxHeight: 30,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            LinearProgressIndicator(
              value: progress,
              minHeight: 4,
              backgroundColor: context.ui.containerColor,
              valueColor: AlwaysStoppedAnimation<Color>(
                context.ui.primaryColor,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              "${(progress * 100).toInt()}%",
              style: const TextStyle(
                fontSize: 10,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      )
          : const SizedBox.shrink(),
    );
  }

  Widget _buildMediaPreview(BuildContext context) {
    return Container(
      height: 80,
      padding: const EdgeInsets.symmetric(horizontal: 8),
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: selectedMedia.length,
        itemBuilder: (context, index) {
          final media = selectedMedia[index];
          return Padding(
            padding: const EdgeInsets.only(right: 8),
            child: Stack(
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: Container(
                    width: 70, height: 70,
                    color: context.ui.containerColor,
                    child: media.type == AttachmentType.video
                        ? (media.thumbnail != null
                        ? Image.file(File(media.thumbnail!), fit: BoxFit.cover)
                        : const Center(child: CircularProgressIndicator(strokeWidth: 2)))
                        : Image.file(media.file, fit: BoxFit.cover),
                  ),
                ),
                if (media.type == AttachmentType.video)
                  const Positioned.fill(child: Icon(Icons.play_circle_outline, color: Colors.white, size: 30)),
                Positioned(
                  top: 2, right: 2,
                  child: GestureDetector(
                    onTap: () => onRemoveMediaAt(index),
                    child: Container(
                      decoration: const BoxDecoration(color: Colors.black54, shape: BoxShape.circle),
                      child: const Icon(Icons.close, size: 16, color: Colors.white),
                    ),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildInputRow(BuildContext context, bool isUploading) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 6, vertical: 6),
      padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 4),
      decoration: BoxDecoration(
        color: context.ui.containerColor,
        borderRadius: BorderRadius.circular(32),
        boxShadow: [BoxShadow(color: Colors.black.withAlpha(5), blurRadius: 10)],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          addMenu, // Наше выпадающее меню
          Expanded(
            child: TextField(
              controller: controller,
              maxLines: 5,
              minLines: 1,
              style: TextStyle(color: context.ui.fontColorPrimary),
              decoration: const InputDecoration(
                filled: true, fillColor: Colors.transparent,
                hintText: "Сообщение...",
                border: InputBorder.none,
                contentPadding: EdgeInsets.symmetric(horizontal: 8, vertical: 10),
              ),
            ),
          ),
          ListenableBuilder( // Перерисовываем только иконку при вводе текста
            listenable: controller,
            builder: (context, child) {
              final hasContent = controller.text.trim().isNotEmpty || selectedMedia.isNotEmpty;
              return IconButton(
                onPressed: isUploading ? null : onSend,
                icon: Icon(
                  Icons.send_rounded,
                  color: hasContent && !isUploading
                      ? context.ui.primaryColor
                      : context.ui.iconColorPrimary,
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}