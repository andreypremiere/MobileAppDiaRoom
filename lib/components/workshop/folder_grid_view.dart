import 'package:flutter/material.dart';

import '../../models/enums/workshop/folder_actions.dart';
import '../../models/workshop/folder.dart';
import 'folder_widget.dart';

class FolderGridView extends StatelessWidget {
  final List<Folder> folders;
  final Function(Folder) onFolderTap;
  final Function(Folder, FolderAction) onActionSelected;
  final bool isMyRoom;

  const FolderGridView({
    super.key,
    required this.folders,
    required this.onFolderTap,
    required this.onActionSelected,
    this.isMyRoom = false
  });

  @override
  Widget build(BuildContext context) {
    if (folders.isEmpty) {
      return const Center(child: Text('Тут пока пусто'));
    }

    return GridView.builder(
      padding: const EdgeInsets.all(8),
      itemCount: folders.length,
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        mainAxisSpacing: 12,
        crossAxisSpacing: 12,
        childAspectRatio: 0.9,
      ),
      itemBuilder: (context, index) {
        final folder = folders[index];
        return FolderItem(
          canEdit: isMyRoom,
          folder: folder,
          onTap: () => onFolderTap(folder),
          onActionSelected: (action) => onActionSelected(folder, action),
        );
      },
    );
  }
}