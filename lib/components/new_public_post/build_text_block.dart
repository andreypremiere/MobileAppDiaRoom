import 'package:flutter/material.dart';
import '../../models/post_creator/block_text.dart';
import '../../utils/utils.dart';

class TextBlockWidget extends StatelessWidget {
  final BlockText block;
  final VoidCallback onFocus;

  const TextBlockWidget({
    super.key,
    required this.block,
    required this.onFocus,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(borderRadius: BorderRadius.circular(8)),
      clipBehavior: Clip.antiAlias,
      child: TextField(
        controller: block.controller,
        onTap: onFocus, // Вызываем переданный колбэк при клике
        focusNode: block.focusNode,
        autofocus: false,
        minLines: 3,
        maxLines: null,
        style: TextStyle(
          fontFamily: 'SNPro',
          fontSize: block.metadata['size']?.toDouble() ?? 16,
          fontWeight: getFontWeight(block.metadata['weight'] ?? 0),
          color: Colors.black87,
        ),
        decoration: InputDecoration(
          border: InputBorder.none,
          enabledBorder: InputBorder.none,
          focusedBorder: InputBorder.none,
          hintText: 'Введите текст...',
          hintStyle: TextStyle(color: Colors.grey.shade400),
          contentPadding: const EdgeInsets.all(16),
          filled: true,
          fillColor: Colors.white,
        ),
      ),
    );
  }
}