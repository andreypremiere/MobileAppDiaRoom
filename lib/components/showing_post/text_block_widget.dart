import 'package:dia_room/utils/app_theme.dart';
import 'package:flutter/material.dart';
import '../../models/post_creator/block_text.dart';

class TextBlockWidget extends StatelessWidget {
  final TextBlockPost block;

  const TextBlockWidget({
    super.key,
    required this.block,
  });

  @override
  Widget build(BuildContext context) {
    return Text(
      block.value,
      style: TextStyle(
        fontSize: block.textType.size,
        fontWeight: block.textType.weight,
        color: context.ui.fontColorPrimary,
        fontStyle: block.textType.style,
        height: 1.2,
      ),
    );
  }
}