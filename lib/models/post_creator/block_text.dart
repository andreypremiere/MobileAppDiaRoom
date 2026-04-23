import 'package:flutter/material.dart';

import '../enums/post_types.dart';
import 'block_post.dart';

class TextBlockPost extends BlockPost {
  String value;
  TextType textType;

  TextBlockPost({
    required this.value,
    required this.textType,
  }) : super(type: BlockType.text);

  // Статический метод для создания объекта из Map
  static TextBlockPost fromMap(Map<String, dynamic> map) {
    return TextBlockPost(
      value: map['text'] ?? 'Не удалось извлечь значение текстового блока. Это шаблонный текст.',
      textType: TextType.fromMap(map),
    );
  }
}



class BlockTextCreating extends TextBlockPost implements Validatable{
  TextEditingController controller;
  final FocusNode focusNode;

  BlockTextCreating({
    TextEditingController? controller,
    FocusNode? focusNode,
  })  : controller = controller ?? TextEditingController(),
        focusNode = focusNode ?? FocusNode(),
        super(
        value: controller?.text ?? '',
        textType: TextType.text,
      );

  @override
  String get value => controller.text;

  @override
  set value(String newValue) {
    controller.text = newValue;
  }

  void dispose() {
    controller.dispose();
    focusNode.dispose();
  }

  @override
  bool isEmpty() {
    return value.isEmpty;
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