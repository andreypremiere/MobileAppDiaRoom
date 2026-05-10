import 'package:dia_room/utils/app_theme.dart';
import 'package:flutter/material.dart';

import '../../api/workshop_api.dart';

Future<void> showCreateFolderDialog(
    BuildContext context, {
      required String roomId,
      String? parentId,
      required VoidCallback onSuccess,
    }) async {
  final controller = TextEditingController();

  final folderName = await showDialog<String>(
    context: context,
    builder: (context) => AlertDialog(
      backgroundColor: context.ui.containerColor,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      // title: Text(
      //   'Создать папку',
      //   style: TextStyle(color: context.ui.fontColorPrimary, fontWeight: FontWeight.bold),
      // ),
      content: TextField(
        controller: controller,
        autofocus: true,
        style: TextStyle(color: context.ui.fontColorPrimary),
        decoration: InputDecoration(
          hintText: 'Имя папки',
          hintStyle: TextStyle(color: context.ui.fontColorPrimary.withAlpha(100)),
          enabledBorder: UnderlineInputBorder(borderSide: BorderSide(color: context.ui.primaryColor)),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: Text('Отмена', style: TextStyle(color: context.ui.fontColorPrimary)),
        ),
        TextButton(
          onPressed: () => Navigator.pop(context, controller.text.trim()),
          child: Text('Создать', style: TextStyle(color: context.ui.primaryColor, fontWeight: FontWeight.w600)),
        ),
      ],
    ),
  );

  if (folderName != null && folderName.isNotEmpty) {
    final result = await createFolder(parentId: parentId, name: folderName);
    if (result.success) {
      onSuccess();
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(result.message ?? "Не удалось создать папку")),
      );
    }
  }
}