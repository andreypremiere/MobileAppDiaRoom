import 'package:dia_room/utils/app_theme.dart';
import 'package:flutter/material.dart';

Future<String?> showRenameDialog(BuildContext context, String currentName) async {
  final controller = TextEditingController(text: currentName);

  return showDialog<String>(
    context: context,
    builder: (context) => AlertDialog(
      backgroundColor: context.ui.containerColor,
      // title: Text('Переименование', style: TextStyle(color: context.ui.fontColorPrimary)),
      content: TextField(
        controller: controller,
        autofocus: true,
        style: TextStyle(color: context.ui.fontColorPrimary),
        decoration: InputDecoration(
          hintText: 'Введите новое имя',
        ),
      ),
      actions: [
        TextButton(onPressed: () => Navigator.pop(context), child: Text('Отмена', style: TextStyle(color: context.ui.fontColorPrimary),)),
        TextButton(
          onPressed: () => Navigator.pop(context, controller.text),
          child: Text('Сохранить', style: TextStyle(color: context.ui.fontColorPrimary, fontWeight: FontWeight.w500),),
        ),
      ],
    ),
  );
}