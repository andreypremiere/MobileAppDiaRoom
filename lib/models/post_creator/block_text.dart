import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_quill/flutter_quill.dart';

import '../enums/block_type.dart';
import '../enums/text_type.dart';
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



class BlockTextCreating extends TextBlockPost implements Validatable {
  QuillController controller;
  final FocusNode focusNode;

  BlockTextCreating({
    QuillController? controller,
    FocusNode? focusNode,
  })  : controller = controller ?? QuillController.basic(),
        focusNode = focusNode ?? FocusNode(),
        super(
        value: '', // Родительскому классу пока передаем пустоту
        textType: TextType.text,
      );

  @override
  String get value => jsonEncode(controller.document.toDelta().toJson());

  @override
  set value(String newValue) {
    try {
      controller.document = Document.fromJson(jsonDecode(newValue));
    } catch (_) {
      // Защита: если передали обычную строку, просто вставляем её без стилей
      controller.document = Document()..insert(0, newValue);
    }
  }

  void dispose() {
    controller.dispose();
    focusNode.dispose();
  }

  @override
  bool isEmpty() {
    // Проверяем, есть ли реальный текст (убираем пробелы и переносы)
    return controller.document.toPlainText().trim().isEmpty;
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