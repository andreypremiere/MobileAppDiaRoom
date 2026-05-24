import 'package:dia_room/components/info_dialog_component.dart';
import 'package:dia_room/utils/app_theme.dart';
import 'package:flutter/material.dart';

import '../../api/workshop_api.dart';
import '../../models/workshop/folder.dart';
import '../general/dialog_button.dart';

Future<void> showCreateFolderDialog(
    BuildContext context, {
      required String roomId,
      String? parentId,
      required Function(Folder newFolder) onSuccess,
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

  if (folderName != null && folderName.isNotEmpty) {
    final result = await createFolder(parentId: parentId, name: folderName);
    if (result.success) {
      final newFolder = Folder.fromMap(result.data);
      onSuccess(newFolder);
    } else {
      if (context.mounted) {
        await AppInfoDialog.show(context, result.message ?? "Не удалось создать паппку.");
      }
    }
  }
}