import 'package:dia_room/utils/app_theme.dart';
import 'package:flutter/material.dart';

import '../general/dialog_button.dart';

Future<String?> showRenameDialog(BuildContext context, String currentName) async {
  final controller = TextEditingController(text: currentName);

  return showDialog<String>(
    context: context,
    builder: (context) => AlertDialog(
      backgroundColor: context.ui.containerColor,
      title: Text('Новое название', style: TextStyle(color: context.ui.fontColorPrimary)),
      content: TextField(
        controller: controller,
        autofocus: true,
        style: TextStyle(color: context.ui.fontColorPrimary),
        decoration: InputDecoration(
          hintText: 'Введите новое имя',
        ),
      ),
      actions: [
        Row(
          children: [
            DialogButton(
              text: "Отмена",
              onPressed: () {
                if (context.mounted) {
                  Navigator.pop(context);
                }
              },
              textColor: context.ui.fontColorHint,
              isTransparent: true,
              padding: EdgeInsets.symmetric(
                vertical: 8,
                horizontal: 10,
              ),
            ),
            const Spacer(),
            DialogButton(
              text: "Сохранить",
              onPressed: () {
                if (context.mounted) {
                  Navigator.pop(context, controller.text.trim());
                }
              },
              padding: EdgeInsets.symmetric(
                vertical: 8,
                horizontal: 10,
              ),
            ),
          ],
        ),
      ],
    ),
  );
}