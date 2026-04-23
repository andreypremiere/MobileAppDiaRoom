import 'package:flutter/material.dart';

import '../enums/post_types.dart';
import 'block_post.dart';



class BlockTextCreating extends BlockPost {
  TextEditingController controller;
  final FocusNode focusNode;
  TextType textType;

  BlockTextCreating({
    required this.controller,
    this.textType = TextType.text,
  }) : focusNode = FocusNode(),
        super(type: BlockType.text);

  void dispose() {
    controller.dispose();
    focusNode.dispose();
  }

  @override
  bool isEmpty() {
    return controller.text.isEmpty;
  }
}

class BlockTextUpload extends BlockUpload {
  String text;
  TextType textType;

  BlockTextUpload({
    required this.text,
    required this.textType,
}) : super(type: BlockType.text);


  Map<String, dynamic> toJson() {
    return {
      'blockType': type.slug, // text
      'text': text,
      'textType': textType.slug, // Например: header, paragraph
    };
  }
}