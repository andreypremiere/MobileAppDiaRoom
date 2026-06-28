import 'package:dia_room/utils/app_theme.dart';
import 'package:flutter/material.dart';
import 'package:flutter_quill/flutter_quill.dart';
import '../../models/post_creator/block_text.dart';

class TextBlockWidget extends StatefulWidget {
  final BlockTextCreating block;
  final VoidCallback onFocus;

  const TextBlockWidget({
    super.key,
    required this.block,
    required this.onFocus,
  });

  @override
  State<TextBlockWidget> createState() => _TextBlockWidgetState();
}

class _TextBlockWidgetState extends State<TextBlockWidget> {

  @override
  void initState() {
    super.initState();
    // Слушаем фокус: если тапнули прямо в текст Quill, сообщаем родителю
    widget.block.focusNode.addListener(_onFocusChange);
  }

  @override
  void dispose() {
    widget.block.focusNode.removeListener(_onFocusChange);
    super.dispose();
  }

  void _onFocusChange() {
    if (widget.block.focusNode.hasFocus) {
      widget.onFocus();
    }
  }

  // --- Методы форматирования из Diary ---
  void _toggleAttribute(Attribute attribute) {
    final selection = widget.block.controller.selection;
    if (!selection.isCollapsed) {
      widget.block.controller.formatSelection(attribute);
    }
  }

  void _clearSelectionStyles() {
    final selection = widget.block.controller.selection;
    if (!selection.isCollapsed) {
      widget.block.controller.formatSelection(Attribute.clone(Attribute.bold, null));
      widget.block.controller.formatSelection(Attribute.clone(Attribute.italic, null));
      widget.block.controller.formatSelection(Attribute.clone(Attribute.underline, null));
      widget.block.controller.formatSelection(Attribute.clone(Attribute.blockQuote, null));
      widget.block.controller.formatSelection(Attribute.clone(Attribute.header, null));
      widget.block.controller.formatSelection(Attribute.clone(Attribute.h1, null));
      widget.block.controller.formatSelection(Attribute.clone(Attribute.h2, null));
      widget.block.controller.formatSelection(Attribute.clone(Attribute.header, null));
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
                  widget.block.controller.formatSelection(LinkAttribute(text));
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
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
      ),
      clipBehavior: Clip.antiAlias,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: QuillEditor(
          focusNode: widget.block.focusNode,
          scrollController: ScrollController(),
          controller: widget.block.controller,
          config: QuillEditorConfig(
            placeholder: "Введите текст...",
            autoFocus: false,
            // scrollable ставим false: блок текста должен расширяться вниз (как maxLines: null)
            scrollable: false,
            expands: false,
            showCursor: true,
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
                  color: Colors.grey.shade400,
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
              h1: DefaultTextBlockStyle(
                TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: context.ui.fontColorPrimary,
                  height: 1.2,
                ),
                const HorizontalSpacing(0, 0),
                const VerticalSpacing(10, 6), // Отступы сверху и снизу заголовка
                const VerticalSpacing(0, 0),
                null,
              ),
              // Стилизация Среднего заголовка (H2)
              h2: DefaultTextBlockStyle(
                TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w600,
                  color: context.ui.fontColorPrimary,
                  height: 1.2,
                ),
                const HorizontalSpacing(0, 0),
                const VerticalSpacing(8, 4),
                const VerticalSpacing(0, 0),
                null,
              ),
            ),
            contextMenuBuilder: (context, rawEditorState) {
              final selection = widget.block.controller.selection;

              if (selection.isCollapsed) {
                return AdaptiveTextSelectionToolbar.buttonItems(
                  anchors: rawEditorState.contextMenuAnchors,
                  buttonItems: rawEditorState.contextMenuButtonItems,
                );
              }

              return AdaptiveTextSelectionToolbar(
                anchors: rawEditorState.contextMenuAnchors,
                children: [
                  // 2. СТАНДАРТНЫЕ СТИЛИ
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
                  MenuAnchor(
                    builder: (BuildContext context, MenuController controller, Widget? child) {
                      return IconButton(
                        icon: Icon(Icons.text_fields_rounded, size: 22, color: context.ui.fontColorPrimary),
                        tooltip: 'Шрифты и заголовки',
                        onPressed: () {
                          if (controller.isOpen) {
                            controller.close();
                          } else {
                            controller.open();
                          }
                        },
                      );
                    },
                    menuChildren: [
                      MenuItemButton(
                        onPressed: () {
                          _toggleAttribute(Attribute.h1);
                          rawEditorState.hideToolbar();
                        },
                        child: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 8),
                          child: Text(
                            'Заголовок 1',
                            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: context.ui.fontColorPrimary),
                          ),
                        ),
                      ),
                      MenuItemButton(
                        onPressed: () {
                          _toggleAttribute(Attribute.h2);
                          rawEditorState.hideToolbar();
                        },
                        child: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 8),
                          child: Text(
                            'Заголовок 2',
                            style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: context.ui.fontColorPrimary),
                          ),
                        ),
                      ),
                    ],
                  ),
                  IconButton(
                    onPressed: () {
                      _clearSelectionStyles();
                      rawEditorState.hideToolbar();
                    },
                    icon: const Icon(Icons.format_clear, size: 18, color: Colors.redAccent),
                    // child: Text('Сбросить стиль', style: TextStyle(color: context.ui.fontColorPrimary)),
                  ),


                  // 3. МЕНЮ ТРОЕТОЧИЯ через MenuAnchor
                  MenuAnchor(
                    builder: (BuildContext context, MenuController controller, Widget? child) {
                      return IconButton(
                        icon: Icon(Icons.more_vert_rounded, size: 22, color: context.ui.fontColorPrimary),
                        tooltip: 'Еще',
                        onPressed: () {
                          if (controller.isOpen) {
                            controller.close();
                          } else {
                            controller.open();
                          }
                        },
                      );
                    },
                    menuChildren: [
                      MenuItemButton(
                        onPressed: () {
                          rawEditorState.copySelection(SelectionChangedCause.toolbar);
                          rawEditorState.hideToolbar();
                        },
                        leadingIcon: Icon(Icons.copy_rounded, size: 18, color: context.ui.fontColorPrimary),
                        child: Text('Копировать', style: TextStyle(color: context.ui.fontColorPrimary)),
                      ),
                      MenuItemButton(
                        onPressed: () {
                          rawEditorState.cutSelection(SelectionChangedCause.toolbar);
                          rawEditorState.hideToolbar();
                        },
                        leadingIcon: Icon(Icons.cut_rounded, size: 18, color: context.ui.fontColorPrimary),
                        child: Text('Вырезать', style: TextStyle(color: context.ui.fontColorPrimary)),
                      ),
                      // const PubMenuDividerWrap(), // Разделитель (кастомный или стандартный, см. ниже)

                    ],
                  ),
                ],
              );
            },
          ),
        ),
      ),
    );
  }
}

class PubMenuDividerWrap extends StatelessWidget {
  const PubMenuDividerWrap({super.key});

  @override
  Widget build(BuildContext context) {
    return const Divider(height: 1, thickness: 1);
  }
}