import 'package:flutter/material.dart';

import '../enums/post_types.dart';
import 'block_post.dart';

class BlockText extends BlockPost {
  TextEditingController controller;
  final FocusNode focusNode;
  TextType textType;
  Map<String, dynamic> metadata;

  BlockText({
    required this.controller,
    Map<String, dynamic>? metadata,
    this.textType = TextType.text,
  }) : focusNode = FocusNode(), metadata = metadata ?? {},
        super(type: BlockPostType.text);

  void dispose() {
    controller.dispose();
    focusNode.dispose();
  }
}