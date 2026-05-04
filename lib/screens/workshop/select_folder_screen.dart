import 'package:dia_room/components/new_public_post/app_bar_button.dart';
import 'package:dia_room/utils/app_theme.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../api/auth_response.dart';
import '../../api/workshop_api.dart';
import '../../components/general/app_back_button.dart';
import '../../components/general/full_width_button.dart';
import '../../components/workshop/folder_grid_view.dart';
import '../../contracts/workshop/responses/root.dart';

class SelectFolderScreen extends StatefulWidget {
  final String roomId;
  final String? currentFolderId;
  final String targetId;

  const SelectFolderScreen({
    super.key,
    required this.roomId,
    this.currentFolderId,
    required this.targetId,
  });

  @override
  State<SelectFolderScreen> createState() => _SelectFolderScreenState();
}

class _SelectFolderScreenState extends State<SelectFolderScreen> {
  late Future<AuthResponse> _foldersFuture;

  @override
  void initState() {
    super.initState();
    if (widget.currentFolderId == null) {
      _foldersFuture = getRootFolders(roomId: widget.roomId);
    } else {
      _foldersFuture = getFolders(roomId: widget.roomId, folderId: widget.currentFolderId!);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        backgroundColor: context.ui.appBarColor,
        title: Text('Выберите место', style: TextStyle(color: context.ui.fontColorPrimary),),
        leading: widget.currentFolderId != null ? AppBackButton(onPressed: () => context.pop()) : null,
        actions: [
          if (widget.currentFolderId == null)
            AppBarButton(text: "Отмена", onPressed: () => context.pop('cancel'), backgroundColor: context.ui.toolbarContainerColor,)
        ],
      ),
      // Кнопка подтверждения
      bottomNavigationBar: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child:
          FullWidthButton(text: 'Переместить сюда', onPressed: () {
            context.pop(widget.currentFolderId);
          },),
        ),
      ),
      body: FutureBuilder<AuthResponse>(
        future: _foldersFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) return const Center(child: CircularProgressIndicator());
          if (snapshot.hasError || !snapshot.data!.success) return const Center(child: Text('Ошибка'));

          final Root root = Root.fromMap(snapshot.data!.data);

          // ВАЖНО: Фильтруем список, чтобы нельзя было переместить папку саму в себя
          final safeFolders = root.folders.where((f) => f.id != widget.targetId).toList();

          // Переиспользуем твой грид, но отключаем контекстные меню!
          return FolderGridView(
            folders: safeFolders,
            isMyRoom: false,
            onActionSelected: (_, __) {},
            onFolderTap: (folder) {
              context.push<String?>('/select-folder/${widget.roomId}/${widget.targetId}/${folder.id}').then((result) {
                if (result != null) context.pop(result);
              });
            },
          );
        },
      ),
    );
  }
}