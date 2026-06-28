import 'dart:convert';

import 'package:dia_room/models/post_creator/block_text.dart';
import 'package:dia_room/utils/app_theme.dart';
import 'package:flutter/material.dart';
import 'package:flutter_quill/flutter_quill.dart';

class TextBlockWidget extends StatelessWidget {
  final TextBlockPost block;

  const TextBlockWidget({
    super.key,
    required this.block,
  });

  @override
  Widget build(BuildContext context) {
    late final QuillController controller;

    try {
      controller = QuillController(
        document: Document.fromJson(jsonDecode(block.value)),
        selection: const TextSelection.collapsed(offset: 0),
      );
    } catch (_) {
      controller = QuillController(
        document: Document()..insert(0, block.value),
        selection: const TextSelection.collapsed(offset: 0),
      );
    }
    controller.readOnly = true;

    return QuillEditor.basic(
      controller: controller,
      config: QuillEditorConfig(
        scrollable: false,
        expands: false,
        showCursor: false,
        enableSelectionToolbar: false,
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
            const VerticalSpacing(10, 6),
            const VerticalSpacing(0, 0),
            null,
          ),
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
      ),
    );
  }
}