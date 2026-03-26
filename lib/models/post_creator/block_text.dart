import 'package:flutter/material.dart';

import '../enums/post_types.dart';
import 'block_post.dart';

class MetadataText {
  int size;
  int weight;

  MetadataText() : size = 14, weight = 400;

  Map<String, dynamic> toJson() {
    return {
      'size': size,
      'weight': weight,
    };
  }
}

class BlockText extends BlockPost {
  TextEditingController controller;
  final FocusNode focusNode;
  TextType textType;
  MetadataText metadata;

  BlockText({
    required this.controller,
    MetadataText? metadata,
    this.textType = TextType.text,
  }) : focusNode = FocusNode(), metadata = metadata ?? MetadataText(),
        super(type: BlockPostType.text);

  void dispose() {
    controller.dispose();
    focusNode.dispose();
  }

  void setTitleType() {
    // textType = TextType.header;
    metadata.size = 22;
    metadata.weight = 800;
  }

  void setSubtitleType() {
    // textType = TextType.subtitle;
    metadata.size = 18;
    metadata.weight = 600;
  }

  void setUsualText() {
    // textType = TextType.text;
    metadata.size = 16;
    metadata.weight = 400;
  }

  @override
  bool isEmpty() {
    return controller.text.isEmpty;
  }
}

class BlockTextUpload extends BlockUpload {
  String text;
  TextType textType;
  MetadataText metadata;

  BlockTextUpload({
    required this.text,
    required this.textType,
    required this.metadata
}) : super(type: BlockPostType.text);


  Map<String, dynamic> toJson() {
    return {
      'type': type.name, // text
      'text': text,
      'textType': textType.name, // Например: header, paragraph
      'metadata': metadata.toJson(),
    };
  }
}