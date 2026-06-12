import 'dart:io';
import 'package:dia_room/components/diary/panel_link_buttons.dart';
import 'package:dia_room/components/diary/tag_chip.dart';
import 'package:dia_room/models/diary/tag.dart';
import 'package:flutter/material.dart';
import 'package:flutter_quill/flutter_quill.dart';
import 'package:provider/provider.dart';
import 'package:dia_room/utils/app_theme.dart';
import 'package:dia_room/models/diary/selected_media.dart';
import 'package:dia_room/models/enums/diary/attachment_type.dart';
import 'package:dia_room/services/diary/upload_manager.dart';

class DiaryInputPanel extends StatefulWidget {
  final QuillController controller;
  final List<SelectedMedia> selectedMedia;
  final VoidCallback onSend;
  final Function(int) onRemoveMediaAt;
  final List<MessageTag> selectedTags;
  final Widget addMenu;
  final String? linkWorkshop;
  final String? linkPost;
  final VoidCallback? onCloseWorkshop;
  final VoidCallback? onClosePost;
  final Function(String)? onCloseTag;

  const DiaryInputPanel({
    super.key,
    required this.controller,
    required this.selectedMedia,
    required this.onSend,
    required this.onRemoveMediaAt,
    required this.addMenu,
    required this.selectedTags,
    this.linkWorkshop,
    this.linkPost,
    this.onCloseWorkshop,
    this.onClosePost,
    this.onCloseTag,
  });

  @override
  State<DiaryInputPanel> createState() => _DiaryInputPanelState();
}

class _DiaryInputPanelState extends State<DiaryInputPanel> {
  // Контроллеры теперь железно живут в State и сохраняют фокус
  final FocusNode _focusNode = FocusNode();
  final ScrollController _scrollController = ScrollController();

  @override
  void dispose() {
    _focusNode.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  // Методы форматирования rich-текста
  void _toggleAttribute(Attribute attribute) {
    final selection = widget.controller.selection;
    if (!selection.isCollapsed) {
      widget.controller.formatSelection(attribute);
    }
  }

  void _clearSelectionStyles() {
    final selection = widget.controller.selection;
    if (!selection.isCollapsed) {
      widget.controller.formatSelection(Attribute.clone(Attribute.bold, null));
      widget.controller.formatSelection(Attribute.clone(Attribute.italic, null));
      widget.controller.formatSelection(Attribute.clone(Attribute.underline, null));
      widget.controller.formatSelection(Attribute.clone(Attribute.blockQuote, null));
    }
  }

  void _showLinkDialog(BuildContext context, void Function() onApplied) {
    final TextEditingController urlController = TextEditingController();
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          backgroundColor: context.ui.containerColor,
          title: const Text('Вставить ссылку'),
          content: TextField(
            controller: urlController,
            decoration: const InputDecoration(
              hintText: 'https://example.com',
              border: OutlineInputBorder(),
            ),
            keyboardType: TextInputType.url,
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Отмена'),
            ),
            TextButton(
              onPressed: () {
                final text = urlController.text.trim();
                if (text.isNotEmpty) {
                  widget.controller.formatSelection(LinkAttribute(text));
                }
                Navigator.pop(context);
                onApplied();
              },
              child: const Text('Применить'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final uploadProvider = context.watch<UploadManager>();
    final isUploading = uploadProvider.isUploading;
    final progress = uploadProvider.progress;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        _buildUploadProgress(context, isUploading, progress),
        if (widget.linkWorkshop != null || widget.linkPost != null)
          AttachedLinksBlock(
              workshopLink: widget.linkWorkshop,
              postLink: widget.linkPost,
              labelWorkshop: 'Ссылка в мастерской',
              labelPost: 'Ссылка в публикациях',
              onRemovePost: widget.onClosePost,
              onRemoveWorkshop: widget.onCloseWorkshop),
        if (widget.selectedMedia.isNotEmpty) _buildMediaPreview(context),
        if (widget.selectedTags.isNotEmpty) _buildTagsPanel(),
        _buildInputRow(context, isUploading),
      ],
    );
  }

  Widget _buildTagsPanel() {
    return Container(
      height: 48,
      padding: const EdgeInsets.symmetric(horizontal: 8),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.start,
          children: widget.selectedTags.map((tag) {
            return Padding(
              padding: const EdgeInsets.only(right: 8),
              child: TagChip(
                tag: tag,
                isSelected: true,
                onClose: widget.onCloseTag,
              ),
            );
          }).toList(),
        ),
      ),
    );
  }

  Widget _buildUploadProgress(BuildContext context, bool isUploading, double progress) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      height: isUploading ? 30 : 0,
      decoration: const BoxDecoration(),
      clipBehavior: Clip.hardEdge,
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
              valueColor: AlwaysStoppedAnimation<Color>(context.ui.primaryColor),
            ),
            const SizedBox(height: 4),
            Text(
              "${(progress * 100).toInt()}%",
              style: const TextStyle(fontSize: 10, fontWeight: FontWeight.bold),
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
        itemCount: widget.selectedMedia.length,
        itemBuilder: (context, index) {
          final media = widget.selectedMedia[index];
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
                    onTap: () => widget.onRemoveMediaAt(index),
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
          widget.addMenu,
          Expanded(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxHeight: 150),
                child: QuillEditor(
                  focusNode: _focusNode,
                  scrollController: _scrollController,
                  controller: widget.controller,
                  config: QuillEditorConfig(
                    placeholder: "Сообщение...",
                    autoFocus: false,
                    expands: false,
                    scrollable: true,
                    showCursor: true,
                    enableSelectionToolbar: true,

                    customStyles: DefaultStyles(
                      // Стиль для обычного текста (абзаца)
                      paragraph: DefaultTextBlockStyle(
                        TextStyle(
                          fontSize: 16, // Делаем крупнее (по дефолту обычно 14)
                          color: context.ui.fontColorPrimary, // Твой цвет текста из темы
                          height: 1.3, // Высота строки для красивого отображения
                        ),
                        const HorizontalSpacing(0, 0),
                        const VerticalSpacing(0, 0), // Убираем дефолтные отступы между абзацами
                        const VerticalSpacing(0, 0),
                        null,
                      ),
                      // Стиль для плейсхолдера (размер должен совпадать с основным текстом)
                      placeHolder: DefaultTextBlockStyle(
                        TextStyle(
                          fontSize: 16,
                          color: context.ui.fontColorHint, // Серый цвет для подсказки
                          height: 1.3,
                        ),
                        const HorizontalSpacing(0, 0),
                        const VerticalSpacing(0, 0),
                        const VerticalSpacing(0, 0),
                        null,
                      ),
                    ),

                    contextMenuBuilder: (context, rawEditorState) {
                      final selection = widget.controller.selection;

                      // Если текст не выделен, показываем дефолтное меню (Вставить)
                      if (selection.isCollapsed) {
                        return AdaptiveTextSelectionToolbar.buttonItems(
                          anchors: rawEditorState.contextMenuAnchors,
                          buttonItems: rawEditorState.contextMenuButtonItems,
                        );
                      }

                      // Если текст выделен — выкатываем кастомную панель стилей
                      return AdaptiveTextSelectionToolbar(
                        anchors: rawEditorState.contextMenuAnchors,
                        children: [
                          IconButton(
                            icon: const Icon(Icons.format_bold, size: 20),
                            onPressed: () {
                              _toggleAttribute(Attribute.bold);
                              rawEditorState.hideToolbar();
                            },
                          ),
                          IconButton(
                            icon: const Icon(Icons.format_italic, size: 20),
                            onPressed: () {
                              _toggleAttribute(Attribute.italic);
                              rawEditorState.hideToolbar();
                            },
                          ),
                          IconButton(
                            icon: const Icon(Icons.format_underlined, size: 20),
                            onPressed: () {
                              _toggleAttribute(Attribute.underline);
                              rawEditorState.hideToolbar();
                            },
                          ),
                          IconButton(
                            icon: const Icon(Icons.format_quote, size: 20),
                            onPressed: () {
                              _toggleAttribute(Attribute.blockQuote);
                              rawEditorState.hideToolbar();
                            },
                          ),
                          IconButton(
                            icon: const Icon(Icons.link, size: 20, color: Colors.blue),
                            onPressed: () {
                              rawEditorState.hideToolbar();
                              _showLinkDialog(context, () {
                                rawEditorState.hideToolbar();
                              });
                            },
                          ),
                          IconButton(
                            icon: const Icon(Icons.format_clear, size: 20, color: Colors.redAccent),
                            onPressed: () {
                              _clearSelectionStyles();
                              rawEditorState.hideToolbar();
                            },
                          ),
                        ],
                      );
                    },
                  ),
                ),
              ),
            ),
          ),
          ListenableBuilder(
            listenable: widget.controller,
            builder: (context, child) {
              final isTextEmpty = widget.controller.document.toPlainText().trim().isEmpty;
              final hasContent = !isTextEmpty || widget.selectedMedia.isNotEmpty;

              return IconButton(
                onPressed: isUploading ? null : widget.onSend,
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