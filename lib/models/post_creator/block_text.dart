import 'package:dia_room/models/payload/base_block.dart';
import 'package:flutter/material.dart';

import '../enums/post_types.dart';
import '../payload/post_creating_interface.dart';


class BlockTextCreating extends TextBlockPost implements Validatable {
  final TextEditingController controller;
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

  bool isEmpty() {
    return value.trim().isEmpty;
  }
}

