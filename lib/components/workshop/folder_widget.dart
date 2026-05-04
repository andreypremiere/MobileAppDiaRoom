import 'package:dia_room/utils/app_theme.dart';
import 'package:flutter/material.dart';

import '../../models/enums/workshop/folder_actions.dart';
import '../../models/workshop/Folder.dart';

class FolderItem extends StatelessWidget {
  final Folder folder;
  final VoidCallback onTap;
  final Function(FolderAction) onActionSelected;
  final bool canEdit;

  const FolderItem({
    super.key,
    required this.folder,
    required this.onTap,
    required this.onActionSelected,
    this.canEdit = false,
  });

  void _showContextMenu(BuildContext context, LongPressStartDetails details) async {
    final RenderBox overlay = Overlay.of(context).context.findRenderObject() as RenderBox;

    final result = await showMenu<FolderAction>(
      context: context,
      // Позиция меню там, где был зажат палец
      position: RelativeRect.fromRect(
        details.globalPosition & const Size(40, 40),
        Offset.zero & overlay.size,
      ),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      elevation: 4, // Та же тень
      color: context.ui.containerColor,
      items: [
        _buildPopupItem(context, value: FolderAction.rename, icon: Icons.edit_rounded, label: 'Переименовать'),
        _buildPopupItem(context, value: FolderAction.move, icon: Icons.folder_copy_outlined, label: 'Переместить'),
        _buildPopupItem(context, value: FolderAction.delete, icon: Icons.delete_outline_rounded, label: 'Удалить', isDanger: true),
      ],
    );

    if (result != null) {
      onActionSelected(result);
    }
  }

  // Твой метод создания айтемов (адаптирован под Enum)
  PopupMenuItem<FolderAction> _buildPopupItem(
      BuildContext context, {
        required FolderAction value,
        required IconData icon,
        required String label,
        bool isDanger = false,
      }) {
    final color = isDanger ? Colors.redAccent : context.ui.fontColorPrimary;
    return PopupMenuItem<FolderAction>(
      value: value,
      height: 44,
      child: Row(
        children: [
          Icon(icon, color: color, size: 20),
          const SizedBox(width: 12),
          Text(label, style: TextStyle(fontSize: 15, fontWeight: FontWeight.w500, color: color)),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
        onLongPressStart: canEdit ? (details) {
          _showContextMenu(context, details);
        } : null,
        child:  InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.folder_rounded,
              size: 60,
              color: Colors.grey.shade400,
            ),
            const SizedBox(height: 12),
            Text(
              folder.name,
              textAlign: TextAlign.center,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w500,
                color: context.ui.fontColorPrimary,
              ),
            ),
          ],
        ),
      ),
    ));
  }
}